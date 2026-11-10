import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_input.dart';
import '../services/smart_input_parser.dart';

class SmartPreviewCard extends StatefulWidget {
  final SmartInputResult initialResult;
  final List<CategoryModel> categories;
  final Future<void> Function({
    required String type,
    required String category,
    required int nominal,
    required String description,
  }) onSave;

  const SmartPreviewCard({
    super.key,
    required this.initialResult,
    required this.categories,
    required this.onSave,
  });

  @override
  State<SmartPreviewCard> createState() => _SmartPreviewCardState();
}

class _SmartPreviewCardState extends State<SmartPreviewCard> {
  late String _type;
  late String _selectedCategory;
  late TextEditingController _nominalController;
  late TextEditingController _descController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialResult.type;
    _selectedCategory = widget.initialResult.category;
    _nominalController = TextEditingController(
      text: widget.initialResult.nominal > 0
          ? widget.initialResult.nominal.toString()
          : '',
    );
    _descController = TextEditingController(text: widget.initialResult.description);
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final clean = _nominalController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final nominal = int.tryParse(clean) ?? 0;

    if (nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari Rp 0')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        type: _type,
        category: _selectedCategory,
        nominal: nominal,
        description: _descController.text.trim().isEmpty
            ? (_type == 'income' ? 'Pemasukan' : 'Pengeluaran')
            : _descController.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = widget.categories
        .where((c) => c.type == _type)
        .map((c) => c.name)
        .toList();

    if (!availableCategories.contains(_selectedCategory)) {
      if (availableCategories.isNotEmpty) {
        _selectedCategory = availableCategories.first;
      }
    }

    return NeoCard(
      backgroundColor: const Color(0xFFF0FDF4), // Green 50
      borderColor: NeoColors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: NeoColors.yellowAccent,
                  border: Border.all(color: NeoColors.black, width: 2),
                ),
                child: const Icon(Icons.auto_awesome, size: 16, color: NeoColors.black),
              ),
              const SizedBox(width: 8),
              const Text(
                'PRATINJAU HASIL AI',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tipe Transaksi Selector
          const Text(
            'TIPE TRANSAKSI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
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
              const SizedBox(width: 10),
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

          // Kategori Dropdown / Selector
          const Text(
            'KATEGORI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
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
                value: availableCategories.contains(_selectedCategory)
                    ? _selectedCategory
                    : (availableCategories.isNotEmpty ? availableCategories.first : null),
                items: availableCategories.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Input Nominal
          NeoInput(
            label: 'Nominal (Rp)',
            controller: _nominalController,
            keyboardType: TextInputType.number,
            hintText: '25.000',
          ),
          const SizedBox(height: 14),

          // Input Deskripsi
          NeoInput(
            label: 'Deskripsi Transaksi',
            controller: _descController,
            hintText: 'Makan siang warteg...',
          ),
          const SizedBox(height: 18),

          // Tombol Simpan
          NeoButton(
            text: 'Simpan Transaksi',
            variant: NeoButtonVariant.success,
            isLoading: _isSaving,
            onPressed: _handleSave,
            icon: const Icon(Icons.check_circle_outline, color: NeoColors.black),
          ),
        ],
      ),
    );
  }
}

