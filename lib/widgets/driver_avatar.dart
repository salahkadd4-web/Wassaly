import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Photo de profil, ou initiale du nom sur fond teinte (ou icone sans nom).
class DriverAvatar extends StatelessWidget {
  const DriverAvatar({
    super.key,
    this.photo,
    this.name,
    this.radius = 24,
    this.icon,
  });

  final String? photo;
  final String? name;
  final double radius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final url = photo;
    final initial = (name ?? '').trim().isEmpty
        ? null
        : String.fromCharCode((name!.trim()).runes.first).toUpperCase();
    final fg = context.isDark ? const Color(0xFFB9CDF9) : AppTheme.blue;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.blue.withValues(alpha: context.isDark ? 0.30 : 0.10),
      foregroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
      child: initial != null
          ? Text(
              initial,
              style: context.text.titleMedium?.copyWith(
                color: fg,
                fontSize: radius * 0.8,
                fontWeight: FontWeight.w700,
              ),
            )
          : Icon(icon ?? Icons.person_outline, color: fg, size: radius),
    );
  }
}
