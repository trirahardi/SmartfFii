import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/transaction_model.dart';
import '../transaction_repository.dart';

class DummyTransactionRepository implements TransactionRepository {
  static const String _transactionsKey = 'smartfi_transactions_';

  String _getKey(String userId) => '$_transactionsKey$userId';

  @override
  Future<List<TransactionModel>> getTransactions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_getKey(userId));

    List<TransactionModel> transactions = [];

    if (jsonStr == null || jsonStr.isEmpty) {
      // Inisialisasi transaksi contoh jika masih kosong
      transactions = _getInitialSampleTransactions(userId);
      await _saveTransactions(userId, transactions);
    } else {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        transactions = list
            .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        transactions = _getInitialSampleTransactions(userId);
      }
    }

    // Urutkan dari yang terbaru
    transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    // Terapkan filter
    return transactions.where((tx) {
      if (startDate != null) {
        final startOfDay = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
        if (tx.transactionDate.isBefore(startOfDay)) return false;
      }
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        if (tx.transactionDate.isAfter(endOfDay)) return false;
      }
      if (type != null && type != 'all') {
        if (tx.type != type) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _saveTransactions(String userId, List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_getKey(userId), jsonEncode(jsonList));
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    final current = await getTransactions(transaction.userId);
    current.insert(0, transaction);
    await _saveTransactions(transaction.userId, current);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final current = await getTransactions(transaction.userId);
    final index = current.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      current[index] = transaction;
      await _saveTransactions(transaction.userId, current);
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().where((k) => k.startsWith(_transactionsKey));

    for (final key in allKeys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        final List<dynamic> list = jsonDecode(jsonStr);
        final transactions = list
            .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
            .toList();
        transactions.removeWhere((t) => t.id == transactionId);
        await prefs.setString(key, jsonEncode(transactions.map((t) => t.toJson()).toList()));
      }
    }
  }

  @override
  Future<void> deleteTransactionsByRange(String userId, String range) async {
    final current = await getTransactions(userId);
    final now = DateTime.now();

    if (range == 'all') {
      await _saveTransactions(userId, []);
    } else if (range == 'this_month') {
      final startOfMonth = DateTime(now.year, now.month, 1);
      current.removeWhere((tx) => !tx.transactionDate.isBefore(startOfMonth));
      await _saveTransactions(userId, current);
    } else if (range == 'this_year') {
      final startOfYear = DateTime(now.year, 1, 1);
      current.removeWhere((tx) => !tx.transactionDate.isBefore(startOfYear));
      await _saveTransactions(userId, current);
    }
  }

  List<TransactionModel> _getInitialSampleTransactions(String userId) {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'tx_init_1',
        userId: userId,
        type: 'income',
        nominal: 6000000,
        description: 'Gaji Bulanan',
        categoryId: 'def-4',
        categoryName: 'Gaji',
        transactionDate: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      TransactionModel(
        id: 'tx_init_2',
        userId: userId,
        type: 'expense',
        nominal: 45000,
        description: 'Makan siang ayam geprek',
        categoryId: 'def-1',
        categoryName: 'Makanan',
        transactionDate: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      TransactionModel(
        id: 'tx_init_3',
        userId: userId,
        type: 'expense',
        nominal: 100000,
        description: 'Bensin & Tol',
        categoryId: 'def-2',
        categoryName: 'Transportasi',
        transactionDate: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TransactionModel(
        id: 'tx_init_4',
        userId: userId,
        type: 'expense',
        nominal: 50000,
        description: 'Langganan streaming film',
        categoryId: 'def-3',
        categoryName: 'Hiburan',
        transactionDate: now,
        createdAt: now,
      ),
    ];
  }
}

