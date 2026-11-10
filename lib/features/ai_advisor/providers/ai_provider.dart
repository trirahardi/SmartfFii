import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/ai_config.dart';
import '../../../data/repositories/ai_repository.dart';
import '../../../data/repositories/dummy/dummy_ai_repository.dart';
import '../../../data/repositories/openai/openai_ai_repository.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../models/chat_message.dart';

/// Provider sakelar tunggal untuk berpindah antara AI dummy dan API OpenAI sungguhan
final useRealAiApiProvider = StateProvider<bool>((ref) {
  // Aktif otomatis jika API key tersedia di env.json
  return AiConfig.hasApiKey;
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final useReal = ref.watch(useRealAiApiProvider);
  if (useReal && AiConfig.hasApiKey) {
    return OpenAiAiRepository();
  }
  return DummyAiRepository();
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  const ChatState({
    required this.messages,
    this.isLoading = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final AiRepository _aiRepository;
  final Ref _ref;
  static const String _storageKey = 'smartfi_ai_chat_history';

  static final List<ChatMessage> _initialGreeting = [
    ChatMessage(
      id: 'msg_greet',
      role: 'ai',
      content: 'Halo! Saya SmartFi, Mentor Keuangan Pribadimu. Apa yang ingin kamu ketahui? Kamu bisa bertanya tentang pengeluaran terbesar, saran hemat, atau ringkasan bulan ini.',
      createdAt: DateTime.now(),
    ),
  ];

  ChatNotifier(this._aiRepository, this._ref) : super(ChatState(messages: _initialGreeting)) {
    loadChatHistory();
  }

  Future<void> loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString(_storageKey);
      if (savedStr != null && savedStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(savedStr);
        final loaded = list.map((item) => ChatMessage.fromJson(item as Map<String, dynamic>)).toList();
        if (loaded.isNotEmpty) {
          state = state.copyWith(messages: loaded);
          return;
        }
      }
    } catch (_) {}
    state = state.copyWith(messages: _initialGreeting);
  }

  Future<void> _saveHistory(List<ChatMessage> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((m) => m.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  String _buildFinancialContext() {
    final txsAsync = _ref.read(transactionsProvider);
    final txs = txsAsync.asData?.value ?? [];

    final income = txs.where((t) => t.isIncome).fold<int>(0, (sum, t) => sum + t.nominal);
    final expense = txs.where((t) => t.isExpense).fold<int>(0, (sum, t) => sum + t.nominal);
    final balance = income - expense;

    // Hitung kategori terbesar
    final catTotals = <String, int>{};
    for (final t in txs.where((t) => t.isExpense)) {
      catTotals[t.categoryName] = (catTotals[t.categoryName] ?? 0) + t.nominal;
    }

    String topCategory = 'Makanan';
    int topAmount = 0;
    catTotals.forEach((cat, amt) {
      if (amt > topAmount) {
        topAmount = amt;
        topCategory = cat;
      }
    });

    final recent15 = txs.take(15).map((t) => {
      'tipe': t.type,
      'kategori': t.categoryName,
      'nominal': t.nominal,
      'deskripsi': t.description,
      'tanggal': t.transactionDate.toIso8601String().split('T').first,
    }).toList();

    return jsonEncode({
      'saldo_terkini': balance,
      'total_pemasukan': income,
      'total_pengeluaran': expense,
      'kategori_terbesar': topCategory,
      'nominal_kategori_terbesar': topAmount,
      'transaksi_terbaru': recent15,
    });
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: trimmed,
      createdAt: DateTime.now(),
    );

    final currentMessages = [...state.messages, userMsg];
    state = state.copyWith(
      messages: currentMessages,
      isLoading: true,
      errorMessage: null,
    );
    await _saveHistory(currentMessages);

    try {
      final contextJson = _buildFinancialContext();
      final reply = await _aiRepository.askMentor(
        message: trimmed,
        history: state.messages,
        financialContextJson: contextJson,
      );

      final aiMsg = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        role: 'ai',
        content: reply,
        createdAt: DateTime.now(),
      );

      final updated = [...currentMessages, aiMsg];
      state = state.copyWith(messages: updated, isLoading: false);
      await _saveHistory(updated);
    } catch (e) {
      final friendlyError = e.toString().replaceAll('Exception: ', '').replaceAll('HttpException: ', '').replaceAll('SocketException: ', '');
      final aiErrorMsg = ChatMessage(
        id: 'msg_err_${DateTime.now().millisecondsSinceEpoch}',
        role: 'ai',
        content: friendlyError.isNotEmpty
            ? friendlyError
            : 'Terjadi kesalahan saat menghubungi server AI. Mohon coba sesaat lagi.',
        createdAt: DateTime.now(),
      );
      final updated = [...currentMessages, aiErrorMsg];
      state = state.copyWith(messages: updated, isLoading: false, errorMessage: friendlyError);
      await _saveHistory(updated);
    }
  }

  Future<void> regenerateLastResponse() async {
    if (state.isLoading || state.messages.isEmpty) return;

    // Cari pesan user terakhir
    int lastUserIndex = -1;
    for (int i = state.messages.length - 1; i >= 0; i--) {
      if (state.messages[i].isUser) {
        lastUserIndex = i;
        break;
      }
    }

    if (lastUserIndex == -1) return;

    final userMsgText = state.messages[lastUserIndex].content;
    final truncatedList = state.messages.sublist(0, lastUserIndex + 1);

    state = state.copyWith(messages: truncatedList, isLoading: true, errorMessage: null);

    try {
      final contextJson = _buildFinancialContext();
      final reply = await _aiRepository.askMentor(
        message: userMsgText,
        history: truncatedList,
        financialContextJson: contextJson,
      );

      final aiMsg = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        role: 'ai',
        content: reply,
        createdAt: DateTime.now(),
      );

      final updated = [...truncatedList, aiMsg];
      state = state.copyWith(messages: updated, isLoading: false);
      await _saveHistory(updated);
    } catch (e) {
      final friendlyError = e.toString().replaceAll('Exception: ', '').replaceAll('HttpException: ', '').replaceAll('SocketException: ', '');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError);
    }
  }

  Future<void> clearHistory() async {
    state = ChatState(messages: _initialGreeting);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repo = ref.watch(aiRepositoryProvider);
  return ChatNotifier(repo, ref);
});

