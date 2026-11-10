import 'package:flutter/material.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/neo_card.dart';

/// Tabel rincian transaksi laporan keuangan
class ReportTable extends StatelessWidget {
  final List<TransactionModel> transactions;
  final int totalIncome;
  final int totalExpense;
  final int netBalance;

  const ReportTable({
    super.key,
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Kartu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: NeoColors.bgLight,
              border: Border(
                bottom: BorderSide(color: NeoColors.black, width: 3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DETAIL TRANSAKSI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NeoColors.white,
                    border: Border.all(color: NeoColors.black, width: 2),
                    boxShadow: NeoColors.hardShadow(offset: 2),
                  ),
                  child: Text(
                    '${transactions.length} TRANSAKSI',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: const [
                  Icon(Icons.inbox, size: 40, color: NeoColors.textDisabled),
                  SizedBox(height: 8),
                  Text(
                    'TIDAK ADA TRANSAKSI UNTUK FILTER TERSEBUT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: NeoColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 40,
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(NeoColors.white),
                  border: TableBorder(
                    horizontalInside: const BorderSide(color: NeoColors.black, width: 1.5),
                    bottom: const BorderSide(color: NeoColors.black, width: 2),
                  ),
                  columnSpacing: 14,
                  horizontalMargin: 12,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    color: NeoColors.black,
                  ),
                  columns: const [
                    DataColumn(label: Text('NO')),
                    DataColumn(label: Text('TANGGAL')),
                    DataColumn(label: Text('KATEGORI')),
                    DataColumn(label: Text('DESKRIPSI')),
                    DataColumn(label: Text('PEMASUKAN (RP)'), numeric: true),
                    DataColumn(label: Text('PENGELUARAN (RP)'), numeric: true),
                  ],
                  rows: [
                    ...transactions.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final tx = entry.value;
                      final isInc = tx.isIncome;

                      return DataRow(
                        cells: [
                          DataCell(Text(idx.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataCell(Text(DateFormatter.formatDate(tx.transactionDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: NeoColors.white,
                                border: Border.all(color: NeoColors.black, width: 1.5),
                              ),
                              child: Text(
                                tx.categoryName.toUpperCase(),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 140),
                              child: Text(
                                tx.description.isNotEmpty ? tx.description : '-',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              isInc ? CurrencyFormatter.formatRupiah(tx.nominal) : '-',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                color: isInc ? NeoColors.successGreen : NeoColors.black,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              !isInc ? CurrencyFormatter.formatRupiah(tx.nominal) : '-',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                color: !isInc ? NeoColors.dangerRed : NeoColors.black,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    // Baris TOTAL
                    DataRow(
                      color: WidgetStateProperty.all(Colors.grey.shade200),
                      cells: [
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                        const DataCell(
                          Text(
                            'TOTAL',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            CurrencyFormatter.formatRupiah(totalIncome),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: NeoColors.successGreen,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            CurrencyFormatter.formatRupiah(totalExpense),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: NeoColors.dangerRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Baris SALDO BERSIH
                    DataRow(
                      color: WidgetStateProperty.all(NeoColors.yellowAccent),
                      cells: [
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                        const DataCell(
                          Text(
                            'SALDO BERSIH',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ),
                        const DataCell(Text('')),
                        DataCell(
                          Text(
                            netBalance < 0
                                ? '-${CurrencyFormatter.formatRupiah(netBalance.abs())}'
                                : CurrencyFormatter.formatRupiah(netBalance),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: NeoColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

