import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../shared/widgets/blueprint_background.dart';
import '../models/chat_message.dart';
import '../providers/ai_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/suggestion_pills.dart';

/// Layar Mentor / Penasihat Keuangan AI SmartFi
class AiAdvisorScreen extends ConsumerStatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  ConsumerState<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends ConsumerState<AiAdvisorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? presetText]) async {
    final text = presetText ?? _inputController.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _inputController.clear();
    }

    _scrollToBottom();
    final notifier = ref.read(chatProvider.notifier);

    // Kirim pesan ke provider AI
    await notifier.sendMessage(text);
    _scrollToBottom();

    // Mainkan efek suara chat
    AudioService().playChatSound();
  }

  Future<void> _handleConfirmClear() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: NeoColors.surfaceLight,
            border: Border.all(color: NeoColors.black, width: 4),
            boxShadow: NeoColors.hardShadow(offset: 8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: NeoColors.bgLight,
                  border: Border(
                    bottom: BorderSide(color: NeoColors.black, width: 4),
                  ),
                ),
                child: const Text(
                  'HAPUS OBROLAN',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Apakah Anda yakin ingin menghapus semua riwayat obrolan dengan Penasihat AI?',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.of(ctx).pop(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: NeoColors.white,
                                border: Border.all(color: NeoColors.black, width: 2),
                                boxShadow: NeoColors.hardShadow(offset: 2),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'BATAL',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.of(ctx).pop(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: NeoColors.dangerRed,
                                border: Border.all(color: NeoColors.black, width: 2),
                                boxShadow: NeoColors.hardShadow(offset: 2),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'HAPUS',
                                style: TextStyle(
                                  color: NeoColors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldClear == true) {
      await ref.read(chatProvider.notifier).clearHistory();
    }
  }

  void _showApiSourceDialog() {
    final isReal = ref.read(useRealAiApiProvider);
    showDialog(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: NeoColors.surfaceLight,
            border: Border.all(color: NeoColors.black, width: 4),
            boxShadow: NeoColors.hardShadow(offset: 8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: NeoColors.bgLight,
                  border: Border(
                    bottom: BorderSide(color: NeoColors.black, width: 4),
                  ),
                ),
                child: const Text(
                  'SUMBER API AI',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Pilih sumber kecerdasan AI untuk konsultasi finansial:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () {
                        ref.read(useRealAiApiProvider.notifier).state = true;
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isReal ? NeoColors.yellowAccent : NeoColors.white,
                          border: Border.all(color: NeoColors.black, width: 2),
                          boxShadow: NeoColors.hardShadow(offset: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isReal ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: NeoColors.black,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'API BANGUNWEB (REAL ONLINE)',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                  ),
                                  Text(
                                    'Menggunakan endpoint OpenAI via BangunWeb (env.json)',
                                    style: TextStyle(fontSize: 10, color: NeoColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        ref.read(useRealAiApiProvider.notifier).state = false;
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: !isReal ? NeoColors.yellowAccent : NeoColors.white,
                          border: Border.all(color: NeoColors.black, width: 2),
                          boxShadow: NeoColors.hardShadow(offset: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              !isReal ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: NeoColors.black,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'DUMMY REPOSITORY (OFFLINE)',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                  ),
                                  Text(
                                    'Bekerja tanpa koneksi internet dengan kalkulasi lokal',
                                    style: TextStyle(fontSize: 10, color: NeoColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final messages = chatState.messages;
    final isLoading = chatState.isLoading;
    final isRealApi = ref.watch(useRealAiApiProvider);

    // Auto scroll saat pesan berubah
    ref.listen(chatProvider, (_, __) => _scrollToBottom());

    return BlueprintBackground(
      child: Column(
        children: [
          // Header Terintegrasi Neobrutalism
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: NeoColors.white,
              border: Border(
                bottom: BorderSide(color: NeoColors.black, width: 3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: NeoColors.white,
                    border: Border.all(color: NeoColors.black, width: 2),
                    boxShadow: NeoColors.hardShadow(offset: 2),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'PENASIHAT AI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'SELALU SIAP MEMBANTU KEUANGANMU',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: NeoColors.textMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge Mode API
                InkWell(
                  onTap: _showApiSourceDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isRealApi ? NeoColors.successGreenLight : NeoColors.yellowAccent,
                      border: Border.all(color: NeoColors.black, width: 2),
                      boxShadow: NeoColors.hardShadow(offset: 2),
                    ),
                    child: Text(
                      isRealApi ? 'REAL AI' : 'OFFLINE',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Muat Ulang Permintaan Terakhir
                InkWell(
                  onTap: messages.length <= 1 || isLoading
                      ? null
                      : () => ref.read(chatProvider.notifier).regenerateLastResponse(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: messages.length <= 1 || isLoading
                          ? Colors.grey.shade300
                          : NeoColors.white,
                      border: Border.all(color: NeoColors.black, width: 2),
                      boxShadow: NeoColors.hardShadow(offset: 2),
                    ),
                    child: const Icon(Icons.refresh, size: 18, color: NeoColors.black),
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Hapus Obrolan
                InkWell(
                  onTap: isLoading ? null : _handleConfirmClear,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: NeoColors.dangerRed,
                      border: Border.all(color: NeoColors.black, width: 2),
                      boxShadow: NeoColors.hardShadow(offset: 2),
                    ),
                    child: const Icon(Icons.delete_outline, size: 18, color: NeoColors.white),
                  ),
                ),
              ],
            ),
          ),

          // Area Daftar Chat
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(14),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  final msg = messages[index];
                  final isLast = index == messages.length - 1;
                  return ChatMessageBubble(
                    message: msg,
                    isLastAiMessage: isLast && msg.isAi,
                    isAiLoading: isLoading,
                    onRegenerate: () =>
                        ref.read(chatProvider.notifier).regenerateLastResponse(),
                  );
                } else {
                  // Bubble loading typing indicator
                  return ChatMessageBubble(
                    message: ChatMessage(
                      id: 'typing_temp',
                      role: 'ai',
                      content: '',
                      createdAt: DateTime.now(),
                    ),
                    isAiLoading: true,
                  );
                }
              },
            ),
          ),

          // Area Bawah: Suggestion Pills + Input Box
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: const BoxDecoration(
              color: NeoColors.white,
              border: Border(
                top: BorderSide(color: NeoColors.black, width: 3),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Suggestion Pills
                  SuggestionPills(
                    disabled: isLoading,
                    onSelected: (text) => _handleSend(text),
                  ),
                  const SizedBox(height: 10),

                  // Input Box + Send Button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: NeoColors.white,
                            border: Border.all(color: NeoColors.black, width: 3),
                            boxShadow: NeoColors.hardShadow(offset: 3),
                          ),
                          child: TextField(
                            controller: _inputController,
                            focusNode: _focusNode,
                            enabled: !isLoading,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: NeoColors.black,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Ketik pertanyaan Anda...',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: NeoColors.textMuted,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (val) => _handleSend(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: isLoading ? null : () => _handleSend(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isLoading ? Colors.grey.shade400 : NeoColors.primaryBlue,
                            border: Border.all(color: NeoColors.black, width: 3),
                            boxShadow: NeoColors.hardShadow(
                              offset: isLoading ? 0 : 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.send,
                            size: 20,
                            color: NeoColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Disclaimer
                  const Text(
                    'SmartFi AI dapat membuat kesalahan. Harap verifikasi informasi penting.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      color: NeoColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
