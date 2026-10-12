import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/map_links.dart';
import '../l10n/app_localizations.dart';
import '../models/geo_place.dart';
import 'snack.dart';

/// Trajet d'une course : point orange (recuperation) relie par un trait en
/// pointilles a l'epingle bleue (livraison), comme sur le logo et
/// l'illustration de l'accueil. Chaque etape ouvre l'itineraire dans Maps.
class RouteTrack extends StatelessWidget {
  const RouteTrack({
    super.key,
    required this.pickup,
    required this.delivery,
    this.showDirections = true,
  });

  final GeoPlace pickup;
  final GeoPlace delivery;

  /// Bouton d'itineraire a cote de chaque etape.
  final bool showDirections;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    // Chaque marqueur est aligne sur le libelle de son etape ; les
    // pointilles partent du depart et descendent jusqu'a l'etape suivante.
    Widget leg({required bool first, required Widget stop}) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 22,
                child: Column(
                  children: [
                    if (first) ...[
                      const SizedBox(height: 3),
                      const RouteDot(),
                      const Expanded(child: DashedLine()),
                    ] else
                      const RoutePin(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: first ? 14 : 0),
                  child: stop,
                ),
              ),
            ],
          ),
        );

    return Column(
      children: [
        leg(
          first: true,
          stop: _Stop(label: t.pickup, place: pickup, showDirections: showDirections),
        ),
        leg(
          first: false,
          stop: _Stop(label: t.delivery, place: delivery, showDirections: showDirections),
        ),
      ],
    );
  }
}

/// Point de depart d'une course (anneau orange).
class RouteDot extends StatelessWidget {
  const RouteDot({super.key, this.size = 14});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: AppTheme.orange, width: size * 0.28),
      ),
    );
  }
}

/// Arrivee d'une course (epingle bleue).
class RoutePin extends StatelessWidget {
  const RoutePin({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on_rounded,
      size: size,
      color: context.isDark ? const Color(0xFF6B9BF7) : AppTheme.blue,
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({
    required this.label,
    required this.place,
    required this.showDirections,
  });

  final String label;
  final GeoPlace place;
  final bool showDirections;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final address = place.address.isEmpty ? t.gpsPosition : place.address;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.text.labelMedium),
              const SizedBox(height: 2),
              Text(address, style: context.text.titleSmall),
              if (place.hasCoordinates && place.address.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gps_fixed, size: 12, color: context.muted),
                      const SizedBox(width: 4),
                      Text(t.gpsShared, style: context.text.bodySmall),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (showDirections)
          IconButton(
            tooltip: t.openInMaps,
            style: IconButton.styleFrom(
              backgroundColor: context.surfaceAlt,
              foregroundColor: context.colors.onSurface,
            ),
            icon: const Icon(Icons.near_me_outlined, size: 20),
            onPressed: () => launchWithFeedback(context, openDirections(place)),
          ),
      ],
    );
  }
}

/// Trait vertical en pointilles entre deux etapes (prend toute la hauteur).
class DashedLine extends StatelessWidget {
  const DashedLine({super.key});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DashPainter(context.muted), child: const SizedBox(width: 22));
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;
    const dash = 4.0;
    const gap = 4.0;
    var y = 4.0;
    while (y < size.height - 4) {
      canvas.drawLine(Offset(x, y), Offset(x, (y + dash).clamp(0, size.height - 4)), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
