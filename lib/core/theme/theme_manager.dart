import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { cyberpunk, matrixGreen, deepOcean }

class ThemeColors {
  final Color primary;
  final Color accent;
  final Color glow;
  final Color background;
  final Color card;
  final LinearGradient primaryGradient;

  const ThemeColors({
    required this.primary,
    required this.accent,
    required this.glow,
    required this.background,
    required this.card,
    required this.primaryGradient,
  });
}

class ThemeNotifier extends Notifier<ThemeType> {
  static const String _prefKey = 'selected_theme_v2';

  @override
  ThemeType build() {
    _init();
    return ThemeType.cyberpunk;
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_prefKey) ?? 0;
      state = ThemeType.values[themeIndex.clamp(0, ThemeType.values.length - 1)];
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> setTheme(ThemeType theme) async {
    state = theme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKey, theme.index);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeType>(() {
  return ThemeNotifier();
});

final themeColorsProvider = Provider<ThemeColors>((ref) {
  final currentTheme = ref.watch(themeProvider);

  switch (currentTheme) {
    case ThemeType.matrixGreen:
      return const ThemeColors(
        primary: Color(0xFF00897B),
        accent: Color(0xFF26A69A),
        glow: Color(0xFF80CBC4),
        background: Color(0xFF0A100D),
        card: Color(0xFF111E19),
        primaryGradient: LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    case ThemeType.deepOcean:
      return const ThemeColors(
        primary: Color(0xFF2979FF),
        accent: Color(0xFF00E5FF),
        glow: Color(0xFFE0F7FA),
        background: Color(0xFF050A18),
        card: Color(0xFF0E172E),
        primaryGradient: LinearGradient(
          colors: [Color(0xFF2979FF), Color(0xFF00E5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    case ThemeType.cyberpunk:
      return const ThemeColors(
        primary: Color(0xFFE53935),
        accent: Color(0xFFFF6D00),
        glow: Color(0xFFFFC107),
        background: Color(0xFF0F0D13),
        card: Color(0xFF1E1926),
        primaryGradient: LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFFF6D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
  }
});
