import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/subscription_claim.dart';
import '../../widgets/snack.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../auth/auth_providers.dart';
import '../drivers/driver_providers.dart';
import 'subscription_providers.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _refCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _refCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final me = ref.read(authStateProvider).value;
    final driver = me == null ? null : ref.read(driverProvider(me.uid)).value;
    if (driver == null) return;

    setState(() => _sending = true);
    try {
      await ref
          .read(subscriptionRepositoryProvider)
          .submitClaim(driver: driver, reference: _refCtrl.text);
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
    final theme = Theme.of(context);
    final me = ref.watch(authStateProvider).value;
    final driver = me == null ? null : ref.watch(driverProvider(me.uid)).value;
    final claims = ref.watch(myClaimsProvider);
    final hasPending = claims.value?.any((c) => c.isPending) ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(t.subscription)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (driver != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SubscriptionChip(status: driver.effectiveStatus),
                          const SizedBox(height: 8),
                          if (driver.subscriptionEnd != null)
                            Text(
                              t.expiresOn(formatDate(driver.subscriptionEnd!)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        color: AppTheme.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.priceLine('${AppConfig.monthlyPriceDa}'),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(t.paymentSteps),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(AppConfig.paymentDetails),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _refCtrl,
                  maxLength: 120,
                  decoration: InputDecoration(
                    labelText: t.paymentReference,
                    prefixIcon: const Icon(Icons.receipt_long_outlined),
                  ),
                  validator: (v) => (v ?? '').trim().length < 3
                      ? t.paymentReferenceRequired
                      : null,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: (_sending || hasPending) ? null : _submit,
                  icon: _sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(t.iHavePaid),
                ),
                if (hasPending)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      t.claimAlreadyPending,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(t.claimsHistory, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          claims.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingState(),
            ),
            error: (_, __) => const SizedBox(height: 160, child: ErrorState()),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(t.noClaims, textAlign: TextAlign.center),
                );
              }
              return Column(
                children: [
                  for (final c in list) ...[
                    _ClaimTile(claim: c),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ClaimTile extends StatelessWidget {
  const _ClaimTile({required this.claim});

  final SubscriptionClaim claim;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final StatusChip chip;
    switch (claim.status) {
      case 'approved':
        chip = StatusChip(
          label: t.claimApproved,
          color: AppTheme.success,
          icon: Icons.check_circle_outline,
        );
      case 'rejected':
        chip = StatusChip(
          label: t.claimRejected,
          color: AppTheme.danger,
          icon: Icons.block,
        );
      default:
        chip = StatusChip(
          label: t.claimPending,
          color: AppTheme.orange,
          icon: Icons.schedule,
        );
    }
    return Card(
      child: ListTile(
        title: Text(claim.reference),
        subtitle: Text(formatDateTime(claim.createdAt)),
        trailing: chip,
      ),
    );
  }
}
