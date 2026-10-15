import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/delivery_request.dart';
import '../../models/open_request.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/route_track.dart';
import '../../widgets/snack.dart';
import '../../widgets/status_chip.dart';
import '../auth/auth_providers.dart';
import '../billing/billing_functions.dart';
import '../billing/billing_providers.dart';
import '../common/home_tab_provider.dart';
import '../drivers/driver_providers.dart';
import '../ratings/rating_sheet.dart';
import '../requests/negotiation_panel.dart';
import '../requests/price_sheet.dart';
import 'open_request_providers.dart';

/// Lance une action reseau et affiche l'erreur eventuelle.
Future<void> _guard(BuildContext context, Future<void> Function() action) async {
  final t = AppLocalizations.of(context)!;
  try {
    await action();
  } on BillingException catch (e) {
    if (context.mounted) showSnack(context, e.message(t));
  } catch (_) {
    if (context.mounted) showSnack(context, t.genericError);
  }
}

/// Carte d'une demande ouverte.
/// Vue livreur : quartiers et distance, puis son offre (proposer, negocier).
/// Vue client : adresse exacte, offres recues (negocier, accepter, refuser).
class OpenRequestCard extends ConsumerStatefulWidget {
  const OpenRequestCard({
    super.key,
    required this.request,
    required this.asDriver,
  });

  final OpenRequest request;
  final bool asDriver;

  @override
  ConsumerState<OpenRequestCard> createState() => _OpenRequestCardState();
}

class _OpenRequestCardState extends ConsumerState<OpenRequestCard> {
  bool _busy = false;

  OpenRequest get request => widget.request;

  Future<void> _close() async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.closeOpenRequestTitle),
        content: Text(t.closeOpenRequestBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.no)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.yes)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    await _guard(context, () => ref.read(openRequestRepositoryProvider).close(request.id));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final asDriver = widget.asDriver;
    final route = asDriver ? null : ref.watch(openRequestRouteProvider(request.id)).value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Le client voit sa propre demande : inutile de repeter son nom.
            if (asDriver)
              Row(
                children: [
                  DriverAvatar(name: request.clientName, radius: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.clientName, style: context.text.titleMedium),
                        Text(formatDateTime(request.createdAt), style: context.text.bodySmall),
                      ],
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Text(formatDateTime(request.createdAt), style: context.text.bodySmall),
                  ),
                  _clientChip(t),
                ],
              ),
            const SizedBox(height: 16),
            RouteTrack(
              pickup: RouteStop(area: request.pickupArea, place: route?.pickup),
              delivery: RouteStop(area: request.deliveryArea, place: route?.delivery),
              showDirections: false,
              exactHidden: asDriver,
              distanceKm: request.distanceKm,
            ),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppTheme.radiusControl),
                ),
                child: Text(request.note, style: context.text.bodyMedium),
              ),
            ],
            if (asDriver) ...[
              const SizedBox(height: 14),
              _DriverOffer(request: request),
            ] else if (request.isOpen) ...[
              const SizedBox(height: 16),
              _ClientOffers(request: request),
              const SizedBox(height: 4),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: context.ink(AppTheme.danger)),
                  onPressed: _busy ? null : _close,
                  child: Text(t.closeOpenRequest),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _clientChip(AppLocalizations t) {
    if (request.isOpen) {
      return StatusChip(label: t.openRequestOpenLabel, color: AppTheme.orange);
    }
    if (request.isTaken) {
      return StatusChip(
        label: t.openRequestTakenBy(request.takenByName ?? ''),
        color: AppTheme.success,
        icon: Icons.check_rounded,
      );
    }
    return StatusChip(label: t.openRequestClosedLabel, color: AppTheme.neutral);
  }
}

/// Vue livreur : faire une offre, puis negocier avec le client.
class _DriverOffer extends ConsumerStatefulWidget {
  const _DriverOffer({required this.request});

  final OpenRequest request;

  @override
  ConsumerState<_DriverOffer> createState() => _DriverOfferState();
}

class _DriverOfferState extends ConsumerState<_DriverOffer> {
  bool _busy = false;

  OpenRequest get request => widget.request;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    await _guard(context, action);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _makeOffer(String uid) async {
    final t = AppLocalizations.of(context)!;
    final price = await pickPrice(
      context,
      title: t.makeOfferTitle,
      hint: t.makeOfferHint,
      confirmLabel: t.proposeAction,
    );
    if (price == null) return;
    final name = ref.read(userProfileProvider).value?.name ?? '';
    await _run(() => ref.read(openRequestRepositoryProvider).makeOffer(
          openId: request.id,
          driverId: uid,
          driverName: name,
          price: price,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final offer = ref.watch(myOfferProvider(request.id)).value;
    final repo = ref.read(openRequestRepositoryProvider);

    if (offer == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            style: AppTheme.goButton,
            onPressed: _busy ? null : () => _makeOffer(uid),
            icon: const Icon(Icons.local_offer_outlined),
            label: Text(t.makeOfferTitle),
          ),
          const SizedBox(height: 8),
          Text(t.makeOfferHint, textAlign: TextAlign.center, style: context.text.bodySmall),
        ],
      );
    }
    if (!offer.isOpen) {
      return Text(
        offer.refusedBy == 'client' ? t.offerRefusedByClient : t.offerWithdrawn,
        style: context.text.bodyMedium?.copyWith(color: context.muted),
      );
    }

    var fee = 0;
    var debt = 0;
    if (ref.watch(driverProvider(uid)).value?.isPerDeliveryMode ?? false) {
      fee = AppConfig.perDeliveryPriceDa;
      debt = ref.watch(myBillingProvider).value?.debt ?? 0;
    }
    return NegotiationPanel(
      asDriver: true,
      price: offer.price,
      lastBy: offer.lastBy,
      otherName: request.clientName,
      busy: _busy,
      onPropose: (price) => _run(() => repo.counterOffer(
            openId: request.id,
            driverId: uid,
            price: price,
            by: PriceBy.driver,
          )),
      onAccept: () => _run(() async {
        await ref.read(billingFunctionsProvider).agreeOffer(request.id, uid);
        if (!mounted) return;
        showSnack(this.context, t.agreementDone(request.clientName));
        ref.read(homeTabProvider.notifier).select(1);
      }),
      onRefuse: () => _run(() => repo.refuseOffer(
            openId: request.id,
            driverId: uid,
            by: PriceBy.driver,
          )),
      refuseLabel: t.withdrawOffer,
      feeDa: fee,
      debt: debt,
    );
  }
}

/// Vue client : offres recues sur sa demande ouverte.
class _ClientOffers extends ConsumerWidget {
  const _ClientOffers({required this.request});

  final OpenRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final offers = ref.watch(offersProvider(request.id)).value ?? const [];
    final open = offers.where((o) => o.isOpen).toList();

    if (open.isEmpty) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(t.waitingOffers, style: context.text.bodyMedium)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.offersCount('${open.length}'), style: context.text.titleSmall),
        const SizedBox(height: 10),
        for (final o in open) ...[
          _OfferTile(request: request, offer: o),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _OfferTile extends ConsumerStatefulWidget {
  const _OfferTile({required this.request, required this.offer});

  final OpenRequest request;
  final Offer offer;

  @override
  ConsumerState<_OfferTile> createState() => _OfferTileState();
}

class _OfferTileState extends ConsumerState<_OfferTile> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    await _guard(context, action);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final o = widget.offer;
    final openId = widget.request.id;
    final driver = ref.watch(driverProvider(o.driverId)).value;
    final repo = ref.read(openRequestRepositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            DriverAvatar(photo: driver?.photo, name: o.driverName, radius: 16),
            const SizedBox(width: 10),
            Expanded(child: Text(o.driverName, style: context.text.titleSmall)),
            if (driver != null)
              RatingBadge(average: driver.ratingAverage, count: driver.ratingCount),
          ],
        ),
        const SizedBox(height: 8),
        NegotiationPanel(
          asDriver: false,
          price: o.price,
          lastBy: o.lastBy,
          otherName: o.driverName,
          busy: _busy,
          onPropose: (price) => _run(() => repo.counterOffer(
                openId: openId,
                driverId: o.driverId,
                price: price,
                by: PriceBy.client,
              )),
          onAccept: () => _run(() async {
            await ref.read(billingFunctionsProvider).agreeOffer(openId, o.driverId);
            if (mounted) showSnack(this.context, t.agreementDone(o.driverName));
          }),
          onRefuse: () => _run(() => repo.refuseOffer(
                openId: openId,
                driverId: o.driverId,
                by: PriceBy.client,
              )),
        ),
      ],
    );
  }
}
