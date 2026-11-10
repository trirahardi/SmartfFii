import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/audio_service.dart';

class SettingsState {
  final int savingsTarget;
  final String themeMode; // 'light' | 'dark'
  final bool isClickMuted;
  final bool isAiMuted;
  final bool isReminderActive;
  final String reminderTime;

  const SettingsState({
    this.savingsTarget = 5000000,
    this.themeMode = 'light',
    this.isClickMuted = false,
    this.isAiMuted = false,
    this.isReminderActive = false,
    this.reminderTime = '08:00',
  });

  SettingsState copyWith({
    int? savingsTarget,
    String? themeMode,
    bool? isClickMuted,
    bool? isAiMuted,
    bool? isReminderActive,
    String? reminderTime,
  }) {
    return SettingsState(
      savingsTarget: savingsTarget ?? this.savingsTarget,
      themeMode: themeMode ?? this.themeMode,
      isClickMuted: isClickMuted ?? this.isClickMuted,
      isAiMuted: isAiMuted ?? this.isAiMuted,
      isReminderActive: isReminderActive ?? this.isReminderActive,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final target = prefs.getInt('smartfi_savings_target') ?? 5000000;
      final theme = prefs.getString('smartfi_theme_mode') ?? 'light';
      final clickMuted = prefs.getBool('smartfi_mute_click') ?? false;
      final aiMuted = prefs.getBool('smartfi_mute_ai') ?? false;
      final reminderActive = prefs.getBool('smartfi_reminder_active') ?? false;
      final reminderTime = prefs.getString('smartfi_reminder_time') ?? '08:00';

      state = SettingsState(
        savingsTarget: target,
        themeMode: theme,
        isClickMuted: clickMuted,
        isAiMuted: aiMuted,
        isReminderActive: reminderActive,
        reminderTime: reminderTime,
      );
    } catch (_) {}
  }

  Future<void> setSavingsTarget(int target) async {
    state = state.copyWith(savingsTarget: target);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('smartfi_savings_target', target);
  }

  Future<void> setThemeMode(String mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('smartfi_theme_mode', mode);
  }

  Future<void> toggleClickMute() async {
    final newVal = !state.isClickMuted;
    state = state.copyWith(isClickMuted: newVal);
    await AudioService().setClickMuted(newVal);
  }

  Future<void> toggleAiMute() async {
    final newVal = !state.isAiMuted;
    state = state.copyWith(isAiMuted: newVal);
    await AudioService().setAiMuted(newVal);
  }

  Future<void> setReminder({required bool isActive, required String time}) async {
    state = state.copyWith(isReminderActive: isActive, reminderTime: time);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('smartfi_reminder_active', isActive);
    await prefs.setString('smartfi_reminder_time', time);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

