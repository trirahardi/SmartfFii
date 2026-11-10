import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/neo_card.dart';

class CategoryPieChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  static const List<Color> _palette = [
    Color(0xFF3B82F6), // Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF64748B), // Slate
  ];

  const CategoryPieChart({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final expenseTxs = transactions.where((t) => t.isExpense).toList();
    final catTotals = <String, int>{};

    for (final tx in expenseTxs) {
      catTotals[tx.categoryName] = (catTotals[tx.categoryName] ?? 0) + tx.nominal;
    }

    final sortedEntries = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalExpense = sortedEntries.fold<int>(0, (sum, e) => sum + e.value);

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERSENTASE PENGELUARAN PER KATEGORI',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          if (sortedEntries.isEmpty) ...[
            Container(
              height: 160,
              alignment: Alignment.center,
              child: const Text(
                'Belum ada data pengeluaran',
                style: TextStyle(fontWeight: FontWeight.w800, color: NeoColors.textMuted),
              ),
            ),
          ] else ...[
            Row(
              children: [
                // Doughnut Pie
                SizedBox(
                  width: 130,
                  height: 130,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 32,
                      sectionsSpace: 2,
                      sections: sortedEntries.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final color = _palette[idx % _palette.length];

                        return PieChartSectionData(
                          value: item.value.toDouble(),
                          color: color,
                          radius: 28,
                          showTitle: false,
                          borderSide: const BorderSide(color: NeoColors.black, width: 2),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Legend List
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: sortedEntries.take(4).toList().asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final color = _palette[idx % _palette.length];
                      final percent = totalExpense > 0 ? ((item.value / totalExpense) * 100).toInt() : 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                border: Border.all(color: NeoColors.black, width: 1.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.key,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$percent%',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
