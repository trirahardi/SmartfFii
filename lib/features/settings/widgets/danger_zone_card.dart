import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../transactions/providers/transaction_provider.dart';

/// Kartu Zona Bahaya: Hapus riwayat transaksi berdasarkan rentang
class DangerZoneCard extends ConsumerStatefulWidget {
  const DangerZoneCard({super.key});

  @override
  ConsumerState<DangerZoneCard> createState() => _DangerZoneCardState();
}

class _DangerZoneCardState extends ConsumerState<DangerZoneCard> {
  String _deleteRange = 'all'; // 'this_month' | 'this_year' | 'all'
  bool _isDeleting = false;

  Future<void> _handleConfirmDelete() async {
    AudioService().playClickSound();

    final rangeText = _deleteRange == 'this_month'
        ? 'bulan ini'
        : (_deleteRange == 'this_year' ? 'tahun ini' : 'semua waktu');

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: NeoColors.surfaceLight,
            border: Border.all(color: NeoColors.black, width: 4),
            boxShadow: NeoColors.hardShadow(offset: 8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: NeoColors.dangerRedLight,
                  border: Border(
                    bottom: BorderSide(color: NeoColors.black, width: 4),
                  ),
                ),
                child: const Text(
                  'KONFIRMASI HAPUS TRANSAKSI',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: NeoColors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Apakah Anda yakin ingin menghapus data transaksi untuk rentang $rangeText? Data akan hilang permanen.',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.of(ctx).pop(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: NeoColors.white,
                                border: Border.all(
                                  color: NeoColors.black,
                                  width: 2,
                                ),
                                boxShadow: NeoColors.hardShadow(offset: 2),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'BATAL',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.of(ctx).pop(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: NeoColors.dangerRed,
                                border: Border.all(
                                  color: NeoColors.black,
                                  width: 2,
                                ),
                                boxShadow: NeoColors.hardShadow(offset: 2),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'YA, HAPUS',
                                style: TextStyle(
                                  color: NeoColors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      try {
        await ref
            .read(transactionsProvider.notifier)
            .deleteByRange(_deleteRange);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Riwayat transaksi berhasil dihapus!'),
              backgroundColor: NeoColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus transaksi: $e'),
              backgroundColor: NeoColors.dangerRed,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      borderColor: NeoColors.dangerRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: NeoColors.dangerRedLight,
                  border: Border.all(color: NeoColors.black, width: 2),
                  boxShadow: NeoColors.hardShadow(offset: 2),
                ),
                child: const Icon(
                  Icons.warning,
                  color: NeoColors.black,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'ZONA BAHAYA',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: NeoColors.dangerRed,
                    ),
                  ),
                  Text(
                    'HAPUS DATA TRANSAKSI PERMANEN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: NeoColors.textMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pilihan Rentang
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RENTANG PENGHAPUSAN',
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
                    value: _deleteRange,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: NeoColors.black,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: NeoColors.black,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'this_month',
                        child: Text('TRANSAKSI BULAN INI'),
                      ),
                      DropdownMenuItem(
                        value: 'this_year',
                        child: Text('TRANSAKSI TAHUN INI'),
                      ),
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('SEMUA TRANSAKSI SEPANJANG WAKTU'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _deleteRange = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          NeoButton(
            text: _isDeleting ? 'MENGHAPUS...' : 'HAPUS RIWAYAT TRANSAKSI',
            icon: const Icon(
              Icons.delete_forever,
              size: 18,
              color: NeoColors.white,
            ),
            backgroundColor: NeoColors.dangerRed,
            textColor: NeoColors.white,
            onPressed: _isDeleting ? null : _handleConfirmDelete,
          ),
        ],
      ),
    );
  }
}
