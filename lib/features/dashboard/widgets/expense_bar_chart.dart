import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/neo_card.dart';

class ExpenseBarChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const ExpenseBarChart({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    // Siapkan data 7 hari terakhir
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final dailyExpenses = <int>[];
    for (final day in last7Days) {
      final dayExpense = transactions
          .where((t) => t.isExpense)
          .where((t) {
            final tDay = DateTime(t.transactionDate.year, t.transactionDate.month, t.transactionDate.day);
            return tDay.isAtSameMomentAs(day);
          })
          .fold<int>(0, (sum, t) => sum + t.nominal);
      dailyExpenses.add(dayExpense);
    }

    final maxVal = dailyExpenses.fold<int>(100000, (max, v) => v > max ? v : max);

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TREN PENGELUARAN 7 HARI TERAKHIR',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => NeoColors.surfaceLight,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final dayStr = DateFormatter.formatTanggalPendek(last7Days[group.x.toInt()]);
                      return BarTooltipItem(
                        '$dayStr\n${CurrencyFormatter.formatRupiah(rod.toY.toInt())}',
                        const TextStyle(
                          color: NeoColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (val, meta) {
                        if (val == 0) return const Text('0', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800));
                        final k = (val / 1000).toInt();
                        return Text('${k}k', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800));
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < last7Days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              DateFormatter.formatTanggalPendek(last7Days[idx]),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFE5E7EB), strokeWidth: 1),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: NeoColors.black, width: 2),
                    left: BorderSide(color: NeoColors.black, width: 2),
                  ),
                ),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: dailyExpenses[i].toDouble(),
                        color: NeoColors.primaryBlue,
                        width: 18,
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: NeoColors.black, width: 2),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

