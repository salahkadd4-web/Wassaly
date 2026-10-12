import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/driver_billing.dart';
import '../../models/driver_profile.dart';
import '../../models/subscription_claim.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/section_header.dart';
import '../../widgets/snack.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../auth/auth_providers.dart';
import '../billing/billing_functions.dart';
import '../billing/billing_providers.dart';
import '../driver/driver_dashboard_tab.dart';
import '../drivers/driver_providers.dart';
import 'subscription_providers.dart';

/// "Ma formule" : statut, choix de la formule, dette, paiement, historique.
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final me = ref.watch(authStateProvider).value;
    final driverAsync = me == null
        ? const AsyncValue<DriverProfile?>.loading()
        : ref.watch(driverProvider(me.uid));
    final billing = ref.watch(myBillingProvider).value ??
        DriverBilling.empty(me?.uid ?? '');

    return Scaffold(
      appBar: AppBar(title: Text(t.myPlan)),
      body: driverAsync.when(
        loading: () => const LoadingState(),
        error: (_, _) => const ErrorState(),
        data: (driver) {
          if (driver == null) return const ErrorState();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              _StatusCard(driver: driver, billing: billing),
              const SizedBox(height: 24),
              _PlanChooser(driver: driver, billing: billing),
              const SizedBox(height: 24),
              _PaymentSection(driver: driver, billing: billing),
              const SizedBox(height: 24),
              const _History(),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------- Statut

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.driver, required this.billing});

  final DriverProfile driver;
  final DriverBilling billing;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final status = driver.effectiveStatus;
    final perDelivery = status == 'per_delivery' || status == 'blocked';

    final String title;
    final String? line;
    switch (status) {
      case 'trial':
        title = t.subTrial;
        line = t.trialUntil('${driver.daysLeft}', formatDate(driver.subscriptionEnd!));
      case 'paid':
        title = t.planMonthlyTitle;
        line = t.expiresOn(formatDate(driver.subscriptionEnd!));
      case 'per_delivery':
      case 'blocked':
        title = t.planPerDeliveryTitle;
        line = null;
      case 'suspended':
        title = t.subSuspended;
        line = t.suspendedMsg;
      default:
        title = t.noActivePlan;
        line = t.subscriptionExpiredMsg;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: context.text.titleLarge)),
                // Le titre dit deja la formule : la pastille ne sert qu'au blocage.
                if (status == 'blocked') SubscriptionChip(status: status),
              ],
            ),
            if (line != null) ...[
              const SizedBox(height: 6),
              Text(line, style: context.text.bodyMedium?.copyWith(color: context.muted)),
            ],
            if (perDelivery) ...[
              const SizedBox(height: 18),
              Text(t.debtLabel, style: context.text.labelMedium),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    t.amountDa(formatAmount(billing.debt)),
                    style: context.text.displaySmall,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.debtLimitSuffix(formatAmount(AppConfig.debtLimitDa)),
                    style: context.text.bodyMedium?.copyWith(color: context.muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DebtMeter(billing: billing, height: 12),
              const SizedBox(height: 10),
              Text(
                billing.atLimit
                    ? t.debtBlockedMsg(formatAmount(billing.debt))
                    : t.deliveriesLeft('${billing.deliveriesLeft}'),
                style: context.text.bodySmall?.copyWith(
                  color: billing.atLimit ? context.ink(AppTheme.danger) : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Choix

class _PlanChooser extends ConsumerStatefulWidget {
  const _PlanChooser({required this.driver, required this.billing});

  final DriverProfile driver;
  final DriverBilling billing;

  @override
  ConsumerState<_PlanChooser> createState() => _PlanChooserState();
}

class _PlanChooserState extends ConsumerState<_PlanChooser> {
  String? _saving;

  DriverProfile get d => widget.driver;

  /// Formule affichee comme choisie : celle de la suite, sinon celle en cours.
  String? get _selected {
    if (d.plan != null) return d.plan;
    switch (d.effectiveStatus) {
      case 'paid':
        return DriverPlan.monthly;
      case 'per_delivery':
      case 'blocked':
        return DriverPlan.perDelivery;
    }
    return null;
  }

  /// Quand le choix prendra effet, dit avant de valider.
  String _effect(AppLocalizations t, String plan) {
    final status = d.effectiveStatus;
    if (status == 'trial' || status == 'paid') {
      return t.planEffectOn(formatDate(d.subscriptionEnd!));
    }
    if (plan == DriverPlan.monthly) {
      return t.planEffectAfterPayment(
        formatAmount(AppConfig.monthlyPriceDa + widget.billing.debt),
      );
    }
    return t.planEffectNow;
  }

  Future<void> _choose(String plan) async {
    final t = AppLocalizations.of(context)!;
    if (plan == _selected || _saving != null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(plan == DriverPlan.monthly ? t.planMonthlyTitle : t.planPerDeliveryTitle),
        content: Text(_effect(t, plan)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.choosePlanConfirm)),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = plan);
    try {
      await ref.read(billingFunctionsProvider).choosePlan(plan);
      if (mounted) showSnack(context, t.planSaved);
    } on BillingException catch (e) {
      if (mounted) showSnack(context, e.message(t));
    } finally {
      if (mounted) setState(() => _saving = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final status = d.effectiveStatus;
    if (status == 'suspended') return const SizedBox.shrink();
    final running = status == 'trial' || status == 'paid';
    final selected = _selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: running ? t.planForLater : t.choosePlan),
        _PlanOption(
          selected: selected == DriverPlan.monthly,
          saving: _saving == DriverPlan.monthly,
          title: t.planMonthlyTitle,
          price: t.planMonthlyPrice(formatAmount(AppConfig.monthlyPriceDa)),
          description: t.planMonthlyDesc,
          onTap: () => _choose(DriverPlan.monthly),
        ),
        const SizedBox(height: 10),
        _PlanOption(
          selected: selected == DriverPlan.perDelivery,
          saving: _saving == DriverPlan.perDelivery,
          title: t.planPerDeliveryTitle,
          price: t.planPerDeliveryPrice('${AppConfig.perDeliveryPriceDa}'),
          description: t.planPerDeliveryDesc(formatAmount(AppConfig.debtLimitDa)),
          onTap: () => _choose(DriverPlan.perDelivery),
        ),
        if (d.hasPendingPlanChange && selected != null) ...[
          const SizedBox(height: 10),
          Text(
            _effect(t, selected),
            style: context.text.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _PlanOption extends StatelessWidget {
  const _PlanOption({
    required this.selected,
    required this.saving,
    required this.title,
    required this.price,
    required this.description,
    required this.onTap,
  });

  final bool selected;
  final bool saving;
  final String title;
  final String price;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.isDark ? const Color(0xFF6B9BF7) : AppTheme.blue;
    return Material(
      color: selected
          ? AppTheme.blue.withValues(alpha: context.isDark ? 0.22 : 0.06)
          : Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: BorderSide(
          color: selected ? accent : Theme.of(context).dividerColor,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected ? accent : context.muted,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleMedium),
                    const SizedBox(height: 2),
                    Text(price, style: context.text.titleSmall?.copyWith(color: accent)),
                    const SizedBox(height: 6),
                    Text(description, style: context.text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Paiement

class _PaymentSection extends ConsumerStatefulWidget {
  const _PaymentSection({required this.driver, required this.billing});

  final DriverProfile driver;
  final DriverBilling billing;

  @override
  ConsumerState<_PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends ConsumerState<_PaymentSection> {
  final _formKey = GlobalKey<FormState>();
  final _refCtrl = TextEditingController();
  String? _kind;
  bool _sending = false;

  @override
  void dispose() {
    _refCtrl.dispose();
    super.dispose();
  }

  /// Paiements possibles : la dette si elle existe, le mois sauf si le
  /// livreur reste a la livraison.
  List<String> get _kinds {
    final d = widget.driver;
    final kinds = <String>[];
    if (widget.billing.debt > 0) kinds.add(ClaimKind.debt);
    final staysPerDelivery = d.plan == DriverPlan.perDelivery &&
        !(d.effectiveStatus == 'paid' || d.effectiveStatus == 'trial');
    if (!staysPerDelivery) kinds.add(ClaimKind.monthly);
    return kinds;
  }

  int _amount(String kind) => kind == ClaimKind.debt
      ? widget.billing.debt
      : AppConfig.monthlyPriceDa + widget.billing.debt;

  Future<void> _submit(String kind) async {
    final t = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final profile = ref.read(userProfileProvider).value;
    if (profile == null) return;

    setState(() => _sending = true);
    try {
      await ref.read(subscriptionRepositoryProvider).submitClaim(
            driverId: widget.driver.uid,
            driverName: widget.driver.name,
            driverPhone: profile.phone,
            kind: kind,
            amount: _amount(kind),
            reference: _refCtrl.text,
          );
      _refCtrl.clear();
      if (mounted) showSnack(context, t.claimSent);
    } catch (_) {
      if (mounted) showSnack(context, t.genericError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (widget.driver.isSuspended) return const SizedBox.shrink();
    final kinds = _kinds;
    if (kinds.isEmpty) return const SizedBox.shrink();
    final kind = kinds.contains(_kind) ? _kind! : kinds.first;
    final amount = _amount(kind);
    final hasPending =
        ref.watch(myClaimsProvider).value?.any((c) => c.isPending) ?? false;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: t.payTitle),
          if (kinds.length > 1) ...[
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: ClaimKind.debt, label: Text(t.payDebt)),
                ButtonSegment(value: ClaimKind.monthly, label: Text(t.payMonth)),
              ],
              selected: {kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 14),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(t.amountToPay, style: context.text.bodyMedium)),
                      Text(t.amountDa(formatAmount(amount)), style: context.text.titleLarge),
                    ],
                  ),
                  if (kind == ClaimKind.monthly && widget.billing.debt > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      t.monthPlusDebt(
                        formatAmount(AppConfig.monthlyPriceDa),
                        formatAmount(widget.billing.debt),
                      ),
                      style: context.text.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(t.paymentSteps, style: context.text.bodyMedium),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppTheme.radiusControl),
                    ),
                    child: SelectableText(
                      AppConfig.paymentDetails,
                      style: context.text.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _refCtrl,
                    maxLength: 120,
                    decoration: InputDecoration(
                      labelText: t.paymentReference,
                      prefixIcon: const Icon(Icons.receipt_long_outlined),
                    ),
                    validator: (v) =>
                        (v ?? '').trim().length < 3 ? t.paymentReferenceRequired : null,
                  ),
                  const SizedBox(height: 4),
                  FilledButton(
                    onPressed: (_sending || hasPending) ? null : () => _submit(kind),
                    child: _sending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t.iHavePaidAmount(formatAmount(amount))),
                  ),
                  if (hasPending) ...[
                    const SizedBox(height: 10),
                    InfoBanner(
                      icon: Icons.schedule_rounded,
                      message: t.claimAlreadyPending,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Historique

class _History extends ConsumerWidget {
  const _History();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final claims = ref.watch(myClaimsProvider).value ?? const [];
    final ledger = ref.watch(myLedgerProvider).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: t.claimsHistory),
        if (claims.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(t.noClaims, style: context.text.bodySmall),
          )
        else
          Card(
            child: Column(
              children: [
                for (var i = 0; i < claims.length; i++) ...[
                  if (i > 0) const Divider(indent: 16, endIndent: 16),
                  _ClaimTile(claim: claims[i]),
                ],
              ],
            ),
          ),
        if (ledger.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionHeader(title: t.ledgerTitle),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < ledger.length; i++) ...[
                  if (i > 0) const Divider(indent: 16, endIndent: 16),
                  _LedgerTile(entry: ledger[i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ClaimTile extends StatelessWidget {
  const _ClaimTile({required this.claim});

  final SubscriptionClaim claim;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final StatusChip chip = switch (claim.status) {
      'approved' => StatusChip(label: t.claimApproved, color: AppTheme.success),
      'rejected' => StatusChip(label: t.claimRejected, color: AppTheme.danger),
      _ => StatusChip(label: t.claimPending, color: AppTheme.orange),
    };
    final title = claim.amount > 0
        ? t.claimTitle(
            claim.isDebt ? t.payDebt : t.payMonth,
            t.amountDa(formatAmount(claim.amount)),
          )
        : claim.reference;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(title),
      subtitle: Text('${claim.reference}\n${formatDateTime(claim.createdAt)}'),
      isThreeLine: true,
      trailing: chip,
    );
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final label = switch (entry.type) {
      'refund' => t.ledgerRefund,
      'payment' => t.ledgerPayment,
      _ => t.ledgerCharge,
    };
    final positive = entry.signedAmount > 0;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Text(label),
      subtitle: Text(formatDateTime(entry.createdAt)),
      trailing: Text(
        '${positive ? '+' : '−'}${t.amountDa(formatAmount(entry.amount))}',
        style: context.text.titleSmall?.copyWith(
          color: positive ? null : context.ink(AppTheme.success),
        ),
      ),
    );
  }
}
