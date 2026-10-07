import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chat.dart';
import '../../models/delivery_request.dart';
import '../../widgets/contact_buttons.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/place_row.dart';
import '../../widgets/snack.dart';
import '../../widgets/status_chip.dart';
import '../auth/auth_providers.dart';
import '../chat/chat_repository.dart';
import '../drivers/driver_providers.dart';
import 'request_providers.dart';

/// Carte d'une demande de livraison, vue par le client ou par le livreur.
class RequestCard extends ConsumerWidget {
  const RequestCard({super.key, required this.request, required this.asDriver});

  final DeliveryRequest request;
  final bool asDriver;

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    String status, {
    bool confirm = false,
  }) async {
    final t = AppLocalizations.of(context)!;
    if (confirm) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.confirmCancelTitle),
          content: Text(t.confirmCancelBody),
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
    }
    try {
      await ref.read(requestRepositoryProvider).setStatus(request.id, status);
    } catch (_) {
      if (context.mounted) showSnack(context, t.genericError);
    }
  }

  void _openChat(BuildContext context, WidgetRef ref) {
    final myUid = ref.read(authStateProvider).value?.uid;
    if (myUid == null) return;
    final myName = ref.read(userProfileProvider).value?.name ?? '';
    final clientId = asDriver ? request.clientId : myUid;
    final driverId = asDriver ? myUid : request.driverId;
    context.push(
      '/chat/${ChatRepository.idFor(clientId, driverId)}',
      extra: ChatArgs(
        clientName: asDriver ? request.clientName : myName,
        driverName: asDriver ? myName : request.driverName,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    final name = asDriver ? request.clientName : request.driverName;
    final phone = asDriver
        ? request.clientPhone
        : (ref.watch(driverProvider(request.driverId)).value?.phone ?? '');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DriverAvatar(
                  radius: 20,
                  icon: asDriver ? Icons.person : Icons.two_wheeler,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: theme.textTheme.titleMedium),
                      Text(
                        formatDateTime(request.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                RequestStatusChip(status: request.status),
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
            if (request.isOpen || asDriver) ...[
              const SizedBox(height: 14),
              ContactButtons(
                phone: phone,
                onMessage: () => _openChat(context, ref),
              ),
            ],
            if (asDriver && request.isPending) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.danger,
                      ),
                      onPressed: () =>
                          _setStatus(context, ref, RequestStatus.rejected),
                      icon: const Icon(Icons.close),
                      label: Text(t.reject),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.success,
                      ),
                      onPressed: () =>
                          _setStatus(context, ref, RequestStatus.accepted),
                      icon: const Icon(Icons.check),
                      label: Text(t.accept),
                    ),
                  ),
                ],
              ),
            ],
            if (asDriver && request.isAccepted) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () =>
                    _setStatus(context, ref, RequestStatus.completed),
                icon: const Icon(Icons.done_all),
                label: Text(t.markCompleted),
              ),
            ],
            if (!asDriver && request.isOpen) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                ),
                onPressed: () => _setStatus(
                  context,
                  ref,
                  RequestStatus.cancelled,
                  confirm: true,
                ),
                icon: const Icon(Icons.cancel_outlined),
                label: Text(t.cancelRequest),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
