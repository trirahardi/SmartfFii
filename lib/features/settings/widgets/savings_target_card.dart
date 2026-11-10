import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_input.dart';
import '../providers/settings_provider.dart';

/// Kartu pengaturan target tabungan bulanan
class SavingsTargetCard extends ConsumerStatefulWidget {
  const SavingsTargetCard({super.key});

  @override
  ConsumerState<SavingsTargetCard> createState() => _SavingsTargetCardState();
}

class _SavingsTargetCardState extends ConsumerState<SavingsTargetCard> {
  final TextEditingController _targetController = TextEditingController();
  int _rawTarget = 0;
  bool _isLoading = false;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final settings = ref.read(settingsProvider);
      _rawTarget = settings.savingsTarget;
      _targetController.text = CurrencyFormatter.formatRupiah(_rawTarget);
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _onTargetChanged(String val) {
    final clean = val.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) {
      _rawTarget = 0;
      _targetController.value = const TextEditingValue(text: '');
      return;
    }
    final parsed = int.tryParse(clean) ?? 0;
    _rawTarget = parsed;
    final formatted = CurrencyFormatter.formatRupiah(parsed);
    _targetController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(settingsProvider.notifier).setSavingsTarget(_rawTarget);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Target tabungan berhasil diperbarui!'),
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
                  color: NeoColors.yellowAccent,
                  border: Border.all(color: NeoColors.black, width: 2),
                  boxShadow: NeoColors.hardShadow(offset: 2),
                ),
                child: const Icon(Icons.track_changes, color: NeoColors.black, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'TARGET TABUNGAN BULANAN',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'DIGUNAKAN UNTUK INDIKATOR DASHBOARD',
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
          NeoInput(
            label: 'TARGET NOMINAL (RP)',
            controller: _targetController,
            hintText: 'Contoh: 5.000.000',
            keyboardType: TextInputType.number,
            onChanged: _onTargetChanged,
          ),
          const SizedBox(height: 16),
          NeoButton(
            text: _isLoading ? 'MENYIMPAN...' : 'SIMPAN TARGET',
            backgroundColor: NeoColors.yellowAccent,
            textColor: NeoColors.black,
            onPressed: _isLoading ? null : _handleSave,
          ),
        ],
      ),
    );
  }
}

