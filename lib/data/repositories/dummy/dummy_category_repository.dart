import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/category_model.dart';
import '../category_repository.dart';

class DummyCategoryRepository implements CategoryRepository {
  static const String _categoriesKey = 'smartfi_categories_';

  String _getKey(String userId) => '$_categoriesKey$userId';

  @override
  Future<List<CategoryModel>> getCategories(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_getKey(userId));

    if (jsonStr == null || jsonStr.isEmpty) {
      // Inisialisasi kategori bawaan jika belum ada
      final defaults = CategoryModel.defaultCategories
          .map((c) => c.copyWith(userId: userId))
          .toList();
      await _saveCategories(userId, defaults);
      return defaults;
    }

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      final categories = list
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return categories;
    } catch (_) {
      return CategoryModel.defaultCategories;
    }
  }

  Future<void> _saveCategories(String userId, List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = categories.map((c) => c.toJson()).toList();
    await prefs.setString(_getKey(userId), jsonEncode(jsonList));
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    final current = await getCategories(category.userId);
    current.add(category);
    await _saveCategories(category.userId, current);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final current = await getCategories(category.userId);
    final index = current.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      current[index] = category;
      await _saveCategories(category.userId, current);
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().where((k) => k.startsWith(_categoriesKey));

    for (final key in allKeys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        final List<dynamic> list = jsonDecode(jsonStr);
        final categories = list
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
        categories.removeWhere((c) => c.id == categoryId && !c.isDefault);
        await prefs.setString(key, jsonEncode(categories.map((c) => c.toJson()).toList()));
      }
    }
  }
}

