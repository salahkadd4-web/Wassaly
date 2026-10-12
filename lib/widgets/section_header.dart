import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Titre de section dans une liste, avec action optionnelle a droite.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing, this.count});

  final String title;
  final Widget? trailing;

  /// Nombre d'elements, affiche discretement apres le titre.
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: title,
                children: [
                  if (count != null)
                    TextSpan(
                      text: '  $count',
                      style: context.text.titleMedium?.copyWith(color: context.muted),
                    ),
                ],
              ),
              style: context.text.titleMedium,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
