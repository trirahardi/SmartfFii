import 'package:flutter/material.dart';

/// Palet warna Neobrutalism aplikasi SmartFi sesuai design.md
class NeoColors {
  NeoColors._();

  // Background
  static const Color bgLight = Color(0xFFE6F0FF); // Biru pudar blueprint
  static const Color bgDark = Color(0xFF18181B); // Zinc 900

  // Surface / Kartu
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF27272A);

  // Borders & Hard Shadows
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Aksen Utama
  static const Color primaryBlue = Color(0xFF3B82F6); // Blue 500
  static const Color primaryBlueHover = Color(0xFF2563EB); // Blue 600
  static const Color primaryBlueLight = Color(0xFFDBEAFE); // Blue 100

  // Status & Aksen
  static const Color successGreen = Color(0xFF10B981); // Emerald 500
  static const Color successGreenLight = Color(0xFF86EFAC); // Green 300
  static const Color dangerRed = Color(0xFFEF4444); // Red 500
  static const Color dangerRedLight = Color(0xFFF87171); // Red 400
  static const Color warningYellow = Color(0xFFF59E0B); // Amber 500
  static const Color yellowAccent = Color(0xFFFDE047); // Yellow 300
  static const Color purpleAccent = Color(0xFF8B5CF6); // Violet 500

  // Teks
  static const Color textDark = Color(0xFF000000);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF475569);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // Border & Shadow BoxShadow helper
  static List<BoxShadow> hardShadow({
    double offset = 4.0,
    Color color = black,
  }) {
    if (offset <= 0) return [];
    return [
      BoxShadow(
        color: color,
        offset: Offset(offset, offset),
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];
  }
}

