import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Illustration de ville en bas de l'ecran d'accueil : immeubles, arbres,
/// trajet en pointilles, repere de livraison et livreur a scooter.
/// Dessinee en code : elle s'adapte au theme clair / sombre.
class CityIllustration extends StatelessWidget {
  const CityIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _CityPainter(dark: dark)),
        Align(
          alignment: const Alignment(0.55, 0.78),
          child: Icon(Icons.two_wheeler, size: 64, color: AppTheme.orange),
        ),
      ],
    );
  }
}

class _CityPainter extends CustomPainter {
  _CityPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ground = h * 0.9;

    final far = dark ? const Color(0xFF13234A) : const Color(0xFFDCEAFB);
    final near = dark ? const Color(0xFF1A2F5E) : const Color(0xFFC9DDF7);
    final window = dark ? const Color(0xFF28437F) : const Color(0xFFEAF2FD);
    final tree = dark ? const Color(0xFF1F3C77) : const Color(0xFFC3D8F5);

    void building(double x, double bw, double bh, Color color) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x * w, ground - bh * h, bw * w, bh * h),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()..color = color,
      );
    }

    // Immeubles du fond puis du premier plan.
    building(0.03, 0.14, 0.50, far);
    building(0.46, 0.13, 0.72, far);
    building(0.78, 0.15, 0.58, far);
    building(0.17, 0.13, 0.36, near);
    building(0.60, 0.12, 0.44, near);
    building(0.90, 0.10, 0.34, near);

    // Quelques fenetres.
    final wp = Paint()..color = window;
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 2; c++) {
        canvas.drawRect(
          Rect.fromLTWH(
            (0.20 + c * 0.05) * w,
            ground - (0.31 - r * 0.07) * h,
            0.025 * w,
            0.03 * h,
          ),
          wp,
        );
      }
    }

    // Arbres.
    void treeAt(double x, double r) {
      final cx = x * w;
      canvas.drawRect(
        Rect.fromLTWH(cx - 2, ground - r * 1.2, 4, r * 1.2),
        Paint()..color = tree,
      );
      canvas.drawCircle(Offset(cx, ground - r * 1.9), r, Paint()..color = tree);
    }

    treeAt(0.10, h * 0.12);
    treeAt(0.33, h * 0.08);
    treeAt(0.93, h * 0.11);

    // Sol.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, ground, w, h * 0.04),
        const Radius.circular(8),
      ),
      Paint()..color = near,
    );

    // Trajet en pointilles jusqu'au repere.
    final pinX = w * 0.55;
    final pinY = h * 0.30;
    final route = Path()
      ..moveTo(w * 0.40, ground - 4)
      ..cubicTo(
        w * 0.62,
        ground - h * 0.10,
        w * 0.32,
        h * 0.52,
        pinX,
        pinY + h * 0.18,
      );
    final routePaint = Paint()
      ..color = dark ? AppTheme.orange : const Color(0xFF3B82F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (final m in route.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(
          m.extractPath(d, math.min(d + 7, m.length)),
          routePaint,
        );
        d += 13;
      }
    }

    // Repere orange.
    final r = h * 0.075;
    final orange = Paint()..color = AppTheme.orange;
    canvas.drawPath(
      Path()
        ..moveTo(pinX - r * 0.85, pinY + r * 0.55)
        ..lineTo(pinX, pinY + r * 2.1)
        ..lineTo(pinX + r * 0.85, pinY + r * 0.55)
        ..close(),
      orange,
    );
    canvas.drawCircle(Offset(pinX, pinY), r, orange);
    canvas.drawCircle(
      Offset(pinX, pinY),
      r * 0.42,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _CityPainter old) => old.dark != dark;
}
