import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/blueprint_background.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_input.dart';
import '../../../shared/widgets/neo_modal.dart';
import '../../auth/providers/auth_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/smart_input_box.dart';
import '../widgets/transaction_form_dialog.dart';
import '../widgets/transaction_monthly_summary.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _selectedTypeFilter = 'all'; // 'all' | 'income' | 'expense'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, String txId) {
    NeoModal.show(
      context: context,
      title: 'Hapus Transaksi',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: NeoButton(
                  text: 'Batal',
                  variant: NeoButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeoButton(
                  text: 'Hapus',
                  variant: NeoButtonVariant.danger,
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    await ref.read(transactionsProvider.notifier).deleteTransaction(txId);
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Transaksi berhasil dihapus')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);
    final userId = userAsync.asData?.value?.id ?? 'default_user';

    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.asData?.value ?? CategoryModel.defaultCategories;

    final txsAsync = ref.watch(transactionsProvider);

    return BlueprintBackground(
      child: txsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: NeoColors.black),
        ),
        error: (err, _) => Center(
          child: Text('Terjadi kesalahan: $err'),
        ),
        data: (allTransactions) {
          // Filter transaksi
          final searchQuery = _searchController.text.toLowerCase().trim();
          final filteredTxs = allTransactions.where((tx) {
            if (_selectedTypeFilter != 'all' && tx.type != _selectedTypeFilter) {
              return false;
            }
            if (searchQuery.isNotEmpty) {
              final inDesc = tx.description.toLowerCase().contains(searchQuery);
              final inCat = tx.categoryName.toLowerCase().contains(searchQuery);
              return inDesc || inCat;
            }
            return true;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Header Title
              NeoCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: NeoColors.yellowAccent,
                        border: Border.all(color: NeoColors.black, width: 2),
                        boxShadow: NeoColors.hardShadow(offset: 2),
                      ),
                      child: const Icon(Icons.swap_horiz, size: 28, color: NeoColors.black),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KELOLA TRANSAKSI',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Lacak dan catat keuangan Anda dengan bantuan AI.',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: NeoColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 1. Smart Input Box
              SmartInputBox(
                categories: categories,
                onSaveTransaction: ({
                  required String type,
                  required String category,
                  required int nominal,
                  required String description,
                }) async {
                  final catMatch = categories.firstWhere(
                    (c) => c.name == category,
                    orElse: () => categories.first,
                  );

                  final newTx = TransactionModel(
                    id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                    userId: userId,
                    type: type,
                    nominal: nominal,
                    description: description,
                    categoryId: catMatch.id,
                    categoryName: category,
                    transactionDate: DateTime.now(),
                    createdAt: DateTime.now(),
                  );

                  await ref.read(transactionsProvider.notifier).addTransaction(newTx);
                },
              ),
              const SizedBox(height: 16),

              // 2. Ringkasan Bulan Ini
              TransactionMonthlySummary(transactions: allTransactions),
              const SizedBox(height: 16),

              // 3. Riwayat Transaksi Container
              NeoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'RIWAYAT TRANSAKSI',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                        NeoButton(
                          text: 'Tambah Manual',
                          isFullWidth: false,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          variant: NeoButtonVariant.warning,
                          icon: const Icon(Icons.add, size: 16, color: NeoColors.black),
                          onPressed: () {
                            TransactionFormDialog.show(
                              context: context,
                              userId: userId,
                              categories: categories,
                              onSave: (tx) async {
                                await ref.read(transactionsProvider.notifier).addTransaction(tx);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Pencarian & Filter Bar
                    NeoInput(
                      hintText: 'Cari transaksi...',
                      controller: _searchController,
                      prefixIcon: const Icon(Icons.search, color: NeoColors.black),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),

                    // Filter Kancing (Semua, Pemasukan, Pengeluaran)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Semua', 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Pemasukan', 'income'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Pengeluaran', 'expense'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Daftar Transaksi
                    if (filteredTxs.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: const Text(
                          'Belum ada transaksi ditemukan.',
                          style: TextStyle(fontWeight: FontWeight.w800, color: NeoColors.textMuted),
                        ),
                      ),
                    ] else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTxs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final tx = filteredTxs[index];
                          final isIncome = tx.isIncome;

                          return GestureDetector(
                            onTap: () {
                              TransactionFormDialog.show(
                                context: context,
                                userId: userId,
                                categories: categories,
                                editingTx: tx,
                                onSave: (updatedTx) async {
                                  await ref.read(transactionsProvider.notifier).updateTransaction(updatedTx);
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: NeoColors.surfaceLight,
                                border: Border.all(color: NeoColors.black, width: 2),
                                boxShadow: NeoColors.hardShadow(offset: 2),
                              ),
                              child: Row(
                                children: [
                                  // Tanggal
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormatter.formatTanggalPendek(tx.transactionDate),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      NeoBadge(
                                        text: tx.categoryName,
                                        fontSize: 10,
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),

                                  // Deskripsi
                                  Expanded(
                                    child: Text(
                                      tx.description,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Nominal
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isIncome ? '+' : '-'} ${CurrencyFormatter.formatRupiah(tx.nominal)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: isIncome ? NeoColors.successGreen : NeoColors.dangerRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),

                                  // Tombol Hapus
                                  GestureDetector(
                                    onTap: () {
                                      AudioService().playClickSound();
                                      _confirmDelete(context, tx.id);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: NeoColors.dangerRedLight,
                                        border: Border.all(color: NeoColors.black, width: 2),
                                        boxShadow: NeoColors.hardShadow(offset: 2),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color: NeoColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedTypeFilter == value;

    return GestureDetector(
      onTap: () {
        AudioService().playClickSound();
        setState(() => _selectedTypeFilter = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? NeoColors.primaryBlueLight : NeoColors.surfaceLight,
          border: Border.all(color: NeoColors.black, width: 2),
          boxShadow: isSelected ? NeoColors.hardShadow(offset: 2) : [],
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: NeoColors.textDark,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
