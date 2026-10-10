import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/snack.dart';

/// Choix de la photo de la piece d'identite : galerie ou appareil photo.
/// [file] est la photo choisie ; [onPicked] est appele a chaque nouveau choix.
class IdPhotoPicker extends StatelessWidget {
  const IdPhotoPicker({
    super.key,
    required this.file,
    required this.onPicked,
    this.enabled = true,
    this.errorText,
  });

  final XFile? file;
  final ValueChanged<XFile> onPicked;
  final bool enabled;
  final String? errorText;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final t = AppLocalizations.of(context)!;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      if (picked != null) onPicked(picked);
    } catch (_) {
      if (context.mounted) showSnack(context, t.idPickError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final picked = file;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorText != null ? scheme.error : theme.dividerColor,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: picked == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.badge_outlined, size: 56, color: scheme.primary),
                    const SizedBox(height: 8),
                    Text(t.idTitle, style: theme.textTheme.titleMedium),
                  ],
                )
              : Image.file(File(picked.path), fit: BoxFit.cover),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    enabled ? () => _pick(context, ImageSource.gallery) : null,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(t.idFromGallery),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    enabled ? () => _pick(context, ImageSource.camera) : null,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(t.idFromCamera),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
