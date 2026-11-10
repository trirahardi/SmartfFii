import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/date_formatter.dart';
import '../models/transaction_model.dart';

/// Layanan ekspor laporan keuangan ke berkas format CSV / Spreadsheet Excel
class CsvExportService {
  CsvExportService._();

  static Future<void> exportCsv({
    required List<TransactionModel> transactions,
    required int totalIncome,
    required int totalExpense,
    required int netBalance,
  }) async {
    final headers = ['No', 'Tanggal', 'Kategori', 'Deskripsi', 'Pemasukan (Rp)', 'Pengeluaran (Rp)'];

    final rows = <String>[];
    rows.add(headers.join(','));

    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final inc = tx.isIncome ? tx.nominal : 0;
      final exp = tx.isExpense ? tx.nominal : 0;
      final date = DateFormatter.formatDate(tx.transactionDate);
      final cat = '"${tx.categoryName.replaceAll('"', '""')}"';
      final desc = '"${tx.description.replaceAll('"', '""')}"';

      rows.add([
        (i + 1).toString(),
        date,
        cat,
        desc,
        inc.toString(),
        exp.toString(),
      ].join(','));
    }

    // Baris TOTAL
    rows.add(['', '', '', 'TOTAL', totalIncome.toString(), totalExpense.toString()].join(','));

    // Baris SALDO BERSIH
    rows.add(['', '', '', 'SALDO BERSIH', '', netBalance.toString()].join(','));

    final csvContent = rows.join('\n');

    // Simpan ke direktori cache / dokumen
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/laporan_keuangan_smartfi.csv');
    await file.writeAsString(csvContent);

    // Bagikan file menggunakan share_plus
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      text: 'Laporan Keuangan SmartFi',
      subject: 'Laporan Keuangan SmartFi',
    );
  }
}

