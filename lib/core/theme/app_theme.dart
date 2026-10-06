import 'package:flutter/material.dart';

class AppTheme {
  static const Color blue = Color(0xFF0D47A1);
  static const Color orange = Color(0xFFFF7A00);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);

  static ElevatedButtonThemeData get _buttons => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        dividerColor: const Color(0xFFE2E8F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          brightness: Brightness.light,
        ).copyWith(
          primary: blue,
          secondary: orange,
          error: danger,
          surface: Colors.white,
          onSurface: const Color(0xFF0F172A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: blue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: _buttons,
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        dividerColor: const Color(0xFF334155),
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF3B82F6),
          secondary: orange,
          error: danger,
          surface: const Color(0xFF1E293B),
          onSurface: const Color(0xFFF8FAFC),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: _buttons,
      );
}
