import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/locale/locale_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../features/auth/auth_providers.dart';
import '../features/notifications/push_providers.dart';
import '../l10n/app_localizations.dart';
import 'driver_avatar.dart';

enum _AccountAction { language, theme, admin, signOut }

/// Action de la barre d'application : un seul menu "compte" (langue, theme,
/// administration, deconnexion) au lieu de quatre icones.
List<Widget> buildAppBarActions(BuildContext context, WidgetRef ref) {
  return const [AccountMenuButton(), SizedBox(width: 8)];
}

class AccountMenuButton extends ConsumerWidget {
  const AccountMenuButton({super.key});

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final code = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Français'),
                onTap: () => Navigator.pop(ctx, 'fr'),
              ),
              ListTile(
                title: const Text('العربية'),
                onTap: () => Navigator.pop(ctx, 'ar'),
              ),
            ],
          ),
        ),
      ),
    );
    if (code != null) ref.read(localeProvider.notifier).setLocale(Locale(code));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final isAdmin = ref.watch(isAdminProvider).value == true;
    final profile = ref.watch(userProfileProvider).value;
    final dark = context.isDark;

    return PopupMenuButton<_AccountAction>(
      tooltip: t.accountMenu,
      offset: const Offset(0, 52),
      onSelected: (action) {
        switch (action) {
          case _AccountAction.language:
            _pickLanguage(context, ref);
          case _AccountAction.theme:
            ref
                .read(themeModeProvider.notifier)
                .set(dark ? ThemeMode.light : ThemeMode.dark);
          case _AccountAction.admin:
            context.push('/admin');
          case _AccountAction.signOut:
            signOutAndUnregisterPush(ref);
        }
      },
      itemBuilder: (_) => [
        if (profile != null)
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: context.text.titleSmall),
                Text(profile.email, style: context.text.bodySmall),
              ],
            ),
          ),
        if (profile != null) const PopupMenuDivider(),
        _item(_AccountAction.language, Icons.translate_rounded, t.language),
        _item(
          _AccountAction.theme,
          dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          dark ? t.themeToLight : t.themeToDark,
        ),
        if (isAdmin)
          _item(_AccountAction.admin, Icons.admin_panel_settings_outlined, t.adminPanel),
        const PopupMenuDivider(),
        _item(_AccountAction.signOut, Icons.logout_rounded, t.signOut),
      ],
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: DriverAvatar(photo: profile?.photo, name: profile?.name, radius: 18),
      ),
    );
  }

  PopupMenuItem<_AccountAction> _item(
    _AccountAction value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }
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
        const SizedBox(width: 12),
        Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
