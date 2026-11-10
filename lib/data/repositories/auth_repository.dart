import '../models/user_model.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();
  Stream<AppUser?> authStateChanges();
  Future<AppUser> signInWithEmailPassword(String email, String password);
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signUp(String name, String email, String password);
  Future<void> updateProfile({
    String? name,
    int? targetSavings,
    bool? reminderEnabled,
    String? reminderTime,
  });
  Future<void> signOut();
}

