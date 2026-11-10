import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormat = NumberFormat.decimalPattern('id_ID');

  /// Format angka integer ke string Rupiah: misal 25000 -> "Rp 25.000"
  static String formatRupiah(num? amount) {
    if (amount == null) return 'Rp 0';
    return _rupiahFormat.format(amount);
  }

  /// Format angka integer ke string angka berpemisah ribuan: misal 25000 -> "25.000"
  static String formatNumber(num? amount) {
    if (amount == null) return '0';
    return _numberFormat.format(amount);
  }

  /// Parse string angka atau input berpemisah ribuan ke integer bersih
  static int parseCleanInt(String value) {
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }
}

