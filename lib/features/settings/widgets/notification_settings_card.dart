import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../providers/settings_provider.dart';

/// Kartu pengaturan pengingat harian pencatatan keuangan
class NotificationSettingsCard extends ConsumerStatefulWidget {
  const NotificationSettingsCard({super.key});

  @override
  ConsumerState<NotificationSettingsCard> createState() => _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends ConsumerState<NotificationSettingsCard> {
  bool _isActive = false;
  String _timeStr = '08:00';
  bool _isInit = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final s = ref.read(settingsProvider);
      _isActive = s.isReminderActive;
      _timeStr = s.reminderTime;
      _isInit = true;
    }
  }

  Future<void> _selectTime() async {
    AudioService().playClickSound();
    final parts = _timeStr.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 8,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: NeoColors.primaryBlue,
              onPrimary: NeoColors.white,
              surface: NeoColors.surfaceLight,
              onSurface: NeoColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final min = picked.minute.toString().padLeft(2, '0');
      setState(() => _timeStr = '$hour:$min');
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(settingsProvider.notifier).setReminder(
            isActive: _isActive,
            time: _timeStr,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan pengingat berhasil diperbarui!'),
            backgroundColor: NeoColors.successGreen,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(Icons.notifications_active, color: NeoColors.black, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'PENGINGAT HARIAN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'NOTIFIKASI CATAT PENGELUARAN',
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

          // Switch Aktifkan Pengingat
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
                const Text(
                  'STATUS PENGINGAT',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                ),
                Switch(
                  value: _isActive,
                  activeTrackColor: NeoColors.primaryBlueLight,
                  activeThumbColor: NeoColors.primaryBlue,
                  onChanged: (val) {
                    AudioService().playClickSound();
                    setState(() => _isActive = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Pemilih Jam Pengingat
          InkWell(
            onTap: _isActive ? _selectTime : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: _isActive ? NeoColors.white : Colors.grey.shade200,
                border: Border.all(color: NeoColors.black, width: 2),
                boxShadow: NeoColors.hardShadow(offset: _isActive ? 2 : 0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'WAKTU PENGINGAT (SETIAP HARI)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: NeoColors.black),
                      const SizedBox(width: 6),
                      Text(
                        _timeStr,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          NeoButton(
            text: _isLoading ? 'MENYIMPAN...' : 'SIMPAN PENGINGAT',
            backgroundColor: NeoColors.primaryBlue,
            textColor: NeoColors.white,
            onPressed: _isLoading ? null : _handleSave,
          ),
        ],
      ),
    );
  }
}
