import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Bloc de saisie d'un lieu : adresse ecrite et/ou position GPS partagee.
class PlaceInputSection extends StatelessWidget {
  const PlaceInputSection({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.controller,
    required this.hasGps,
    required this.locating,
    required this.onShare,
    required this.onClear,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;
  final bool hasGps;
  final bool locating;
  final VoidCallback onShare;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: t.addressLabel,
            prefixIcon: const Icon(Icons.edit_location_alt_outlined),
          ),
          validator: (v) {
            final empty = (v ?? '').trim().isEmpty;
            return (empty && !hasGps) ? t.placeRequired : null;
          },
        ),
        const SizedBox(height: 8),
        if (hasGps)
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(t.gpsShared)),
              TextButton(onPressed: onClear, child: Text(t.remove)),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: locating ? null : onShare,
            icon: locating
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(t.shareMyPosition),
          ),
      ],
    );
  }
}
