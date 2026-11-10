import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../shared/widgets/neo_card.dart';
import '../providers/settings_provider.dart';

/// Kartu pengaturan efek suara (Mute Click & Mute AI)
class AudioSettingsCard extends ConsumerWidget {
  const AudioSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: NeoColors.bgLight,
                  border: Border.all(color: NeoColors.black, width: 2),
                  boxShadow: NeoColors.hardShadow(offset: 2),
                ),
                child: const Icon(
                  Icons.volume_up,
                  color: NeoColors.black,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'KONTROL EFEK SUARA',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'ATUR SUARA KLIK DAN OBROLAN AI',
                    style: TextStyle(
                      fontSize: 9,
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

          // Switch Mute Click
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: NeoColors.white,
              border: Border.all(color: NeoColors.black, width: 2),
              boxShadow: NeoColors.hardShadow(offset: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'BISUKAN SUARA KLIK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Menonaktifkan suara saat menekan tombol',
                      style: TextStyle(fontSize: 9, color: NeoColors.textMuted),
                    ),
                  ],
                ),
                Switch(
                  value: settings.isClickMuted,
                  activeTrackColor: NeoColors.primaryBlueLight,
                  activeThumbColor: NeoColors.primaryBlue,
                  onChanged: (_) {
                    AudioService().playClickSound();
                    ref.read(settingsProvider.notifier).toggleClickMute();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Switch Mute AI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: NeoColors.white,
              border: Border.all(color: NeoColors.black, width: 2),
              boxShadow: NeoColors.hardShadow(offset: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'BISUKAN SUARA CHAT AI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Menonaktifkan bunyi saat pesan AI tiba',
                      style: TextStyle(fontSize: 9, color: NeoColors.textMuted),
                    ),
                  ],
                ),
                Switch(
                  value: settings.isAiMuted,
                  activeTrackColor: NeoColors.primaryBlueLight,
                  activeThumbColor: NeoColors.primaryBlue,
                  onChanged: (_) {
                    AudioService().playClickSound();
                    ref.read(settingsProvider.notifier).toggleAiMute();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
