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
import '../reports/report_sheet.dart';
import 'complete_dialog.dart';
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

  /// Acceptation par le serveur : en formule a la livraison, 50 DA sont
  /// ajoutes a la dette, on le dit avant.
  Future<void> _accept(bool charged, int debt) async {
    final t = AppLocalizations.of(context)!;
    if (charged &&
        !await _confirm(
          t.acceptChargeTitle,
          t.acceptChargeBody(
            '${AppConfig.perDeliveryPriceDa}',
            formatAmount(debt + AppConfig.perDeliveryPriceDa),
            formatAmount(AppConfig.debtLimitDa),
          ),
          t.accept,
        )) {
      return;
    }
    await _run(() async {
      try {
        await ref.read(billingFunctionsProvider).acceptDelivery(request.id);
      } on BillingException catch (e) {
        if (mounted) showSnack(context, e.message(t));
      }
    });
  }

  /// Le livreur termine la course : il saisit le montant, qui alimente son
  /// chiffre d'affaires.
  Future<void> _complete() async {
    final t = AppLocalizations.of(context)!;
    final amount = await askDeliveryAmount(context);
    if (amount == null) return;
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
            if (request.isCompleted && request.amount != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(t.amountLabel, style: context.text.bodySmall),
                  const Spacer(),
                  Text(
                    t.amountDa(formatAmount(request.amount!)),
                    style: context.text.titleMedium,
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
                      : Text(
                          charged
                              ? t.acceptWithPrice('${AppConfig.perDeliveryPriceDa}')
                              : t.accept,
                        ),
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
