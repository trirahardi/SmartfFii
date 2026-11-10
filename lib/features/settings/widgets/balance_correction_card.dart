import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_input.dart';
import '../../transactions/providers/transaction_provider.dart';

/// Kartu koreksi saldo aktual manual
class BalanceCorrectionCard extends ConsumerStatefulWidget {
  const BalanceCorrectionCard({super.key});

  @override
  ConsumerState<BalanceCorrectionCard> createState() => _BalanceCorrectionCardState();
}

class _BalanceCorrectionCardState extends ConsumerState<BalanceCorrectionCard> {
  final TextEditingController _balanceController = TextEditingController();
  int _rawInput = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  void _onBalanceChanged(String val) {
    final clean = val.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) {
      _rawInput = 0;
      _balanceController.value = const TextEditingValue(text: '');
      return;
    }
    final parsed = int.tryParse(clean) ?? 0;
    _rawInput = parsed;
    final formatted = CurrencyFormatter.formatRupiah(parsed);
    _balanceController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _handleCorrectBalance(int currentBalance) async {
    final diff = _rawInput - currentBalance;
    if (diff == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo sudah sesuai dengan data saat ini.'),
          backgroundColor: NeoColors.warningYellow,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final isInc = diff > 0;
      final tx = TransactionModel(
        id: 'tx_adj_${now.millisecondsSinceEpoch}',
        userId: 'default_user',
        type: isInc ? 'income' : 'expense',
        nominal: diff.abs(),
        categoryName: 'Penyesuaian Saldo',
        description: 'Koreksi saldo manual via Pengaturan',
        transactionDate: now,
        createdAt: now,
      );

      await ref.read(transactionsProvider.notifier).addTransaction(tx);
      _balanceController.clear();
      _rawInput = 0;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saldo berhasil dikoreksi!'),
            backgroundColor: NeoColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengoreksi saldo: $e'),
            backgroundColor: NeoColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final txs = transactionsAsync.asData?.value ?? [];

    final inc = txs.where((t) => t.isIncome).fold<int>(0, (sum, t) => sum + t.nominal);
    final exp = txs.where((t) => t.isExpense).fold<int>(0, (sum, t) => sum + t.nominal);
    final currentBalance = inc - exp;

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
                child: const Icon(Icons.account_balance_wallet, color: NeoColors.black, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'KOREKSI SALDO AKTUAL',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'SESUAIKAN DENGAN SALDO REKENING RIIL',
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

          // Tampilan Saldo Tersimpan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NeoColors.bgLight,
              border: Border.all(color: NeoColors.black, width: 2),
              boxShadow: NeoColors.hardShadow(offset: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SALDO TERSIMPAN SAAT INI',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                ),
                Text(
                  CurrencyFormatter.formatRupiah(currentBalance),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          NeoInput(
            label: 'SALDO RIIL BARU (RP)',
            controller: _balanceController,
            hintText: 'Masukkan saldo sebenarnya',
            keyboardType: TextInputType.number,
            onChanged: _onBalanceChanged,
          ),
          const SizedBox(height: 16),

          NeoButton(
            text: _isLoading ? 'MENYESUAIKAN...' : 'KOREKSI SALDO',
            backgroundColor: NeoColors.primaryBlue,
            textColor: NeoColors.white,
            onPressed: _isLoading || _balanceController.text.isEmpty
                ? null
                : () => _handleCorrectBalance(currentBalance),
          ),
        ],
      ),
    );
  }
}

