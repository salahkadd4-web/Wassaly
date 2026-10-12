import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/map_links.dart';
import '../l10n/app_localizations.dart';
import 'snack.dart';

/// Boutons Appeler / WhatsApp / Message.
/// Le numero n'est connu qu'apres l'acceptation : sans numero, seul le
/// bouton Message est propose.
class ContactButtons extends StatelessWidget {
  const ContactButtons({super.key, required this.phone, this.onMessage});

  final String phone;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final buttons = <Widget>[
      if (phone.isNotEmpty) ...[
        _ContactButton(
          icon: Icons.call_outlined,
          label: t.call,
          onPressed: () => launchWithFeedback(context, callPhone(phone)),
        ),
        _ContactButton(
          icon: Icons.forum_outlined,
          label: t.whatsapp,
          onPressed: () => launchWithFeedback(context, openWhatsApp(phone)),
        ),
      ],
      // Seul, le bouton Message prend toute la largeur ; a cote des deux
      // autres, il devient une icone pour que les libelles tiennent.
      if (onMessage != null && phone.isEmpty)
        _ContactButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: t.message,
          onPressed: onMessage!,
        ),
    ];
    if (buttons.isEmpty && onMessage == null) return const SizedBox.shrink();
    return Row(
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: buttons[i]),
        ],
        if (onMessage != null && phone.isNotEmpty) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: t.message,
            style: IconButton.styleFrom(
              minimumSize: const Size(46, 46),
              backgroundColor: context.surfaceAlt,
              foregroundColor: context.colors.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusControl),
              ),
            ),
            onPressed: onMessage,
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
          ),
        ],
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        backgroundColor: context.surfaceAlt,
        foregroundColor: context.colors.onSurface,
        textStyle: context.text.titleSmall,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}
