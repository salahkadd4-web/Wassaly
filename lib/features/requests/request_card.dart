import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chat.dart';
import '../../models/delivery_request.dart';
import '../../widgets/contact_buttons.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/route_track.dart';
import '../../widgets/snack.dart';
import '../../widgets/status_chip.dart';
import '../auth/auth_providers.dart';
import '../billing/billing_functions.dart';
import '../billing/billing_providers.dart';
import '../chat/chat_repository.dart';
import '../drivers/driver_providers.dart';
import '../ratings/rating_sheet.dart';
import '../reports/report_sheet.dart';
import 'complete_dialog.dart';
import 'price_sheet.dart';
import 'request_providers.dart';

/// Carte d'une demande de livraison, vue par le client ou par le livreur.
///
/// Le numero de l'autre partie n'apparait qu'une fois la demande acceptee ;
/// le livreur accepte via le serveur (debit de 50 DA en formule a la livraison).
class RequestCard extends ConsumerStatefulWidget {
  const RequestCard({super.key, required this.request, required this.asDriver});

  final DeliveryRequest request;
  final bool asDriver;

  @override
  ConsumerState<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<RequestCard> {
  bool _busy = false;

  DeliveryRequest get request => widget.request;
  bool get asDriver => widget.asDriver;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String body, String confirmLabel) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.no)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _setStatus(String status) async {
    final t = AppLocalizations.of(context)!;
    try {
      await ref.read(requestRepositoryProvider).setStatus(request.id, status);
    } catch (_) {
      if (mounted) showSnack(context, t.genericError);
    }
  }

  Future<void> _cancel() async {
    final t = AppLocalizations.of(context)!;
    if (!await _confirm(t.confirmCancelTitle, t.confirmCancelBody, t.yes)) return;
    await _run(() => _setStatus(RequestStatus.cancelled));
  }

  /// Acceptation par le serveur au prix choisi dans la liste. En formule a la
  /// livraison, les 50 DA ajoutes au solde sont indiques dans la meme feuille.
  Future<void> _accept(bool charged, int debt) async {
    final t = AppLocalizations.of(context)!;
    final fee = charged ? AppConfig.perDeliveryPriceDa : 0;
    final price = await pickDeliveryPrice(
      context,
      title: t.acceptPriceTitle,
      confirmLabel: t.accept,
      feeDa: fee,
      debtAfter: debt + fee,
    );
    if (price == null) return;
    await _run(() async {
      try {
        await ref.read(billingFunctionsProvider).acceptDelivery(request.id, price);
      } on BillingException catch (e) {
        if (mounted) showSnack(context, e.message(t));
      }
    });
  }

  /// Le livreur termine la course : le montant est le prix convenu (les
  /// anciennes demandes sans prix demandent encore une saisie).
  Future<void> _complete() async {
    final t = AppLocalizations.of(context)!;
    final price = request.price;
    final int? chosen;
    if (price != null) {
      final ok = await _confirm(
        t.completeConfirmTitle,
        t.completeConfirmBody(formatAmount(price)),
        t.markCompleted,
      );
      chosen = ok ? price : null;
    } else {
      chosen = await askDeliveryAmount(context);
    }
    if (chosen == null) return;
    final amount = chosen;
    await _run(() async {
      try {
        await ref.read(requestRepositoryProvider).complete(request.id, amount);
      } catch (_) {
        if (mounted) showSnack(context, t.genericError);
      }
    });
  }

  void _openChat() {
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
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final name = asDriver ? request.clientName : request.driverName;

    String phone = '';
    if (request.contactShared && request.isOpen) {
      final contact = ref.watch(requestContactProvider(request.id)).value;
      phone = (asDriver ? contact?.clientPhone : contact?.driverPhone) ?? '';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DriverAvatar(name: name, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: context.text.titleMedium),
                      Text(
                        formatDateTime(request.createdAt),
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                RequestStatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 16),
            RouteTrack(
              pickup: request.pickup,
              delivery: request.delivery,
              showDirections: asDriver && request.isOpen,
            ),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 14),
              _NoteBox(note: request.note),
            ],
            if ((request.price ?? (request.isCompleted ? request.amount : null))
                case final shown?) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(t.agreedPrice, style: context.text.bodyMedium),
                  const Spacer(),
                  Text(
                    t.amountDa(formatAmount(shown)),
                    style: context.text.titleLarge,
                  ),
                ],
              ),
            ],
            ..._actions(t, phone),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(AppLocalizations t, String phone) {
    if (asDriver) {
      if (request.isPending) {
        final me = ref.watch(authStateProvider).value?.uid ?? '';
        final driver = ref.watch(driverProvider(me)).value;
        final charged = driver?.isPerDeliveryMode ?? false;
        final debt = charged ? (ref.watch(myBillingProvider).value?.debt ?? 0) : 0;
        return [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: AppTheme.dangerOutlined(context),
                  onPressed: _busy ? null : () => _run(() => _setStatus(RequestStatus.rejected)),
                  child: Text(t.reject),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: AppTheme.confirmButton,
                  onPressed: _busy ? null : () => _accept(charged, debt),
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(t.accept),
                ),
              ),
            ],
          ),
        ];
      }
      if (request.isAccepted) {
        return [
          const SizedBox(height: 16),
          ContactButtons(phone: phone, onMessage: _openChat),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _busy ? null : _complete,
            icon: const Icon(Icons.done_all_rounded),
            label: Text(t.markCompleted),
          ),
        ];
      }
      return const [];
    }

    // Vue client.
    return [
      if (request.isOpen) ...[
        const SizedBox(height: 16),
        ContactButtons(phone: phone, onMessage: _openChat),
        if (request.isPending) ...[
          const SizedBox(height: 8),
          Text(
            t.contactAfterAccept,
            textAlign: TextAlign.center,
            style: context.text.bodySmall,
          ),
        ],
      ],
      if (request.isCompleted) ...[
        const SizedBox(height: 14),
        if (request.rated case final stars?)
          Row(
            children: [
              Text(t.yourRating, style: context.text.bodyMedium),
              const Spacer(),
              StarsRow(stars: stars),
            ],
          )
        else
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.orange.withValues(alpha: 0.16),
              foregroundColor: context.ink(AppTheme.orange),
            ),
            onPressed: () => showRatingSheet(
              context,
              requestId: request.id,
              driverId: request.driverId,
              driverName: request.driverName,
            ),
            icon: const Icon(Icons.star_rounded),
            label: Text(t.rateDelivery),
          ),
      ],
      const SizedBox(height: 4),
      Row(
        children: [
          if (request.isOpen)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: context.ink(AppTheme.danger)),
              onPressed: _busy ? null : _cancel,
              child: Text(t.cancelRequest),
            ),
          const Spacer(),
          if (request.isAccepted || request.isCompleted)
            ReportDriverLink(
              driverId: request.driverId,
              driverName: request.driverName,
              requestId: request.id,
            ),
        ],
      ),
    ];
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTheme.radiusControl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.sticky_note_2_outlined, size: 18, color: context.muted),
          const SizedBox(width: 10),
          Expanded(child: Text(note, style: context.text.bodyMedium)),
        ],
      ),
    );
  }
}
