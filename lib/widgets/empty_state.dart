import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Ecran vide : dit ce qui manque et, si possible, propose quoi faire.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.title,
    this.action,
  });

  final IconData icon;
  final String message;
  final String? title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: context.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: context.muted),
              ),
              const SizedBox(height: 16),
              if (title != null) ...[
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: 6),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: context.muted),
              ),
              if (action != null) ...[
                const SizedBox(height: 20),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
