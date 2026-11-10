import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';

/// Kartu filter tanggal dan jenis transaksi laporan keuangan
class ReportFilterCard extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String reportType; // 'all' | 'income' | 'expense'
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final ValueChanged<String> onReportTypeChanged;
  final VoidCallback onSearch;

  const ReportFilterCard({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.reportType,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onReportTypeChanged,
    required this.onSearch,
  });

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    AudioService().playClickSound();
    final initialDate = isStart
        ? (startDate ?? DateTime.now())
        : (endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: NeoColors.primaryBlue,
              onPrimary: NeoColors.white,
              surface: NeoColors.surfaceLight,
              onSurface: NeoColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        onStartDateChanged(picked);
      } else {
        onEndDateChanged(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'FILTER LAPORAN',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),

          // Baris Pemilih Tanggal
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TANGGAL MULAI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: NeoColors.white,
                          border: Border.all(color: NeoColors.black, width: 2),
                          boxShadow: NeoColors.hardShadow(offset: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: NeoColors.black),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                startDate != null
                                    ? DateFormatter.formatDate(startDate!)
                                    : 'Pilih Tanggal',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TANGGAL AKHIR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: NeoColors.white,
                          border: Border.all(color: NeoColors.black, width: 2),
                          boxShadow: NeoColors.hardShadow(offset: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: NeoColors.black),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                endDate != null
                                    ? DateFormatter.formatDate(endDate!)
                                    : 'Pilih Tanggal',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pilihan Jenis Laporan
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'JENIS LAPORAN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: NeoColors.white,
                  border: Border.all(color: NeoColors.black, width: 2),
                  boxShadow: NeoColors.hardShadow(offset: 2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: reportType,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: NeoColors.black),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: NeoColors.black,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('SEMUA TRANSAKSI'),
                      ),
                      DropdownMenuItem(
                        value: 'income',
                        child: Text('PEMASUKAN'),
                      ),
                      DropdownMenuItem(
                        value: 'expense',
                        child: Text('PENGELUARAN'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) onReportTypeChanged(val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tombol Cari Laporan
          NeoButton(
            text: 'CARI LAPORAN',
            icon: const Icon(Icons.search, size: 18, color: NeoColors.white),
            backgroundColor: NeoColors.primaryBlue,
            textColor: NeoColors.white,
            onPressed: onSearch,
          ),
        ],
      ),
    );
  }
}
