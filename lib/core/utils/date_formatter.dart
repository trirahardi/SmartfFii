import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Format tanggal Indonesia: misal 2026-11-09 -> "09 Nov 2026"
  static String formatTanggal(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
  }

  /// Alias untuk formatTanggal
  static String formatDate(DateTime? dateTime) => formatTanggal(dateTime);

  /// Format tanggal pendek: misal "09 Nov" (untuk sumbu X grafik tren 7 hari)
  static String formatTanggalPendek(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd MMM', 'id_ID').format(dateTime);
  }

  /// Format jam & menit: misal "20:00"
  static String formatJam(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('HH:mm', 'id_ID').format(dateTime);
  }

  /// Format ISO 8601 string tanggal murni: "yyyy-MM-dd"
  static String toIsoDateString(DateTime dt) {
    return DateFormat('yyyy-MM-dd').format(dt);
  }
}

