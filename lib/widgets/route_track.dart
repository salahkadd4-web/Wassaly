import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../core/utils/map_links.dart';
import '../l10n/app_localizations.dart';
import '../models/geo_place.dart';
import 'snack.dart';

/// Une etape : quartier (public) et, si on y a acces, l'adresse exacte.
class RouteStop {
  const RouteStop({this.area = '', this.place});

  final String area;

  /// Adresse exacte et GPS ; null tant que le livreur n'a pas conclu l'accord.
  final GeoPlace? place;
}

/// Trajet d'une course : point orange (recuperation) relie par un trait en
/// pointilles a l'epingle bleue (livraison), comme sur le logo et
/// l'illustration de l'accueil. Chaque etape ouvre l'itineraire dans Maps
/// quand l'adresse exacte est connue.
class RouteTrack extends StatelessWidget {
  const RouteTrack({
    super.key,
    required this.pickup,
    required this.delivery,
    this.showDirections = true,
    this.exactHidden = false,
    this.distanceKm,
  });

  final RouteStop pickup;
  final RouteStop delivery;

  /// Bouton d'itineraire a cote de chaque etape (si l'adresse est connue).
  final bool showDirections;

  /// Adresse exacte masquee (livreur avant l'accord) : on le dit.
  final bool exactHidden;

  /// Distance recuperation -> livraison, si connue.
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final comma = Localizations.localeOf(context).languageCode == 'fr';
    final km = distanceKm;
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

    Widget info(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: context.muted),
              const SizedBox(width: 8),
              Expanded(child: Text(text, style: context.text.bodySmall)),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        leg(
          first: true,
          stop: _Stop(label: t.pickup, stop: pickup, showDirections: showDirections),
        ),
        leg(
          first: false,
          stop: _Stop(label: t.delivery, stop: delivery, showDirections: showDirections),
        ),
        if (km != null)
          info(Icons.straighten_rounded, t.courseDistance(formatDistance(km, comma: comma))),
        if (exactHidden) info(Icons.lock_outline_rounded, t.exactAddressAfterAgreement),
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
    required this.stop,
    required this.showDirections,
  });

  final String label;
  final RouteStop stop;
  final bool showDirections;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final place = stop.place;
    final exact = place == null
        ? null
        : (place.address.isEmpty ? t.gpsPosition : place.address);
    // Titre : le quartier ; l'adresse exacte en dessous quand elle est connue.
    final title = stop.area.isNotEmpty ? stop.area : (exact ?? '-');
    final detail = stop.area.isNotEmpty ? exact : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.text.labelMedium),
              const SizedBox(height: 2),
              Text(title, style: context.text.titleSmall),
              if (detail != null)
                Text(detail, style: context.text.bodyMedium),
              if (place != null && place.hasCoordinates && place.address.isNotEmpty)
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
        if (showDirections && place != null)
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
