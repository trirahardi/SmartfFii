import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../shared/widgets/blueprint_background.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/audio_settings_card.dart';
import '../widgets/balance_correction_card.dart';
import '../widgets/danger_zone_card.dart';
import '../widgets/notification_settings_card.dart';
import '../widgets/profile_settings_card.dart';
import '../widgets/savings_target_card.dart';
import '../widgets/subscription_info_card.dart';
import '../widgets/theme_settings_card.dart';

/// Layar Pengaturan & Preferensi SmartFi
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    AudioService().playClickSound();

    final confirm = await showDialog<bool>(
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
                  'KONFIRMASI KELUAR',
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
                      'Apakah Anda yakin ingin keluar dari akun SmartFi ini?',
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
                                'KELUAR',
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

    if (confirm == true) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlueprintBackground(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Pengaturan
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: NeoColors.white,
                  border: Border.all(color: NeoColors.black, width: 2),
                  boxShadow: NeoColors.hardShadow(offset: 3),
                ),
                child: const Icon(Icons.settings, size: 24, color: NeoColors.black),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'PENGATURAN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'KELOLA PROFIL, TARGET, DAN PREFERENSI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: NeoColors.textMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Profil Pengguna
          const ProfileSettingsCard(),
          const SizedBox(height: 16),

          // 2. Target Tabungan Bulanan
          const SavingsTargetCard(),
          const SizedBox(height: 16),

          // 3. Tema Tampilan (Light / Dark)
          const ThemeSettingsCard(),
          const SizedBox(height: 16),

          // 4. Efek Suara
          const AudioSettingsCard(),
          const SizedBox(height: 16),

          // 5. Pengingat Harian
          const NotificationSettingsCard(),
          const SizedBox(height: 16),

          // 6. Koreksi Saldo
          const BalanceCorrectionCard(),
          const SizedBox(height: 16),

          // 7. Status Langganan
          const SubscriptionInfoCard(),
          const SizedBox(height: 16),

          // 8. Zona Bahaya
          const DangerZoneCard(),
          const SizedBox(height: 24),

          // Tombol Navigasi Kelola Kategori
          NeoButton(
            text: 'KELOLA KATEGORI TRANSAKSI',
            icon: const Icon(Icons.category, size: 18, color: NeoColors.black),
            backgroundColor: NeoColors.white,
            textColor: NeoColors.black,
            onPressed: () {
              context.push('/categories');
            },
          ),
          const SizedBox(height: 12),

          // Tombol Logout
          NeoButton(
            text: 'KELUAR DARI AKUN',
            icon: const Icon(Icons.logout, size: 18, color: NeoColors.white),
            backgroundColor: NeoColors.dangerRed,
            textColor: NeoColors.white,
            onPressed: () => _handleLogout(context, ref),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
