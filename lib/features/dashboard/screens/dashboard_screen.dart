import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/blueprint_background.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/expense_bar_chart.dart';
import '../widgets/initial_balance_dialog.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/summary_cards.dart';
import '../widgets/widget_2x2.dart';
import '../../settings/providers/settings_provider.dart';

/// Layar utama Dashboard keuangan SmartFi
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _dialogChecked = false;

  void _checkInitialBalance(List<TransactionModel> transactions) {
    if (_dialogChecked) return;
    _dialogChecked = true;

    if (transactions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          InitialBalanceDialog.show(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return BlueprintBackground(
      child: RefreshIndicator(
        color: NeoColors.primaryBlue,
        backgroundColor: NeoColors.white,
        onRefresh: () async {
          await ref.read(transactionsProvider.notifier).loadTransactions();
        },
        child: transactionsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: NeoColors.black),
          ),
          error: (err, _) => Center(
            child: Text(
              'Gagal memuat data: $err',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          data: (transactions) {
            _checkInitialBalance(transactions);

            // Perhitungan data keuangan
            final income = transactions
                .where((t) => t.isIncome)
                .fold<int>(0, (sum, t) => sum + t.nominal);
            final expense = transactions
                .where((t) => t.isExpense)
                .fold<int>(0, (sum, t) => sum + t.nominal);
            final balance = income - expense;

            final now = DateTime.now();
            final transactionsThisMonth = transactions
                .where((t) =>
                    t.transactionDate.month == now.month &&
                    t.transactionDate.year == now.year)
                .toList();

            final incomeThisMonth = transactionsThisMonth
                .where((t) => t.isIncome)
                .fold<int>(0, (sum, t) => sum + t.nominal);
            final expenseThisMonth = transactionsThisMonth
                .where((t) => t.isExpense)
                .fold<int>(0, (sum, t) => sum + t.nominal);

            return ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Header Sambutan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'DASHBOARD UTAMA',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'RINGKASAN FINANSIAL ANDA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: NeoColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: NeoColors.yellowAccent,
                        border: Border.all(color: NeoColors.black, width: 2),
                        boxShadow: NeoColors.hardShadow(offset: 2),
                      ),
                      child: const Text(
                        'AKTIF',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3 Kartu Ringkasan (Saldo, Masuk, Keluar)
                DashboardSummaryCards(
                  balance: balance,
                  income: income,
                  expense: expense,
                ),
                const SizedBox(height: 20),

                // Widget 2x2 Doughnut Metrics
                Widget2x2(
                  balance: balance,
                  incomeThisMonth: incomeThisMonth,
                  expenseThisMonth: expenseThisMonth,
                  targetSavings: ref.watch(settingsProvider).savingsTarget,
                  transactionsThisMonth: transactionsThisMonth,
                ),
                const SizedBox(height: 20),

                // Grafik Batang Pengeluaran 7 Hari
                ExpenseBarChart(
                  transactions: transactions,
                ),
                const SizedBox(height: 20),

                // Diagram Pie Distribusi Kategori
                CategoryPieChart(
                  transactions: transactions,
                ),
                const SizedBox(height: 20),

                // 5 Transaksi Terbaru
                RecentTransactionsList(
                  transactions: transactions,
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
