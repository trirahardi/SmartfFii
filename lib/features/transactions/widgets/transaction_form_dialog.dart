import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_input.dart';
import '../../../shared/widgets/neo_modal.dart';

class TransactionFormDialog {
  TransactionFormDialog._();

  static Future<void> show({
    required BuildContext context,
    required String userId,
    required List<CategoryModel> categories,
    TransactionModel? editingTx,
    required Future<void> Function(TransactionModel tx) onSave,
  }) {
    return NeoModal.show(
      context: context,
      title: editingTx == null ? 'Tambah Transaksi' : 'Ubah Transaksi',
      child: _TransactionFormContent(
        userId: userId,
        categories: categories,
        editingTx: editingTx,
        onSave: onSave,
      ),
    );
  }
}

class _TransactionFormContent extends StatefulWidget {
  final String userId;
  final List<CategoryModel> categories;
  final TransactionModel? editingTx;
  final Future<void> Function(TransactionModel tx) onSave;

  const _TransactionFormContent({
    required this.userId,
    required this.categories,
    this.editingTx,
    required this.onSave,
  });

  @override
  State<_TransactionFormContent> createState() => _TransactionFormContentState();
}

class _TransactionFormContentState extends State<_TransactionFormContent> {
  late String _type;
  late String _categoryName;
  late TextEditingController _nominalController;
  late TextEditingController _descController;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _type = widget.editingTx?.type ?? 'expense';
    _categoryName = widget.editingTx?.categoryName ?? 'Makanan';
    _nominalController = TextEditingController(
      text: widget.editingTx != null ? widget.editingTx!.nominal.toString() : '',
    );
    _descController = TextEditingController(
      text: widget.editingTx?.description ?? '',
    );
    _selectedDate = widget.editingTx?.transactionDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final clean = _nominalController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final nominal = int.tryParse(clean) ?? 0;

    if (nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final categoryMatch = widget.categories.firstWhere(
        (c) => c.name == _categoryName && c.type == _type,
        orElse: () => widget.categories.first,
      );

      final tx = TransactionModel(
        id: widget.editingTx?.id ?? 'tx_${DateTime.now().millisecondsSinceEpoch}',
        userId: widget.userId,
        type: _type,
        nominal: nominal,
        description: _descController.text.trim().isEmpty
            ? (_type == 'income' ? 'Pemasukan' : 'Pengeluaran')
            : _descController.text.trim(),
        categoryId: categoryMatch.id,
        categoryName: _categoryName,
        transactionDate: _selectedDate,
        createdAt: widget.editingTx?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await widget.onSave(tx);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = widget.categories
        .where((c) => c.type == _type)
        .map((c) => c.name)
        .toList();

    if (!filteredCategories.contains(_categoryName)) {
      if (filteredCategories.isNotEmpty) {
        _categoryName = filteredCategories.first;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Pilihan Tipe
        const Text(
          'TIPE TRANSAKSI',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  AudioService().playClickSound();
                  setState(() => _type = 'expense');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _type == 'expense' ? NeoColors.dangerRed : NeoColors.surfaceLight,
                    border: Border.all(color: NeoColors.black, width: 2),
                    boxShadow: _type == 'expense' ? NeoColors.hardShadow(offset: 2) : [],
                  ),
                  child: Center(
                    child: Text(
                      'PENGELUARAN',
                      style: TextStyle(
                        color: _type == 'expense' ? NeoColors.textLight : NeoColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  AudioService().playClickSound();
                  setState(() => _type = 'income');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _type == 'income' ? NeoColors.successGreen : NeoColors.surfaceLight,
                    border: Border.all(color: NeoColors.black, width: 2),
                    boxShadow: _type == 'income' ? NeoColors.hardShadow(offset: 2) : [],
                  ),
                  child: Center(
                    child: Text(
                      'PEMASUKAN',
                      style: TextStyle(
                        color: _type == 'income' ? NeoColors.textLight : NeoColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Kategori Dropdown
        const Text(
          'KATEGORI',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: NeoColors.surfaceLight,
            border: Border.all(color: NeoColors.black, width: 2),
            boxShadow: NeoColors.hardShadow(offset: 2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: filteredCategories.contains(_categoryName)
                  ? _categoryName
                  : (filteredCategories.isNotEmpty ? filteredCategories.first : null),
              items: filteredCategories.map((name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _categoryName = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Nominal
        NeoInput(
          label: 'Nominal (Rp)',
          controller: _nominalController,
          keyboardType: TextInputType.number,
          hintText: '50.000',
        ),
        const SizedBox(height: 14),

        // Deskripsi
        NeoInput(
          label: 'Deskripsi Transaksi',
          controller: _descController,
          hintText: 'Contoh: Belanja mingguan...',
        ),
        const SizedBox(height: 14),

        // Tanggal Transaksi Picker
        const Text(
          'TANGGAL TRANSAKSI',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: NeoColors.surfaceLight,
              border: Border.all(color: NeoColors.black, width: 2),
              boxShadow: NeoColors.hardShadow(offset: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.formatTanggal(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const Icon(Icons.calendar_today, size: 18, color: NeoColors.black),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        NeoButton(
          text: widget.editingTx == null ? 'Simpan Transaksi' : 'Perbarui Transaksi',
          variant: NeoButtonVariant.primary,
          isLoading: _isSaving,
          onPressed: _submit,
        ),
      ],
    );
  }
}

