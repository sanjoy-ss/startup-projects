import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AlogyanStyles {
  static const Size minTouchTargetSize = Size(48.0, 48.0);
  static final BorderRadius cardRadius = BorderRadius.circular(12.0);

  static ThemeData get themeData {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AlogyanColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AlogyanColors.primary,
        primary: AlogyanColors.primary,
        surface: AlogyanColors.surface,
        error: AlogyanColors.danger,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AlogyanColors.textPrimary,
        displayColor: AlogyanColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AlogyanColors.surface,
        foregroundColor: AlogyanColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AlogyanColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AlogyanColors.primary,
          foregroundColor: Colors.white,
          minimumSize: minTouchTargetSize,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
