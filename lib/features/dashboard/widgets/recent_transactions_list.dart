import 'package:flutter/material.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_card.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final recent5 = transactions.take(5).toList();

    return NeoCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Neobrutalism
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: NeoColors.bgLight,
              border: Border(bottom: BorderSide(color: NeoColors.black, width: 4)),
            ),
            child: const Text(
              'RIWAYAT TRANSAKSI TERAKHIR',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),

          if (recent5.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Belum ada transaksi yang dicatat.',
                  style: TextStyle(fontWeight: FontWeight.w800, color: NeoColors.textMuted),
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent5.length,
              separatorBuilder: (_, __) => const Divider(color: NeoColors.black, height: 2, thickness: 2),
              itemBuilder: (context, index) {
                final tx = recent5[index];
                final isIncome = tx.isIncome;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Tanggal & Kategori
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormatter.formatTanggalPendek(tx.transactionDate),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          NeoBadge(
                            text: tx.categoryName,
                            fontSize: 9,
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Deskripsi
                      Expanded(
                        child: Text(
                          tx.description,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Nominal
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isIncome ? '+' : '-'} ${CurrencyFormatter.formatRupiah(tx.nominal)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: isIncome ? NeoColors.successGreen : NeoColors.dangerRed,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const NeoBadge(
                            text: 'Selesai',
                            backgroundColor: NeoColors.successGreenLight,
                            icon: Icon(Icons.check_circle, size: 10, color: NeoColors.black),
                            fontSize: 8,
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

