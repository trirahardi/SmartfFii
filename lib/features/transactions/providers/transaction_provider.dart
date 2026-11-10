import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/firebase/firebase_transaction_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../auth/providers/auth_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return FirebaseTransactionRepository();
});

class TransactionsNotifier extends StateNotifier<AsyncValue<List<TransactionModel>>> {
  final TransactionRepository _repository;
  final String _userId;

  TransactionsNotifier(this._repository, this._userId) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions({DateTime? startDate, DateTime? endDate, String? type}) async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getTransactions(
        _userId,
        startDate: startDate,
        endDate: endDate,
        type: type,
      );
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTransaction(TransactionModel tx) async {
    try {
      await _repository.addTransaction(tx);
      await loadTransactions();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    try {
      await _repository.updateTransaction(tx);
      await loadTransactions();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTransaction(String txId) async {
    try {
      await _repository.deleteTransaction(txId);
      await loadTransactions();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteByRange(String range) async {
    try {
      await _repository.deleteTransactionsByRange(_userId, range);
      await loadTransactions();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<TransactionModel>>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final userAsync = ref.watch(authStateProvider);
  final userId = userAsync.asData?.value?.id ?? 'default_user';

  return TransactionsNotifier(repo, userId);
});

