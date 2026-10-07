import 'package:flutter/material.dart';

import '../core/utils/map_links.dart';
import '../l10n/app_localizations.dart';
import '../models/geo_place.dart';
import 'snack.dart';

/// Ligne "Recuperation" / "Livraison" avec bouton d'itineraire Google Maps.
class PlaceRow extends StatelessWidget {
  const PlaceRow({
    super.key,
    required this.icon,
    required this.label,
    required this.place,
    this.color,
  });

  final IconData icon;
  final String label;
  final GeoPlace place;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Row(
      children: [
        Icon(icon, color: color ?? theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              Text(
                place.address.isEmpty ? t.gpsPosition : place.address,
                style: theme.textTheme.bodyMedium,
              ),
              if (place.hasCoordinates)
                Row(
                  children: [
                    Icon(Icons.gps_fixed, size: 12, color: muted),
                    const SizedBox(width: 4),
                    Text(
                      t.gpsShared,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: t.openInMaps,
          icon: const Icon(Icons.directions),
          onPressed: () => launchWithFeedback(context, openDirections(place)),
        ),
      ],
    );
  }
}
