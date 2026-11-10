import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../auth_repository.dart';

class DummyAuthRepository implements AuthRepository {
  static const String _userStorageKey = 'smartfi_auth_user';
  final StreamController<AppUser?> _authStateController = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  DummyAuthRepository() {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonStr = prefs.getString(_userStorageKey);
      if (userJsonStr != null) {
        final Map<String, dynamic> data = jsonDecode(userJsonStr);
        _currentUser = AppUser.fromJson(data);
      } else {
        _currentUser = null;
      }
    } catch (_) {
      _currentUser = null;
    }
    _authStateController.add(_currentUser);
  }

  Future<void> _saveUser(AppUser? user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString(_userStorageKey, jsonEncode(user.toJson()));
    } else {
      await prefs.remove(_userStorageKey);
    }
    _authStateController.add(_currentUser);
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final prefs = await SharedPreferences.getInstance();
    final userJsonStr = prefs.getString(_userStorageKey);
    if (userJsonStr != null) {
      try {
        _currentUser = AppUser.fromJson(jsonDecode(userJsonStr));
        return _currentUser;
      } catch (_) {}
    }
    return null;
  }

  @override
  Stream<AppUser?> authStateChanges() => _authStateController.stream;

  @override
  Future<AppUser> signInWithEmailPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email dan kata sandi wajib diisi.');
    }

    if (password.length < 6) {
      throw Exception('Kata sandi salah. Minimal 6 karakter.');
    }

    // Ekstrak nama panggilan dari email
    final namePart = email.split('@').first;
    final displayName = namePart.isNotEmpty
        ? namePart[0].toUpperCase() + namePart.substring(1)
        : 'Pengguna SmartFi';

    final user = AppUser(
      id: 'usr_${email.hashCode.abs()}',
      name: displayName,
      email: email.trim(),
      targetSavings: 5000000, // Default target 5 juta
      reminderEnabled: false,
      reminderTime: '20:00',
    );

    await _saveUser(user);
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 700));

    const user = AppUser(
      id: 'usr_google_default',
      name: 'Tri Rahardi Wijaya',
      email: 'tri.wijaya@gmail.com',
      targetSavings: 5000000,
      reminderEnabled: true,
      reminderTime: '20:00',
      avatarUrl: null,
    );

    await _saveUser(user);
    return user;
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Semua kolom pendaftaran wajib diisi.');
    }

    if (password.length < 6) {
      throw Exception('Kata sandi minimal 6 karakter.');
    }

    final user = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Pengguna Baru' : name.trim(),
      email: email.trim(),
      targetSavings: 5000000,
      reminderEnabled: false,
      reminderTime: '20:00',
    );

    await _saveUser(user);
    return user;
  }

  @override
  Future<void> updateProfile({
    String? name,
    int? targetSavings,
    bool? reminderEnabled,
    String? reminderTime,
  }) async {
    final current = await getCurrentUser();
    if (current == null) return;

    final updated = current.copyWith(
      name: name ?? current.name,
      targetSavings: targetSavings ?? current.targetSavings,
      reminderEnabled: reminderEnabled ?? current.reminderEnabled,
      reminderTime: reminderTime ?? current.reminderTime,
    );

    await _saveUser(updated);
  }

  @override
  Future<void> signOut() async {
    await _saveUser(null);
  }
}

