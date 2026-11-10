import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/neo_card.dart';

class TransactionMonthlySummary extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionMonthlySummary({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Filter transaksi bulan berjalan
    final currentMonthTxs = transactions.where((tx) {
      return tx.transactionDate.month == now.month &&
          tx.transactionDate.year == now.year;
    }).toList();

    final pemasukanBulanIni = currentMonthTxs
        .where((t) => t.isIncome)
        .fold<int>(0, (sum, t) => sum + t.nominal);

    final pengeluaranBulanIni = currentMonthTxs
        .where((t) => t.isExpense)
        .fold<int>(0, (sum, t) => sum + t.nominal);

    // Total keseluruhan untuk saldo terkini
    final totalPemasukanAll = transactions
        .where((t) => t.isIncome)
        .fold<int>(0, (sum, t) => sum + t.nominal);

    final totalPengeluaranAll = transactions
        .where((t) => t.isExpense)
        .fold<int>(0, (sum, t) => sum + t.nominal);

    final saldoTerkini = totalPemasukanAll - totalPengeluaranAll;

    final maxY = [
      pemasukanBulanIni.toDouble(),
      pengeluaranBulanIni.toDouble(),
      100000.0,
    ].reduce((a, b) => a > b ? a : b);

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SALDO TERKINI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: NeoColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatRupiah(saldoTerkini),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: NeoColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),

          // Bar Chart Mini Komparasi
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.15,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => NeoColors.surfaceLight,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = rodIndex == 0 ? 'Pemasukan' : 'Pengeluaran';
                      return BarTooltipItem(
                        '$label\n${CurrencyFormatter.formatRupiah(rod.toY.toInt())}',
                        const TextStyle(
                          color: NeoColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            'BULAN INI',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.textDark,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: NeoColors.black, width: 2),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barsSpace: 12,
                    barRods: [
                      BarChartRodData(
                        toY: pemasukanBulanIni.toDouble(),
                        color: NeoColors.successGreenLight,
                        width: 28,
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: NeoColors.black, width: 2),
                      ),
                      BarChartRodData(
                        toY: pengeluaranBulanIni.toDouble(),
                        color: NeoColors.dangerRedLight,
                        width: 28,
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: NeoColors.black, width: 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Banner Total Pemasukan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NeoColors.successGreenLight,
              border: Border.all(color: NeoColors.black, width: 2),
              boxShadow: NeoColors.hardShadow(offset: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceLight,
                        border: Border.all(color: NeoColors.black, width: 2),
                      ),
                      child: const Icon(Icons.arrow_downward, size: 16, color: NeoColors.black),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'TOTAL PEMASUKAN',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormatter.formatRupiah(pemasukanBulanIni),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Banner Total Pengeluaran
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NeoColors.dangerRedLight,
              border: Border.all(color: NeoColors.black, width: 2),
              boxShadow: NeoColors.hardShadow(offset: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceLight,
                        border: Border.all(color: NeoColors.black, width: 2),
                      ),
                      child: const Icon(Icons.arrow_upward, size: 16, color: NeoColors.black),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'TOTAL PENGELUARAN',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormatter.formatRupiah(pengeluaranBulanIni),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

