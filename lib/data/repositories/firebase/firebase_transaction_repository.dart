import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/transaction_model.dart';
import '../transaction_repository.dart';

/// Implementasi Cloud Firestore untuk Penyimpanan Transaksi Pengguna
class FirebaseTransactionRepository implements TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _resolveUserId(String passedUserId) {
    if (passedUserId.isNotEmpty && passedUserId != 'default_user') {
      return passedUserId;
    }
    return _auth.currentUser?.uid ?? 'anonymous_user';
  }

  @override
  Future<List<TransactionModel>> getTransactions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    final uid = _resolveUserId(userId);
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('transactionDate', descending: true);

    if (startDate != null) {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      query = query.where('transactionDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start));
    }
    if (endDate != null) {
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query.where('transactionDate', isLessThanOrEqualTo: Timestamp.fromDate(end));
    }
    if (type != null && type != 'all') {
      query = query.where('type', isEqualTo: type);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      DateTime txDate = DateTime.now();
      if (data['transactionDate'] is Timestamp) {
        txDate = (data['transactionDate'] as Timestamp).toDate();
      } else if (data['transactionDate'] is String) {
        txDate = DateTime.tryParse(data['transactionDate'] as String) ?? DateTime.now();
      }

      DateTime createdAt = DateTime.now();
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        createdAt = DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now();
      }

      return TransactionModel(
        id: doc.id,
        userId: uid,
        type: data['type'] as String? ?? 'expense',
        nominal: (data['nominal'] as num?)?.toInt() ?? 0,
        description: data['description'] as String? ?? '',
        categoryId: data['categoryId'] as String?,
        categoryName: data['categoryName'] as String? ?? 'Lainnya',
        transactionDate: txDate,
        createdAt: createdAt,
      );
    }).toList();
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    final uid = _resolveUserId(transaction.userId);
    final col = _firestore.collection('users').doc(uid).collection('transactions');
    final docRef = col.doc();

    final data = {
      'id': docRef.id,
      'userId': uid,
      'type': transaction.type,
      'nominal': transaction.nominal,
      'description': transaction.description,
      'categoryId': transaction.categoryId,
      'categoryName': transaction.categoryName,
      'transactionDate': Timestamp.fromDate(transaction.transactionDate),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data);
    return transaction.copyWith(id: docRef.id, userId: uid);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final uid = _resolveUserId(transaction.userId);
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transaction.id);

    final data = {
      'type': transaction.type,
      'nominal': transaction.nominal,
      'description': transaction.description,
      'categoryId': transaction.categoryId,
      'categoryName': transaction.categoryName,
      'transactionDate': Timestamp.fromDate(transaction.transactionDate),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.update(data);
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  @override
  Future<void> deleteTransactionsByRange(String userId, String range) async {
    final uid = _resolveUserId(userId);
    final col = _firestore.collection('users').doc(uid).collection('transactions');

    Query<Map<String, dynamic>> query = col;
    final now = DateTime.now();

    if (range == 'this_month') {
      final startOfMonth = DateTime(now.year, now.month, 1);
      query = query.where('transactionDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth));
    } else if (range == 'this_year') {
      final startOfYear = DateTime(now.year, 1, 1);
      query = query.where('transactionDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear));
    }

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<int> getCurrentBalance(String userId) async {
    final txs = await getTransactions(userId);
    final inc = txs.where((t) => t.isIncome).fold<int>(0, (total, t) => total + t.nominal);
    final exp = txs.where((t) => t.isExpense).fold<int>(0, (total, t) => total + t.nominal);
    return inc - exp;
  }
}
