import 'package:flutter/material.dart';

class DriverAvatar extends StatelessWidget {
  const DriverAvatar({super.key, this.photo, this.radius = 26, this.icon});

  final String? photo;
  final double radius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = photo;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primary.withValues(alpha: 0.12),
      foregroundImage: (url != null && url.isNotEmpty)
          ? NetworkImage(url)
          : null,
      child: Icon(
        icon ?? Icons.two_wheeler,
        color: scheme.primary,
        size: radius,
      ),
    );
  }
}
