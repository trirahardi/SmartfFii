import 'package:flutter/material.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/neo_card.dart';

/// 3 Kartu Ringkasan Keuangan Laporan (Pemasukan, Pengeluaran, Saldo Akhir)
class ReportSummaryCards extends StatelessWidget {
  final int totalIncome;
  final int totalExpense;
  final int netBalance;

  const ReportSummaryCards({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Total Pemasukan
        NeoCard(
          backgroundColor: NeoColors.successGreenLight,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL PEMASUKAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: NeoColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatRupiah(totalIncome),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: NeoColors.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NeoColors.white,
                  border: Border.all(color: NeoColors.black, width: 2),
                  boxShadow: NeoColors.hardShadow(offset: 2),
                ),
                child: const Icon(Icons.arrow_downward, color: NeoColors.black, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Total Pengeluaran
        NeoCard(
          backgroundColor: NeoColors.dangerRedLight,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL PENGELUARAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: NeoColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatRupiah(totalExpense),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: NeoColors.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NeoColors.white,
                  border: Border.all(color: NeoColors.black, width: 2),
                  boxShadow: NeoColors.hardShadow(offset: 2),
                ),
                child: const Icon(Icons.arrow_upward, color: NeoColors.black, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Saldo Akhir
        NeoCard(
          backgroundColor: NeoColors.primaryBlueLight,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SALDO AKHIR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: NeoColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatRupiah(netBalance),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: NeoColors.textDark,
                    ),
                  ),
                ],
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NeoColors.white,
                  border: Border.all(color: NeoColors.black, width: 2),
                  boxShadow: NeoColors.hardShadow(offset: 2),
                ),
                child: const Icon(Icons.account_balance_wallet, color: NeoColors.black, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

