import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
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
import '../requests/price_sheet.dart';
import 'open_request_providers.dart';

/// Carte d'une demande ouverte.
/// Vue livreur : "Je prends cette demande" (le premier l'obtient ; le contact
/// du client n'est donne qu'ensuite). Vue client : etat et cloture.
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

  Future<bool> _confirm(String title, String body, String confirmLabel) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.no)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(confirmLabel)),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _take(bool charged, int debt) async {
    final t = AppLocalizations.of(context)!;
    final fee = charged ? AppConfig.perDeliveryPriceDa : 0;
    final price = await pickDeliveryPrice(
      context,
      title: t.takeTitle,
      confirmLabel: t.takeConfirm,
      feeDa: fee,
      debtAfter: debt + fee,
    );
    if (price == null) return;

    setState(() => _busy = true);
    try {
      await ref.read(billingFunctionsProvider).takeOpenRequest(request.id, price);
      if (!mounted) return;
      showSnack(context, t.takeDone(request.clientName));
      ref.read(homeTabProvider.notifier).select(1);
    } on BillingException catch (e) {
      if (mounted) showSnack(context, e.message(t));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _close() async {
    final t = AppLocalizations.of(context)!;
    if (!await _confirm(t.closeOpenRequestTitle, t.closeOpenRequestBody, t.yes)) return;
    try {
      await ref.read(openRequestRepositoryProvider).close(request.id);
    } catch (_) {
      if (mounted) showSnack(context, t.genericError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Le client voit sa propre demande : inutile de repeter son nom.
            if (widget.asDriver)
              Row(
                children: [
                  DriverAvatar(name: request.clientName, radius: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.clientName, style: context.text.titleMedium),
                        Text(
                          formatDateTime(request.createdAt),
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatDateTime(request.createdAt),
                      style: context.text.bodySmall,
                    ),
                  ),
                  _clientChip(t),
                ],
              ),
            const SizedBox(height: 16),
            RouteTrack(
              pickup: request.pickup,
              delivery: request.delivery,
              showDirections: widget.asDriver,
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
            if (widget.asDriver) ..._driverAction(t),
            if (!widget.asDriver && request.isOpen) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: context.ink(AppTheme.danger)),
                  onPressed: _close,
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

  List<Widget> _driverAction(AppLocalizations t) {
    final me = ref.watch(authStateProvider).value?.uid ?? '';
    final driver = ref.watch(driverProvider(me)).value;
    final charged = driver?.isPerDeliveryMode ?? false;
    final debt = charged ? (ref.watch(myBillingProvider).value?.debt ?? 0) : 0;
    return [
      const SizedBox(height: 16),
      FilledButton.icon(
        style: AppTheme.goButton,
        onPressed: _busy ? null : () => _take(charged, debt),
        icon: _busy
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.navy),
              )
            : const Icon(Icons.bolt_rounded),
        label: Text(
          t.takeAction,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        t.takeHint,
        textAlign: TextAlign.center,
        style: context.text.bodySmall,
      ),
    ];
  }
}
