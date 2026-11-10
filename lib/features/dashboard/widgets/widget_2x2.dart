import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/neo_card.dart';

class Widget2x2 extends StatelessWidget {
  final int balance;
  final int incomeThisMonth;
  final int expenseThisMonth;
  final int targetSavings;
  final List<TransactionModel> transactionsThisMonth;

  const Widget2x2({
    super.key,
    required this.balance,
    required this.incomeThisMonth,
    required this.expenseThisMonth,
    required this.targetSavings,
    required this.transactionsThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Progress Tabungan terhadap Target
    final target = targetSavings > 0 ? targetSavings : 5000000;
    double savingsProgress = balance > 0 ? (balance / target) : 0.0;
    if (savingsProgress > 1.0) savingsProgress = 1.0;
    final savingsPercent = (savingsProgress * 100).toInt();

    // 2. Kategori Pengeluaran Terbesar
    final catTotals = <String, int>{};
    for (final t in transactionsThisMonth.where((t) => t.isExpense)) {
      catTotals[t.categoryName] = (catTotals[t.categoryName] ?? 0) + t.nominal;
    }
    String topCatName = 'Belum Ada';
    int topCatAmount = 0;
    catTotals.forEach((cat, amt) {
      if (amt > topCatAmount) {
        topCatAmount = amt;
        topCatName = cat;
      }
    });
    final topCatPercent = expenseThisMonth > 0 ? ((topCatAmount / expenseThisMonth) * 100).toInt() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STATISTIK 2X2 (BULAN INI)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: [
            // Widget 1: Saldo
            _buildDoughnutTile(
              title: 'SALDO',
              valueText: CurrencyFormatter.formatRupiah(balance),
              subtext: '$savingsPercent% dari target',
              color: NeoColors.primaryBlue,
              progress: savingsProgress,
            ),

            // Widget 2: Pemasukan
            _buildDoughnutTile(
              title: 'PEMASUKAN',
              valueText: CurrencyFormatter.formatRupiah(incomeThisMonth),
              subtext: 'Bulan ini',
              color: NeoColors.successGreen,
              progress: 1.0,
            ),

            // Widget 3: Pengeluaran
            _buildDoughnutTile(
              title: 'PENGELUARAN',
              valueText: CurrencyFormatter.formatRupiah(expenseThisMonth),
              subtext: expenseThisMonth > target ? 'Melebihi target' : 'Arus kas keluar',
              color: expenseThisMonth > target ? NeoColors.warningYellow : NeoColors.dangerRed,
              progress: expenseThisMonth > 0 ? 0.75 : 0.0,
            ),

            // Widget 4: Kategori Terbesar
            _buildDoughnutTile(
              title: 'TERBANYAK',
              valueText: topCatName,
              subtext: '$topCatPercent% pengeluaran',
              color: NeoColors.purpleAccent,
              progress: topCatPercent / 100.0,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoughnutTile({
    required String title,
    required String valueText,
    required String subtext,
    required Color color,
    required double progress,
  }) {
    final validProgress = progress.clamp(0.0, 1.0);

    return NeoCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: NeoColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: 270,
                    sectionsSpace: 0,
                    centerSpaceRadius: 24,
                    sections: [
                      PieChartSectionData(
                        value: validProgress > 0 ? validProgress : 0.01,
                        color: color,
                        radius: 10,
                        showTitle: false,
                        borderSide: const BorderSide(color: NeoColors.black, width: 1.5),
                      ),
                      PieChartSectionData(
                        value: (1.0 - validProgress) > 0 ? (1.0 - validProgress) : 0.0,
                        color: NeoColors.bgLight,
                        radius: 10,
                        showTitle: false,
                        borderSide: const BorderSide(color: NeoColors.black, width: 1.5),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: NeoColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${(validProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: NeoColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valueText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: NeoColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: NeoColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

