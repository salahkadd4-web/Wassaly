import 'package:flutter/material.dart';

/// Systeme visuel de Wassaly.
///
/// Charte (docs/CAHIER_DES_CHARGES.md, section 4) : bleu #0D47A1 = confiance, navigation,
/// confirmation ; orange #FF7A00 = mouvement, la course. L'orange est reserve
/// a UNE action "on y va" par ecran (envoyer une demande, prendre une course) :
/// c'est ce qui la rend reperable.
///
/// Le vert et le rouge de la charte (#22C55E, #EF4444) sont trop clairs pour du
/// texte sur fond blanc : ils servent aux pastilles et aux icones, et leurs
/// versions "ink" aux textes. Meme raison pour le texte des boutons orange,
/// ecrit en bleu nuit et non en blanc (contraste 2,6:1 seulement).
class AppTheme {
  // ---------------------------------------------------------------- Charte
  static const Color blue = Color(0xFF0D47A1);
  static const Color orange = Color(0xFFFF7A00);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color neutral = Color(0xFF64748B);

  /// Bleu nuit du code QR : titres, texte sur orange.
  static const Color navy = Color(0xFF0B1F4D);

  /// Versions lisibles en texte sur fond clair.
  static const Color successInk = Color(0xFF15803D);
  static const Color dangerInk = Color(0xFFB91C1C);
  static const Color orangeInk = Color(0xFFB45309);

  static const String fontFamily = 'ReadexPro';

  // ---------------------------------------------------------------- Formes
  /// Rayons : plus l'element est grand et autonome, plus il est arrondi.
  static const double radiusHero = 28;
  static const double radiusCard = 20;
  static const double radiusControl = 14;

  /// Hauteur des boutons : cible confortable pour un livreur dehors.
  static const double buttonHeight = 52;

  /// Bouton orange "on y va" (une seule fois par ecran).
  static ButtonStyle get goButton => FilledButton.styleFrom(
        backgroundColor: orange,
        foregroundColor: navy,
        disabledBackgroundColor: orange.withValues(alpha: 0.35),
        disabledForegroundColor: navy.withValues(alpha: 0.5),
      );

  /// Bouton de confirmation positive (accepter, valider, se mettre en ligne).
  static ButtonStyle get confirmButton => FilledButton.styleFrom(
        backgroundColor: successInk,
        foregroundColor: Colors.white,
      );

  /// Bouton d'action destructive (refuser, annuler, suspendre).
  static ButtonStyle dangerOutlined(BuildContext context) =>
      OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFFCA5A5)
            : dangerInk,
        side: BorderSide(color: danger.withValues(alpha: 0.45), width: 1.5),
      );

  static TextTheme _text(Color ink, Color muted) {
    TextStyle s(double size, FontWeight w, {double h = 1.3, Color? c, double ls = 0}) =>
        TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: w,
          height: h,
          color: c ?? ink,
          letterSpacing: ls,
        );
    return TextTheme(
      displaySmall: s(34, FontWeight.w700, h: 1.1, ls: -0.5),
      headlineMedium: s(26, FontWeight.w700, h: 1.2, ls: -0.3),
      headlineSmall: s(22, FontWeight.w700, h: 1.25, ls: -0.2),
      titleLarge: s(19, FontWeight.w600, h: 1.3),
      titleMedium: s(16, FontWeight.w600, h: 1.35),
      titleSmall: s(14, FontWeight.w600, h: 1.35),
      bodyLarge: s(16, FontWeight.w400, h: 1.5),
      bodyMedium: s(14.5, FontWeight.w400, h: 1.5),
      bodySmall: s(12.5, FontWeight.w400, h: 1.45, c: muted),
      labelLarge: s(15, FontWeight.w600, h: 1.2),
      labelMedium: s(12.5, FontWeight.w500, h: 1.2, c: muted),
      labelSmall: s(11, FontWeight.w500, h: 1.2, c: muted),
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceAlt,
    required Color ink,
    required Color muted,
    required Color primary,
    required Color line,
  }) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primary.withValues(alpha: dark ? 0.24 : 0.10),
      onPrimaryContainer: dark ? Colors.white : blue,
      secondary: orange,
      onSecondary: navy,
      secondaryContainer: orange.withValues(alpha: dark ? 0.22 : 0.14),
      onSecondaryContainer: dark ? const Color(0xFFFFC78A) : orangeInk,
      error: dark ? const Color(0xFFF87171) : dangerInk,
      onError: Colors.white,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      surfaceContainerLowest: surface,
      surfaceContainerLow: surface,
      surfaceContainer: surfaceAlt,
      surfaceContainerHigh: surfaceAlt,
      surfaceContainerHighest: surfaceAlt,
      outline: line,
      outlineVariant: line,
      inverseSurface: dark ? const Color(0xFFEEF2F8) : navy,
      onInverseSurface: dark ? navy : Colors.white,
      shadow: Colors.black,
      surfaceTint: Colors.transparent,
    );
    final text = _text(ink, muted);
    const controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusControl)),
    );
    const buttonSize = Size(64, buttonHeight);
    final buttonText = text.labelLarge;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: background,
      dividerColor: line,
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: ink),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: controlShape,
          textStyle: buttonText,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: ink.withValues(alpha: 0.10),
          disabledForegroundColor: ink.withValues(alpha: 0.38),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: buttonSize,
          shape: controlShape,
          textStyle: buttonText,
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: controlShape,
          textStyle: buttonText,
          foregroundColor: ink,
          side: BorderSide(color: line, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: controlShape,
          textStyle: buttonText,
          foregroundColor: dark ? const Color(0xFF93B4F8) : blue,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: text.bodyMedium?.copyWith(color: muted),
        floatingLabelStyle: text.bodyMedium?.copyWith(color: primary),
        hintStyle: text.bodyMedium?.copyWith(color: muted),
        prefixIconColor: muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: scheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: primary.withValues(alpha: dark ? 0.28 : 0.12),
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected) ? ink : muted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? (dark ? Colors.white : blue)
                : muted,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: ink,
        unselectedLabelColor: muted,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        indicatorColor: orange,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: line,
        tabAlignment: TabAlignment.start,
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: orange,
        textColor: navy,
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusHero),
        ),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: line,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusHero)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          side: BorderSide(color: line),
        ),
        textStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceAlt,
        circularTrackColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          textStyle: text.titleSmall,
          side: BorderSide(color: line, width: 1.5),
          selectedBackgroundColor: primary.withValues(alpha: dark ? 0.28 : 0.12),
          selectedForegroundColor: dark ? Colors.white : blue,
        ),
      ),
    );
  }

  static ThemeData get light => _build(
        brightness: Brightness.light,
        background: const Color(0xFFF4F6FA),
        surface: Colors.white,
        surfaceAlt: const Color(0xFFEBEFF6),
        ink: navy,
        muted: const Color(0xFF5A6A85),
        primary: blue,
        line: const Color(0xFFDCE2EC),
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        background: const Color(0xFF0B1424),
        surface: const Color(0xFF142033),
        surfaceAlt: const Color(0xFF1B2A42),
        ink: const Color(0xFFEEF2F8),
        muted: const Color(0xFF93A3BC),
        primary: const Color(0xFF3D7BF2),
        line: const Color(0xFF26364F),
      );
}

/// Raccourcis de couleurs selon le theme courant.
extension AppColors on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Texte secondaire.
  Color get muted => colors.onSurfaceVariant;

  /// Fond des zones groupees (champs, infos).
  Color get surfaceAlt => colors.surfaceContainer;

  /// Couleur lisible d'une couleur de charte utilisee comme texte.
  Color ink(Color c) {
    if (isDark) return c == AppTheme.blue ? const Color(0xFF93B4F8) : c;
    if (c == AppTheme.success) return AppTheme.successInk;
    if (c == AppTheme.danger) return AppTheme.dangerInk;
    if (c == AppTheme.orange) return AppTheme.orangeInk;
    return c;
  }
}
