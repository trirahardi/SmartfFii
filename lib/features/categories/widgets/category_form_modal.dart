import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_input.dart';
import '../../../shared/widgets/neo_modal.dart';

class CategoryFormModal {
  CategoryFormModal._();

  static Future<void> show({
    required BuildContext context,
    required String userId,
    CategoryModel? editingCategory,
    required Future<void> Function(CategoryModel category) onSave,
  }) {
    return NeoModal.show(
      context: context,
      title: editingCategory == null ? 'Tambah Kategori' : 'Edit Kategori',
      child: _CategoryFormContent(
        userId: userId,
        editingCategory: editingCategory,
        onSave: onSave,
      ),
    );
  }
}

class _CategoryFormContent extends StatefulWidget {
  final String userId;
  final CategoryModel? editingCategory;
  final Future<void> Function(CategoryModel category) onSave;

  const _CategoryFormContent({
    required this.userId,
    this.editingCategory,
    required this.onSave,
  });

  @override
  State<_CategoryFormContent> createState() => _CategoryFormContentState();
}

class _CategoryFormContentState extends State<_CategoryFormContent> {
  late TextEditingController _nameController;
  late String _type;
  late String _selectedIcon;
  late String _selectedColor;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editingCategory?.name ?? '');
    _type = widget.editingCategory?.type ?? 'expense';
    _selectedIcon = widget.editingCategory?.iconName ?? 'Wallet';
    _selectedColor = widget.editingCategory?.colorHex ?? '#3B82F6';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama kategori wajib diisi')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final category = CategoryModel(
        id: widget.editingCategory?.id ?? 'cat_${DateTime.now().millisecondsSinceEpoch}',
        userId: widget.userId,
        name: name,
        type: _type,
        iconName: _selectedIcon,
        colorHex: _selectedColor,
        isDefault: false,
        createdAt: widget.editingCategory?.createdAt ?? DateTime.now(),
      );

      await widget.onSave(category);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Nama Kategori
        NeoInput(
          label: 'Nama Kategori',
          hintText: 'Contoh: Belanja Bulanan',
          controller: _nameController,
        ),
        const SizedBox(height: 14),

        // Tipe Kategori
        const Text(
          'TIPE KATEGORI',
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

        // Pemilih Ikon
        const Text(
          'PILIH IKON',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CategoryIcons.map.keys.map((iconName) {
            final icon = CategoryIcons.map[iconName]!;
            final isSelected = _selectedIcon == iconName;

            return GestureDetector(
              onTap: () {
                AudioService().playClickSound();
                setState(() => _selectedIcon = iconName);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? NeoColors.yellowAccent : NeoColors.surfaceLight,
                  border: Border.all(color: NeoColors.black, width: 2),
                  boxShadow: isSelected ? NeoColors.hardShadow(offset: 2) : [],
                ),
                child: Icon(icon, size: 20, color: NeoColors.black),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Pemilih Warna
        const Text(
          'PILIH WARNA',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CategoryIcons.availableColors.map((hex) {
            final color = CategoryIcons.parseColor(hex);
            final isSelected = _selectedColor == hex;

            return GestureDetector(
              onTap: () {
                AudioService().playClickSound();
                setState(() => _selectedColor = hex);
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: NeoColors.black, width: 2),
                  boxShadow: isSelected ? NeoColors.hardShadow(offset: 3) : [],
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        NeoButton(
          text: widget.editingCategory == null ? 'Simpan Kategori' : 'Simpan Perubahan',
          variant: NeoButtonVariant.primary,
          isLoading: _isSaving,
          onPressed: _submit,
        ),
      ],
    );
  }
}

