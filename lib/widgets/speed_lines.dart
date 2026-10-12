import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Les trois traits de vitesse du logo, en orange : signale le mouvement
/// (livreur en ligne, course en cours). A utiliser avec parcimonie.
/// Les traits partent toujours vers l'arriere, donc a droite en arabe.
class SpeedLines extends StatelessWidget {
  const SpeedLines({super.key, this.width = 28, this.color = AppTheme.orange});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final h = width * 0.16;
    Widget bar(double factor) => Container(
          width: width * factor,
          height: h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(h),
          ),
        );
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          bar(0.62),
          SizedBox(height: h * 0.7),
          bar(1),
          SizedBox(height: h * 0.7),
          bar(0.45),
        ],
      ),
    );
  }
}
