import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/category_model.dart';
import '../../models/user_model.dart';
import '../auth_repository.dart';

/// Implementasi Firebase Authentication & Manajemen Pengguna Aktif
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseAuthRepository();

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _getOrFetchUserProfile(firebaseUser);
    });
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _getOrFetchUserProfile(firebaseUser);
  }

  Future<AppUser> _getOrFetchUserProfile(User firebaseUser) async {
    final userDocRef = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await userDocRef.get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data()!;
      return AppUser.fromJson({
        ...data,
        'id': firebaseUser.uid,
        'email': firebaseUser.email ?? data['email'] ?? '',
        'name': data['name'] ?? firebaseUser.displayName ?? 'Pengguna SmartFi',
      });
    }

    // Jika belum ada profil di Firestore, buat profil baru + kategori bawaan
    return _initializeNewUser(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Pengguna SmartFi',
      email: firebaseUser.email ?? '',
      avatarUrl: firebaseUser.photoURL,
    );
  }

  /// Membuat profil pengguna dan kategori bawaan dalam satu batched write
  Future<AppUser> _initializeNewUser({
    required String uid,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final userDocRef = _firestore.collection('users').doc(uid);
    final batch = _firestore.batch();

    final userData = {
      'id': uid,
      'name': name,
      'email': email,
      'targetSavings': 5000000,
      'reminderEnabled': false,
      'reminderTime': '08:00',
      'reminderTimezone': 'Asia/Jakarta',
      'avatarUrl': avatarUrl,
      'isTrial': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // 1. Buat dokumen user
    batch.set(userDocRef, userData);

    // 2. Buat kategori default dalam batch yang sama
    final categoriesCol = userDocRef.collection('categories');
    for (final defCat in CategoryModel.defaultCategories) {
      final catDoc = categoriesCol.doc();
      batch.set(catDoc, {
        'id': catDoc.id,
        'userId': uid,
        'name': defCat.name,
        'type': defCat.type,
        'iconName': defCat.iconName,
        'colorHex': defCat.colorHex,
        'isDefault': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    return AppUser(
      id: uid,
      name: name,
      email: email,
      targetSavings: 5000000,
      reminderEnabled: false,
      reminderTime: '08:00',
      reminderTimezone: 'Asia/Jakarta',
      avatarUrl: avatarUrl,
      isTrial: false,
    );
  }

  @override
  Future<AppUser> signInWithEmailPassword(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    return _getOrFetchUserProfile(user);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Proses masuk dengan Google dibatalkan pengguna.');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;
    return _getOrFetchUserProfile(user);
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);

    return _initializeNewUser(
      uid: user.uid,
      name: name,
      email: email.trim(),
    );
  }

  @override
  Future<void> updateProfile({
    String? name,
    int? targetSavings,
    bool? reminderEnabled,
    String? reminderTime,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null && name.trim().isNotEmpty) {
      await user.updateDisplayName(name.trim());
      updates['name'] = name.trim();
    }
    if (targetSavings != null) {
      updates['targetSavings'] = targetSavings;
    }
    if (reminderEnabled != null) {
      updates['reminderEnabled'] = reminderEnabled;
    }
    if (reminderTime != null) {
      updates['reminderTime'] = reminderTime;
    }

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
