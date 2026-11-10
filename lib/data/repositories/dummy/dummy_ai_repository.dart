import 'dart:convert';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/category_model.dart';
import '../../../features/ai_advisor/models/chat_message.dart';
import '../../../features/transactions/services/smart_input_parser.dart';
import '../ai_repository.dart';

class DummyAiRepository implements AiRepository {
  @override
  Future<String> askMentor({
    required String message,
    required List<ChatMessage> history,
    required String financialContextJson,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final lower = message.toLowerCase();

    // Sapaan ramah tanpa data keuangan
    if (lower == 'halo' || lower == 'hai' || lower == 'apa kabar' || lower == 'selamat pagi' || lower == 'pagi') {
      return 'Halo! Aku SmartFi, mentor keuangan pribadimu. Ada yang ingin kamu diskusikan tentang anggaran atau pengeluaranmu hari ini?';
    }

    // Topik di luar keuangan
    if (lower.contains('python') || lower.contains('coding') || lower.contains('resep') || lower.contains('puisi')) {
      return 'Maaf ya, sebagai SmartFi aku khusus dirancang untuk mendampingi urusan keuangan dan anggaran pribadimu saja. Yuk, tanyakan seputar saldo, pengeluaran, atau tips menabung!';
    }

    // Parse financial context
    int saldo = 0;
    int totalIncome = 0;
    int totalExpense = 0;
    String topCategory = 'Makanan';
    int topCategoryAmount = 0;

    try {
      final contextData = jsonDecode(financialContextJson) as Map<String, dynamic>;
      saldo = (contextData['saldo_terkini'] as num?)?.toInt() ?? 0;
      totalIncome = (contextData['total_pemasukan'] as num?)?.toInt() ?? 0;
      totalExpense = (contextData['total_pengeluaran'] as num?)?.toInt() ?? 0;
      topCategory = contextData['kategori_terbesar'] as String? ?? 'Makanan';
      topCategoryAmount = (contextData['nominal_kategori_terbesar'] as num?)?.toInt() ?? 0;
    } catch (_) {}

    final formattedSaldo = CurrencyFormatter.formatRupiah(saldo);
    final formattedIncome = CurrencyFormatter.formatRupiah(totalIncome);
    final formattedExpense = CurrencyFormatter.formatRupiah(totalExpense);
    final formattedTopCatAmount = CurrencyFormatter.formatRupiah(topCategoryAmount);

    if (lower.contains('terbesar') || lower.contains('pengeluaran terbesar')) {
      return '''
Berdasarkan catatan keuanganmu, pengeluaran terbesarmu saat ini ada di kategori **$topCategory** sebesar **$formattedTopCatAmount**. 

Saran dariku, coba tinjau kembali pos ini dan tetapkan batas mingguan agar sisa anggaranmu tetap aman hingga akhir bulan.
''';
    }

    if (lower.contains('hemat') || lower.contains('saran hemat')) {
      return '''
Berikut 3 saran hemat yang bisa kamu terapkan:

1. Buat daftar belanja sebelum bepergian untuk mencegah pengeluaran impulsif di luar kebutuhan pokok.
2. Kurangi jajan di luar untuk kategori **$topCategory**, alokasikan maksimal **Rp 50.000** per hari.
3. Sisihkan minimal 10% dari setiap pemasukan langsung ke rekening tabungan di awal bulan.
''';
    }

    return '''
### Analisis Singkat
Saat ini saldo aktifmu berada di angka **$formattedSaldo** (Pemasukan: **$formattedIncome**, Pengeluaran: **$formattedExpense**). Pengeluaran terbesarmu tercatat pada kategori **$topCategory** dengan total **$formattedTopCatAmount**.

### 3 Saran Praktis untuk Kamu
1. Batasi transaksi konsumtif pada kategori **$topCategory** agar rasio tabunganmu meningkat.
2. Catat segera setiap transaksi kecil di bawah **Rp 20.000** karena sering kali tidak terasa menumpuk.
3. Tetapkan target tabungan bulanan yang realistis agar progress finansialmu terukur.

### Prediksi Saldo Akhir Bulan
Dengan pola pengeluaran saat ini, arus kasmu diproyeksikan tetap stabil hingga akhir bulan jika kamu menekan pengeluaran tambahan.
''';
  }

  @override
  Future<Map<String, dynamic>> parseSmartInput({
    required String prompt,
    required List<String> categories,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final catModels = categories
        .map((c) => CategoryModel(
              id: c,
              userId: '',
              name: c,
              type: c.toLowerCase().contains('gaji') ? 'income' : 'expense',
              createdAt: DateTime.now(),
            ))
        .toList();

    final result = SmartInputParser.parse(prompt, catModels);
    return {
      'type': result.type,
      'category': result.category,
      'nominal': result.nominal,
      'description': result.description,
    };
  }
}
