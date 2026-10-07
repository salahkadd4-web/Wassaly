import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme_provider.dart';
import '../l10n/app_localizations.dart';

/// Bouton qui bascule entre le mode clair et le mode sombre.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      tooltip: isDark ? t.themeToLight : t.themeToDark,
      icon: Icon(
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        color: color,
      ),
      onPressed: () => ref
          .read(themeModeProvider.notifier)
          .set(isDark ? ThemeMode.light : ThemeMode.dark),
    );
  }
}
