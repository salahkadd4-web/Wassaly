import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/locale/locale_provider.dart';
import '../features/auth/auth_providers.dart';
import '../l10n/app_localizations.dart';
import 'theme_toggle_button.dart';

/// Actions communes de la barre d'application : theme, langue, admin, deconnexion.
List<Widget> buildAppBarActions(BuildContext context, WidgetRef ref) {
  final t = AppLocalizations.of(context)!;
  final isAdmin = ref.watch(isAdminProvider).value == true;

  return [
    const ThemeToggleButton(),
    PopupMenuButton<String>(
      tooltip: t.language,
      icon: const Icon(Icons.language),
      onSelected: (code) =>
          ref.read(localeProvider.notifier).setLocale(Locale(code)),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'fr', child: Text('Français')),
        PopupMenuItem(value: 'ar', child: Text('العربية')),
      ],
    ),
    if (isAdmin)
      IconButton(
        tooltip: t.adminPanel,
        icon: const Icon(Icons.admin_panel_settings_outlined),
        onPressed: () => context.push('/admin'),
      ),
    IconButton(
      tooltip: t.signOut,
      icon: const Icon(Icons.logout),
      onPressed: () => ref.read(authServiceProvider).signOut(),
    ),
  ];
}

/// Titre de barre : petit logo + texte.
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, required this.title, required this.logo});

  final String title;
  final Widget logo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(width: 10),
        Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
