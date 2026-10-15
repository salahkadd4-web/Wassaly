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
import 'negotiation_panel.dart';
import 'request_providers.dart';

/// Carte d'une demande de livraison, vue par le client ou par le livreur.
///
/// Tant qu'il n'y a pas d'accord, le prix se negocie ([NegotiationPanel]) et
/// le livreur ne voit que les quartiers. A l'accord (serveur) : course
/// comptee, telephones et adresse exacte partages.
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
    final t = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await action();
    } on BillingException catch (e) {
      if (mounted) showSnack(context, e.message(t));
    } catch (_) {
      if (mounted) showSnack(context, t.genericError);
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

  Future<void> _cancel() async {
    final t = AppLocalizations.of(context)!;
    if (!await _confirm(t.confirmCancelTitle, t.confirmCancelBody, t.yes)) return;
    await _run(() => ref
        .read(requestRepositoryProvider)
        .setStatus(request.id, RequestStatus.cancelled));
  }

  Future<void> _propose(int price) => _run(() {
        final repo = ref.read(requestRepositoryProvider);
        return asDriver
            ? repo.proposeAsDriver(request.id, price)
            : repo.counterAsClient(request.id, price);
      });

  Future<void> _agree() =>
      _run(() => ref.read(billingFunctionsProvider).agreeDelivery(request.id));

  Future<void> _reject() async {
    final t = AppLocalizations.of(context)!;
    if (!await _confirm(t.refuseTitle, t.refuseBody, t.reject)) return;
    await _run(() => ref
        .read(requestRepositoryProvider)
        .setStatus(request.id, RequestStatus.rejected));
  }

  /// Fin de course : le montant est le prix convenu (saisie seulement pour
  /// les anciennes demandes sans prix).
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
    await _run(() => ref.read(requestRepositoryProvider).complete(request.id, amount));
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

    // Adresse exacte : le client la voit toujours, le livreur apres l'accord.
    final canSeeExact = !asDriver || request.contactShared;
    final route = canSeeExact
        ? (ref.watch(deliveryRouteProvider(request.id)).value ?? request.legacyRoute)
        : null;

    // Prix convenu, affiche une fois l'accord conclu.
    final agreedPrice = request.contactShared
        ? (request.price ?? (request.isCompleted ? request.amount : null))
        : null;

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
              pickup: RouteStop(area: request.pickupArea, place: route?.pickup),
              delivery: RouteStop(area: request.deliveryArea, place: route?.delivery),
              showDirections: asDriver && request.isAccepted,
              exactHidden: !canSeeExact,
              distanceKm: request.distanceKm,
            ),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 14),
              _NoteBox(note: request.note),
            ],
            if (request.awaitingAgreement) ...[
              const SizedBox(height: 14),
              _negotiation(t),
            ],
            if (agreedPrice case final shown?) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(t.agreedPrice, style: context.text.bodyMedium),
                  const Spacer(),
                  Text(t.amountDa(formatAmount(shown)), style: context.text.titleLarge),
                ],
              ),
            ],
            ..._actions(t, phone),
          ],
        ),
      ),
    );
  }

  Widget _negotiation(AppLocalizations t) {
    var fee = 0;
    var debt = 0;
    if (asDriver) {
      final me = ref.watch(authStateProvider).value?.uid ?? '';
      if (ref.watch(driverProvider(me)).value?.isPerDeliveryMode ?? false) {
        fee = AppConfig.perDeliveryPriceDa;
        debt = ref.watch(myBillingProvider).value?.debt ?? 0;
      }
    }
    return NegotiationPanel(
      asDriver: asDriver,
      price: request.isPending ? null : request.price,
      lastBy: request.lastBy,
      otherName: asDriver ? request.clientName : request.driverName,
      busy: _busy,
      onPropose: _propose,
      onAccept: _agree,
      // Le client annule avec le bouton du bas ; le livreur refuse ici.
      onRefuse: asDriver ? _reject : null,
      feeDa: fee,
      debt: debt,
    );
  }

  List<Widget> _actions(AppLocalizations t, String phone) {
    if (asDriver) {
      if (!request.isAccepted) return const [];
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

    // Vue client.
    return [
      if (request.isOpen) ...[
        const SizedBox(height: 16),
        ContactButtons(phone: phone, onMessage: _openChat),
        if (request.awaitingAgreement) ...[
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
