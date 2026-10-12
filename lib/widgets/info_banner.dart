import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

enum BannerTone { info, warning, danger, success }

/// Message contextuel dans une page : ce qui se passe et quoi faire.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.title,
    this.tone = BannerTone.info,
    this.icon,
    this.action,
  });

  final String message;
  final String? title;
  final BannerTone tone;
  final IconData? icon;
  final Widget? action;

  Color get _color => switch (tone) {
        BannerTone.info => AppTheme.blue,
        BannerTone.warning => AppTheme.orange,
        BannerTone.danger => AppTheme.danger,
        BannerTone.success => AppTheme.success,
      };

  IconData get _icon =>
      icon ??
      switch (tone) {
        BannerTone.info => Icons.info_outline_rounded,
        BannerTone.warning => Icons.error_outline_rounded,
        BannerTone.danger => Icons.lock_outline_rounded,
        BannerTone.success => Icons.check_circle_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final fg = context.ink(color);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusControl + 2),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: fg, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(title!, style: context.text.titleSmall?.copyWith(color: fg)),
                  const SizedBox(height: 2),
                ],
                Text(message, style: context.text.bodyMedium),
                if (action != null) ...[
                  const SizedBox(height: 10),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
