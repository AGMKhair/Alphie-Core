import 'package:flutter/material.dart';
import 'theme_manager.dart';

class AppTheme {
  static ThemeData getTheme(ThemeColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.card,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.accent,
        surface: colors.card,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'monospace',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary),
        ),
        labelStyle: TextStyle(color: colors.glow),
      ),
    );
  }
}
