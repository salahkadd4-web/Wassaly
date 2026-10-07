import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chat.dart';
import '../../models/open_request.dart';
import '../../widgets/contact_buttons.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/place_row.dart';
import '../../widgets/snack.dart';
import '../../widgets/status_chip.dart';
import '../auth/auth_providers.dart';
import '../chat/chat_repository.dart';
import 'open_request_providers.dart';

/// Carte d'une demande ouverte.
/// Vue livreur : boutons de contact. Vue client : bouton pour la cloturer.
class OpenRequestCard extends ConsumerWidget {
  const OpenRequestCard({
    super.key,
    required this.request,
    required this.asDriver,
  });

  final OpenRequest request;
  final bool asDriver;

  void _openChat(BuildContext context, WidgetRef ref) {
    final myUid = ref.read(authStateProvider).value?.uid;
    if (myUid == null) return;
    final myName = ref.read(userProfileProvider).value?.name ?? '';
    context.push(
      '/chat/${ChatRepository.idFor(request.clientId, myUid)}',
      extra: ChatArgs(clientName: request.clientName, driverName: myName),
    );
  }

  Future<void> _close(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.closeOpenRequestTitle),
        content: Text(t.closeOpenRequestBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.yes),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(openRequestRepositoryProvider).close(request.id);
    } catch (_) {
      if (context.mounted) showSnack(context, t.genericError);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const DriverAvatar(radius: 20, icon: Icons.person),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.clientName,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        formatDateTime(request.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!asDriver)
                  StatusChip(
                    label: request.isOpen
                        ? t.openRequestOpenLabel
                        : t.openRequestClosedLabel,
                    color: request.isOpen ? AppTheme.success : AppTheme.neutral,
                    icon: Icons.circle,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            PlaceRow(
              icon: Icons.upload_outlined,
              label: t.pickup,
              place: request.pickup,
              color: AppTheme.orange,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            PlaceRow(
              icon: Icons.home_outlined,
              label: t.delivery,
              place: request.delivery,
            ),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sticky_note_2_outlined, size: 18, color: muted),
                  const SizedBox(width: 8),
                  Expanded(child: Text(request.note)),
                ],
              ),
            ],
            if (asDriver) ...[
              const SizedBox(height: 14),
              ContactButtons(
                phone: request.clientPhone,
                onMessage: () => _openChat(context, ref),
              ),
            ] else if (request.isOpen) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                ),
                onPressed: () => _close(context, ref),
                icon: const Icon(Icons.cancel_outlined),
                label: Text(t.closeOpenRequest),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
