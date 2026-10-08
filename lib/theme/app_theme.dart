import 'package:flutter/material.dart';

class AppTheme {
  static const navy = Color(0xFF0B3B66);
  static const teal = Color(0xFF13B88A);
  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: navy,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      colorScheme: scheme.copyWith(
        primary: isDark ? const Color(0xFF58A6D9) : navy,
        onPrimary: Colors.white,
        secondary: teal,
        onSecondary: Colors.white,
        surface: isDark ? const Color(0xFF172431) : Colors.white,
        onSurface: isDark ? Colors.white : const Color(0xFF172431),
      ),
      brightness: brightness,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF101820)
          : const Color(0xFFF7F9FC),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF21C99A) : navy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade700,
          disabledForegroundColor: Colors.white70,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? const Color(0xFF75DDBD) : navy,
        ),
      ),
    );
  }
}
