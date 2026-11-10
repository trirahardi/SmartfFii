import '../../../data/models/category_model.dart';

class SmartInputResult {
  final String type; // 'income' | 'expense'
  final String category;
  final int nominal;
  final String description;

  const SmartInputResult({
    required this.type,
    required this.category,
    required this.nominal,
    required this.description,
  });
}

class SmartInputParser {
  SmartInputParser._();

  static SmartInputResult parse(String text, List<CategoryModel> userCategories) {
    final lower = text.toLowerCase().trim();

    // 1. Ekstrak Nominal
    int nominal = _extractNominal(lower);

    // 2. Ekstrak Tipe (Income vs Expense)
    String type = _extractType(lower);

    // 3. Ekstrak Kategori
    String category = _extractCategory(lower, type, userCategories);

    // 4. Buat Deskripsi
    String description = text.trim();
    if (description.isEmpty) {
      description = type == 'income' ? 'Pemasukan' : 'Pengeluaran';
    }

    return SmartInputResult(
      type: type,
      category: category,
      nominal: nominal,
      description: description,
    );
  }

  static int _extractNominal(String text) {
    // Pola 1.5 juta / 1,5 jt / 2 juta
    final jutaRegex = RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:juta|jt)', caseSensitive: false);
    final jutaMatch = jutaRegex.firstMatch(text);
    if (jutaMatch != null) {
      final numStr = jutaMatch.group(1)!.replaceAll(',', '.');
      final val = double.tryParse(numStr) ?? 0;
      return (val * 1000000).round();
    }

    // Pola 25 ribu / 25rb / 25k
    final ribuRegex = RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:ribu|rb|k)', caseSensitive: false);
    final ribuMatch = ribuRegex.firstMatch(text);
    if (ribuMatch != null) {
      final numStr = ribuMatch.group(1)!.replaceAll(',', '.');
      final val = double.tryParse(numStr) ?? 0;
      return (val * 1000).round();
    }

    // Pola angka langsung berpemisah titik atau tidak: misal Rp 50.000 atau 50000
    final rawNumberRegex = RegExp(r'(?:rp\.?\s*)?(\d{1,3}(?:\.\d{3})+|\d{4,})', caseSensitive: false);
    final rawMatch = rawNumberRegex.firstMatch(text);
    if (rawMatch != null) {
      final clean = rawMatch.group(1)!.replaceAll('.', '');
      return int.tryParse(clean) ?? 0;
    }

    return 0;
  }

  static String _extractType(String text) {
    final incomeKeywords = [
      'gaji', 'bonus', 'terima', 'masuk', 'dapat', 'penjualan', 'profit',
      'cair', 'thr', 'honor', 'transfer masuk', 'upah', 'dividen', 'cashback'
    ];

    for (final kw in incomeKeywords) {
      if (text.contains(kw)) {
        return 'income';
      }
    }
    return 'expense';
  }

  static String _extractCategory(String text, String type, List<CategoryModel> categories) {
    if (type == 'income') {
      final incomeCats = categories.where((c) => c.isIncome).map((c) => c.name).toList();
      for (final cat in incomeCats) {
        if (text.contains(cat.toLowerCase())) return cat;
      }
      return incomeCats.isNotEmpty ? incomeCats.first : 'Gaji';
    }

    // Pemetaan kata kunci ke kategori pengeluaran
    final keywordMap = {
      'Makanan': ['makan', 'minum', 'siang', 'malam', 'sarapan', 'warteg', 'resto', 'cafe', 'kopi', 'jajan', 'ayam', 'nasi', 'grabfood', 'gofood', 'kuliner', 'bakso', 'mie'],
      'Transportasi': ['bensin', 'bbm', 'pertalite', 'pertamax', 'ojol', 'gojek', 'grab', 'taksi', 'kereta', 'krl', 'bus', 'tol', 'parkir', 'service motor', 'tambal ban'],
      'Tagihan': ['listrik', 'pln', 'pdam', 'pulsa', 'kuota', 'wifi', 'indihome', 'internet', 'kos', 'bpjs', 'air', 'sewa'],
      'Belanja': ['belanja', 'minimarket', 'indomaret', 'alfamart', 'mall', 'baju', 'sepatu', 'shopee', 'tokopedia', 'lazada', 'tiktok shop', 'pasar'],
      'Hiburan': ['nonton', 'bioskop', 'film', 'game', 'netflix', 'spotify', 'karaoke', 'liburan', 'wisata', 'healing', 'jalan'],
      'Kesehatan': ['obat', 'dokter', 'apotek', 'rumah sakit', 'klinik', 'vitamin', 'medis'],
    };

    for (final entry in keywordMap.entries) {
      for (final kw in entry.value) {
        if (text.contains(kw)) {
          // Cari apakah kategori ini ada di daftar user
          final match = categories.firstWhere(
            (c) => c.name.toLowerCase() == entry.key.toLowerCase(),
            orElse: () => categories.firstWhere(
              (c) => c.isExpense,
              orElse: () => CategoryModel.defaultCategories.first,
            ),
          );
          return match.name;
        }
      }
    }

    // Default ke kategori pengeluaran pertama jika ada
    final expenseCats = categories.where((c) => c.isExpense).toList();
    if (expenseCats.isNotEmpty) return expenseCats.first.name;

    return 'Makanan';
  }
}

