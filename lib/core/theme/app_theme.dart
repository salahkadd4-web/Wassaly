import 'package:flutter/material.dart';

class AppTheme {
  static const Color blue = Color(0xFF0D47A1);
  static const Color orange = Color(0xFFFF7A00);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color neutral = Color(0xFF64748B);

  static const RoundedRectangleBorder _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  static ThemeData _base({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color primary,
    required Color border,
    required Color appBar,
  }) {
    final scheme = ColorScheme.fromSeed(seedColor: blue, brightness: brightness)
        .copyWith(
          primary: primary,
          secondary: orange,
          error: danger,
          surface: surface,
          onSurface: onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      dividerColor: border,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBar,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 48),
          shape: _shape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 46),
          shape: _shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 46),
          shape: _shape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: orange.withValues(alpha: 0.22),
      ),
    );
  }

  static ThemeData get light => _base(
    brightness: Brightness.light,
    background: const Color(0xFFF8FAFC),
    surface: Colors.white,
    onSurface: const Color(0xFF0F172A),
    primary: blue,
    border: const Color(0xFFE2E8F0),
    appBar: blue,
  );

  static ThemeData get dark => _base(
    brightness: Brightness.dark,
    background: const Color(0xFF0F172A),
    surface: const Color(0xFF1E293B),
    onSurface: const Color(0xFFF8FAFC),
    primary: const Color(0xFF3B82F6),
    border: const Color(0xFF334155),
    appBar: const Color(0xFF1E293B),
  );
}
