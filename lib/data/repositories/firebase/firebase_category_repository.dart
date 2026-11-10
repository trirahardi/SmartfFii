import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/category_model.dart';
import '../category_repository.dart';

/// Implementasi Cloud Firestore untuk Penyimpanan Kategori Transaksi Pengguna
class FirebaseCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _resolveUserId(String passedUserId) {
    if (passedUserId.isNotEmpty && passedUserId != 'default_user') {
      return passedUserId;
    }
    return _auth.currentUser?.uid ?? 'anonymous_user';
  }

  @override
  Future<List<CategoryModel>> getCategories(String userId) async {
    final uid = _resolveUserId(userId);
    final col = _firestore.collection('users').doc(uid).collection('categories');
    final snapshot = await col.orderBy('createdAt', descending: false).get();

    if (snapshot.docs.isEmpty) {
      // Fallback jika belum ter-seed
      await seedDefaultCategories(uid);
      final refetched = await col.orderBy('createdAt', descending: false).get();
      return refetched.docs.map((doc) {
        final data = doc.data();
        return CategoryModel.fromJson({...data, 'id': doc.id});
      }).toList();
    }

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CategoryModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    final uid = _resolveUserId(category.userId);
    final col = _firestore.collection('users').doc(uid).collection('categories');
    final docRef = col.doc();

    final data = {
      'id': docRef.id,
      'userId': uid,
      'name': category.name,
      'type': category.type,
      'iconName': category.iconName,
      'colorHex': category.colorHex,
      'isDefault': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data);
    return category.copyWith(id: docRef.id, userId: uid);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final uid = _resolveUserId(category.userId);
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .doc(category.id);

    final data = {
      'name': category.name,
      'type': category.type,
      'iconName': category.iconName,
      'colorHex': category.colorHex,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.update(data);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  Future<void> seedDefaultCategories(String userId) async {
    final col = _firestore.collection('users').doc(userId).collection('categories');
    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) return; // Mencegah duplikasi

    final batch = _firestore.batch();
    for (final defCat in CategoryModel.defaultCategories) {
      final docRef = col.doc();
      final data = {
        'id': docRef.id,
        'userId': userId,
        'name': defCat.name,
        'type': defCat.type,
        'iconName': defCat.iconName,
        'colorHex': defCat.colorHex,
        'isDefault': true,
        'createdAt': FieldValue.serverTimestamp(),
      };
      batch.set(docRef, data);
    }
    await batch.commit();
  }
}
