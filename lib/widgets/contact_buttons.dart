import 'package:flutter/material.dart';

import '../core/utils/map_links.dart';
import '../l10n/app_localizations.dart';
import 'snack.dart';

/// Boutons Appeler / WhatsApp / Message.
class ContactButtons extends StatelessWidget {
  const ContactButtons({super.key, required this.phone, this.onMessage});

  final String phone;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: phone.isEmpty
                ? null
                : () => launchWithFeedback(context, callPhone(phone)),
            icon: const Icon(Icons.call, size: 18),
            label: Text(t.call, overflow: TextOverflow.ellipsis),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: phone.isEmpty
                ? null
                : () => launchWithFeedback(context, openWhatsApp(phone)),
            icon: const Icon(Icons.forum_outlined, size: 18),
            label: Text(t.whatsapp, overflow: TextOverflow.ellipsis),
          ),
        ),
        if (onMessage != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onMessage,
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: Text(t.message, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ],
    );
  }
}
