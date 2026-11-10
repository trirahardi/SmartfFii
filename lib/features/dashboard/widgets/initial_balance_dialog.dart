import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_input.dart';
import '../../transactions/providers/transaction_provider.dart';

/// Modal onboarding untuk mengisi saldo awal (minimal Rp 100.000)
class InitialBalanceDialog extends ConsumerStatefulWidget {
  const InitialBalanceDialog({super.key});

  static Future<void> show(BuildContext context) {
    AudioService().playClickSound();
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x99000000),
      builder: (_) => const InitialBalanceDialog(),
    );
  }

  @override
  ConsumerState<InitialBalanceDialog> createState() =>
      _InitialBalanceDialogState();
}

class _InitialBalanceDialogState extends ConsumerState<InitialBalanceDialog> {
  final TextEditingController _controller = TextEditingController();
  int _rawValue = 0;
  bool _isLoading = false;
  String? _errorMessage;

  void _onAmountChanged(String value) {
    final clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) {
      _rawValue = 0;
      _controller.value = const TextEditingValue(text: '');
      setState(() => _errorMessage = null);
      return;
    }

    final parsed = int.tryParse(clean) ?? 0;
    _rawValue = parsed;
    final formatted = CurrencyFormatter.formatRupiah(parsed);

    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    setState(() {
      if (_rawValue < 100000) {
        _errorMessage = 'Minimal pengisian saldo awal adalah Rp 100.000';
      } else {
        _errorMessage = null;
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (_rawValue < 100000) {
      setState(() {
        _errorMessage = 'Masukkan saldo awal minimal Rp 100.000.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final tx = TransactionModel(
        id: 'tx_init_${now.millisecondsSinceEpoch}',
        userId: 'default_user',
        type: 'income',
        nominal: _rawValue,
        categoryName: 'Saldo Awal',
        description: 'Setup Saldo Awal',
        transactionDate: now,
        createdAt: now,
      );

      await ref.read(transactionsProvider.notifier).addTransaction(tx);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal menyimpan saldo awal: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _rawValue >= 100000;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          decoration: BoxDecoration(
            color: NeoColors.surfaceLight,
            border: Border.all(color: NeoColors.black, width: 4),
            boxShadow: NeoColors.hardShadow(offset: 8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: NeoColors.bgLight,
                  border: Border(
                    bottom: BorderSide(color: NeoColors.black, width: 4),
                  ),
                ),
                child: const Text(
                  'SALDO AWAL',
                  style: TextStyle(
                    color: NeoColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // Konten Modal
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: NeoColors.black, width: 2),
                          color: NeoColors.white,
                          boxShadow: NeoColors.hardShadow(offset: 4),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const Text(
                      'SELAMAT DATANG DI SMARTFI!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Mari mulai dengan mengatur saldo awal Anda agar kami bisa melacak keuangan Anda dengan akurat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: NeoColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    NeoInput(
                      label: 'Saldo Awal (Rp)',
                      controller: _controller,
                      hintText: 'Contoh: 100.000',
                      keyboardType: TextInputType.number,
                      errorText: _errorMessage,
                      onChanged: _onAmountChanged,
                    ),
                    const SizedBox(height: 20),
                    NeoButton(
                      text: _isLoading
                          ? 'MENYIMPAN...'
                          : 'MULAI GUNAKAN SMARTFI',
                      backgroundColor: isValid
                          ? NeoColors.primaryBlue
                          : Colors.grey.shade400,
                      textColor: NeoColors.white,
                      onPressed: isValid && !_isLoading ? _handleSubmit : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
