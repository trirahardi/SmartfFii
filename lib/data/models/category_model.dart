import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String type; // 'income' | 'expense'
  final String iconName;
  final String colorHex;
  final bool isDefault;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.iconName = 'Wallet',
    this.colorHex = '#3B82F6',
    this.isDefault = false,
    required this.createdAt,
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  CategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? iconName,
    String? colorHex,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'iconName': iconName,
      'colorHex': colorHex,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String,
      type: json['type'] as String? ?? 'expense',
      iconName: json['iconName'] as String? ?? 'Wallet',
      colorHex: json['colorHex'] as String? ?? '#3B82F6',
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static final List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'def-1',
      userId: '',
      name: 'Makanan',
      type: 'expense',
      iconName: 'Utensils',
      colorHex: '#3B82F6',
      isDefault: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    CategoryModel(
      id: 'def-2',
      userId: '',
      name: 'Transportasi',
      type: 'expense',
      iconName: 'Car',
      colorHex: '#F59E0B',
      isDefault: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    CategoryModel(
      id: 'def-3',
      userId: '',
      name: 'Hiburan',
      type: 'expense',
      iconName: 'Film',
      colorHex: '#8B5CF6',
      isDefault: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    CategoryModel(
      id: 'def-4',
      userId: '',
      name: 'Gaji',
      type: 'income',
      iconName: 'Wallet',
      colorHex: '#10B981',
      isDefault: true,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];
}

/// Pemetaan nama ikon ke IconData bawaan Flutter
class CategoryIcons {
  CategoryIcons._();

  static const Map<String, IconData> map = {
    'Utensils': Icons.restaurant,
    'Car': Icons.directions_car,
    'Film': Icons.movie,
    'HeartPulse': Icons.favorite,
    'GraduationCap': Icons.school,
    'Receipt': Icons.receipt_long,
    'Wallet': Icons.account_balance_wallet,
    'ShoppingCart': Icons.shopping_cart,
    'Plane': Icons.flight,
    'Home': Icons.home,
    'Zap': Icons.bolt,
    'Droplet': Icons.water_drop,
    'Wifi': Icons.wifi,
    'Phone': Icons.phone_android,
    'Coffee': Icons.local_cafe,
    'Shirt': Icons.checkroom,
    'Gift': Icons.card_giftcard,
    'Monitor': Icons.desktop_windows,
    'Briefcase': Icons.work,
    'Plus': Icons.add_circle_outline,
  };

  static IconData getIcon(String? iconName) {
    if (iconName == null) return Icons.circle;
    return map[iconName] ?? Icons.circle;
  }

  static const List<String> availableColors = [
    '#3B82F6', // Blue
    '#0EA5E9', // Sky
    '#06B6D4', // Cyan
    '#14B8A6', // Teal
    '#6366F1', // Indigo
    '#8B5CF6', // Violet
    '#A855F7', // Purple
    '#D946EF', // Fuchsia
    '#EC4899', // Pink
    '#EAB308', // Yellow
    '#F59E0B', // Amber
    '#F97316', // Orange
    '#78716C', // Stone
    '#737373', // Neutral
    '#64748B', // Slate
  ];

  static Color parseColor(String hex) {
    String cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    return Color(int.tryParse(cleanHex, radix: 16) ?? 0xFF3B82F6);
  }
}

