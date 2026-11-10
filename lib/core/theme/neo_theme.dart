import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'neo_colors.dart';

class NeoTheme {
  NeoTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.manropeTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NeoColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: NeoColors.primaryBlue,
        onPrimary: NeoColors.textLight,
        secondary: NeoColors.warningYellow,
        surface: NeoColors.surfaceLight,
        error: NeoColors.dangerRed,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: NeoColors.textDark,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.0,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          color: NeoColors.textDark,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: NeoColors.textDark,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: NeoColors.textDark,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: NeoColors.textDark,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: NeoColors.textDark,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: NeoColors.textDark,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: NeoColors.textDark,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: NeoColors.textDark,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NeoColors.surfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.manrope(
          color: NeoColors.textDark,
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: NeoColors.black),
      ),
      dividerTheme: const DividerThemeData(
        color: NeoColors.black,
        thickness: 2,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NeoColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: NeoColors.primaryBlue,
        onPrimary: NeoColors.textLight,
        secondary: NeoColors.warningYellow,
        surface: NeoColors.surfaceDark,
        error: NeoColors.dangerRed,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: NeoColors.textLight,
          fontWeight: FontWeight.w900,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: NeoColors.textLight,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: NeoColors.textLight,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: NeoColors.textLight,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: NeoColors.textLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NeoColors.surfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.manrope(
          color: NeoColors.textLight,
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: NeoColors.white),
      ),
      dividerTheme: const DividerThemeData(
        color: NeoColors.white,
        thickness: 2,
        space: 1,
      ),
    );
  }
}

