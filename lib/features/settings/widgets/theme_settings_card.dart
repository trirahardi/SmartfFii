import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../shared/widgets/neo_card.dart';
import '../providers/settings_provider.dart';

/// Kartu preferensi tampilan tema (Light / Dark)
class ThemeSettingsCard extends ConsumerWidget {
  const ThemeSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = settings.themeMode == 'dark';

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
                child: const Icon(Icons.palette, color: NeoColors.black, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'TEMA TAMPILAN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'SESUAIKAN DENGAN KENYAMANAN MATA',
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
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    AudioService().playClickSound();
                    ref.read(settingsProvider.notifier).setThemeMode('light');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: !isDark ? NeoColors.yellowAccent : NeoColors.white,
                      border: Border.all(color: NeoColors.black, width: 2),
                      boxShadow: NeoColors.hardShadow(offset: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          !isDark ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                          size: 18,
                          color: NeoColors.black,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'TERANG',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () {
                    AudioService().playClickSound();
                    ref.read(settingsProvider.notifier).setThemeMode('dark');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? NeoColors.yellowAccent : NeoColors.white,
                      border: Border.all(color: NeoColors.black, width: 2),
                      boxShadow: NeoColors.hardShadow(offset: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isDark ? Icons.nightlight_round : Icons.nightlight_round_outlined,
                          size: 18,
                          color: NeoColors.black,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'GELAP',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

