import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/neo_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/blueprint_background.dart';
import '../../../shared/widgets/neo_app_bar.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_modal.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/category_form_modal.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _confirmDeleteCategory(BuildContext context, WidgetRef ref, CategoryModel category) {
    NeoModal.show(
      context: context,
      title: 'Hapus Kategori',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Apakah Anda yakin ingin menghapus kategori "${category.name}"?',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
                    await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Kategori "${category.name}" dihapus')),
                      );
                    }
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
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final userId = userAsync.asData?.value?.id ?? 'default_user';

    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: NeoAppBar(
        title: 'Manajemen Kategori',
        leading: GestureDetector(
          onTap: () {
            AudioService().playClickSound();
            Navigator.of(context).pop();
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: NeoColors.surfaceLight,
              border: Border.all(color: NeoColors.black, width: 2.0),
              boxShadow: NeoColors.hardShadow(offset: 2.0),
            ),
            child: const Icon(Icons.arrow_back, color: NeoColors.black, size: 20),
          ),
        ),
      ),
      body: BlueprintBackground(
        child: categoriesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: NeoColors.black),
          ),
          error: (err, _) => Center(
            child: Text('Terjadi kesalahan: $err'),
          ),
          data: (categories) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Header Card
                NeoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: NeoColors.yellowAccent,
                              border: Border.all(color: NeoColors.black, width: 2),
                              boxShadow: NeoColors.hardShadow(offset: 2),
                            ),
                            child: const Icon(Icons.grid_view, size: 24, color: NeoColors.black),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MANAJEMEN KATEGORI',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Kelola kategori transaksi sesuai kebutuhanmu.',
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
                      const SizedBox(height: 16),
                      NeoButton(
                        text: 'Tambah Kategori Baru',
                        variant: NeoButtonVariant.primary,
                        icon: const Icon(Icons.add, color: NeoColors.white),
                        onPressed: () {
                          CategoryFormModal.show(
                            context: context,
                            userId: userId,
                            onSave: (newCat) async {
                              await ref.read(categoriesProvider.notifier).addCategory(newCat);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Grid Kartu Kategori
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final iconData = CategoryIcons.getIcon(cat.iconName);
                    final bgColor = CategoryIcons.parseColor(cat.colorHex);

                    return NeoCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris Atas: Ikon + Tombol Aksi
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  border: Border.all(color: NeoColors.black, width: 2),
                                  boxShadow: NeoColors.hardShadow(offset: 2),
                                ),
                                child: Icon(iconData, size: 22, color: NeoColors.black),
                              ),
                              if (!cat.isDefault) ...[
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        AudioService().playClickSound();
                                        CategoryFormModal.show(
                                          context: context,
                                          userId: userId,
                                          editingCategory: cat,
                                          onSave: (updated) async {
                                            await ref.read(categoriesProvider.notifier).updateCategory(updated);
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: NeoColors.yellowAccent,
                                          border: Border.all(color: NeoColors.black, width: 2),
                                          boxShadow: NeoColors.hardShadow(offset: 1.5),
                                        ),
                                        child: const Icon(Icons.edit, size: 14, color: NeoColors.black),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        AudioService().playClickSound();
                                        _confirmDeleteCategory(context, ref, cat);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: NeoColors.dangerRedLight,
                                          border: Border.all(color: NeoColors.black, width: 2),
                                          boxShadow: NeoColors.hardShadow(offset: 1.5),
                                        ),
                                        child: const Icon(Icons.delete_outline, size: 14, color: NeoColors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          const Spacer(),

                          // Nama Kategori
                          Text(
                            cat.name.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Badge Tipe
                          NeoBadge(
                            text: cat.isExpense ? 'Pengeluaran' : 'Pemasukan',
                            backgroundColor: cat.isExpense ? NeoColors.dangerRedLight : NeoColors.successGreenLight,
                            fontSize: 9,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          ),
                        ],
                      ),
                    );
                  },
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
