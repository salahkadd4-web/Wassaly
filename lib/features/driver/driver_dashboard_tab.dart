import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ratings/rating_sheet.dart';
import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/driver_billing.dart';
import '../../models/driver_profile.dart';
import '../../services/location_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/snack.dart';
import '../../widgets/speed_lines.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../auth/auth_providers.dart';
import '../billing/billing_providers.dart';
import '../chat/chat_providers.dart';
import '../common/home_tab_provider.dart';
import '../drivers/driver_providers.dart';
import '../requests/request_providers.dart';
import 'revenue_card.dart';

class DriverDashboardTab extends ConsumerStatefulWidget {
  const DriverDashboardTab({super.key});

  @override
  ConsumerState<DriverDashboardTab> createState() => _DriverDashboardTabState();
}

class _DriverDashboardTabState extends ConsumerState<DriverDashboardTab> {
  bool _busy = false;
  bool _autoDeactivated = false;

  Future<void> _setActive(DriverProfile d, bool value) async {
    final t = AppLocalizations.of(context)!;
    final repo = ref.read(driverRepositoryProvider);
    setState(() => _busy = true);
    try {
      if (value) {
        if (!d.subscriptionValid) {
          showSnack(context, t.subscriptionBlocked);
          return;
        }
        final position = await LocationService.currentPosition();
        await repo.setActive(d.uid, true, position: position);
      } else {
        await repo.setActive(d.uid, false);
      }
    } on LocationException catch (e) {
      if (mounted) showSnack(context, locationMessage(t, e.problem));
    } catch (_) {
      if (mounted) showSnack(context, t.genericError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _updatePosition(DriverProfile d) async {
    final t = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final position = await LocationService.currentPosition();
      await ref.read(driverRepositoryProvider).updateLocation(d.uid, position);
      if (mounted) showSnack(context, t.positionUpdatedOk);
    } on LocationException catch (e) {
      if (mounted) showSnack(context, locationMessage(t, e.problem));
    } catch (_) {
      if (mounted) showSnack(context, t.genericError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editCity(DriverProfile d) async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: d.city ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.editCity),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: t.city),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(t.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    try {
      await ref.read(driverRepositoryProvider).setCity(d.uid, value);
    } catch (_) {
      if (mounted) showSnack(context, t.genericError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final me = ref.watch(authStateProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    if (me == null) return const SizedBox.shrink();

    final async = ref.watch(driverProvider(me.uid));
    final billing =
        ref.watch(myBillingProvider).value ?? DriverBilling.empty(me.uid);
    final pending = ref.watch(pendingRequestsCountProvider);
    final unread = ref.watch(unreadMessagesCountProvider);

    return async.when(
      loading: () => const LoadingState(),
      error: (_, _) => const ErrorState(),
      data: (d) {
        if (d == null) {
          return EmptyState(
            icon: Icons.person_off_outlined,
            message: t.driverNotFound,
          );
        }

        // Un abonnement expire, suspendu ou bloque retire le livreur de la liste.
        if (d.active && !d.subscriptionValid && !_autoDeactivated) {
          _autoDeactivated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(driverRepositoryProvider)
                .setActive(d.uid, false)
                .catchError((_) {});
          });
        }

        final online = d.active && d.subscriptionValid;
        final banner = _billingBanner(t, d, billing);
        final firstName = (profile?.name ?? d.name).split(' ').first;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(t.hello(firstName), style: context.text.headlineMedium),
                ),
                RatingBadge(average: d.ratingAverage, count: d.ratingCount),
              ],
            ),
            const SizedBox(height: 16),
            if (banner != null) ...[banner, const SizedBox(height: 12)],
            _AvailabilityPanel(
              online: online,
              busy: _busy,
              onChanged: (v) => _setActive(d, v),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _CounterTile(
                      icon: Icons.inventory_2_outlined,
                      label: t.pendingRequestsLabel,
                      count: pending,
                      onTap: () => ref.read(homeTabProvider.notifier).select(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CounterTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: t.unreadMessagesLabel,
                      count: unread,
                      onTap: () => ref.read(homeTabProvider.notifier).select(3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _PlanCard(driver: d, billing: billing),
            const SizedBox(height: 12),
            const RevenueCard(),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsetsDirectional.fromSTEB(
                      16,
                      4,
                      8,
                      4,
                    ),
                    leading: const Icon(Icons.location_city_outlined),
                    title: Text(t.city),
                    subtitle: Text(
                      (d.city ?? '').isEmpty ? t.cityNotSet : d.city!,
                      style: context.text.bodyMedium,
                    ),
                    trailing: IconButton(
                      tooltip: t.editCity,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _editCity(d),
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    contentPadding: const EdgeInsetsDirectional.fromSTEB(
                      16,
                      4,
                      8,
                      4,
                    ),
                    leading: const Icon(Icons.my_location_rounded),
                    title: Text(t.myPosition),
                    subtitle: Text(
                      d.lastLocationUpdate == null
                          ? t.positionNeverShared
                          : '${t.positionUpdated} : ${formatDateTime(d.lastLocationUpdate!)}',
                    ),
                    trailing: IconButton(
                      tooltip: t.updateMyPosition,
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _busy ? null : () => _updatePosition(d),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Alerte de facturation la plus importante, ou null.
  Widget? _billingBanner(AppLocalizations t, DriverProfile d, DriverBilling b) {
    void open() => context.push('/driver/subscription');
    Widget button(String label) => OutlinedButton(
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
      onPressed: open,
      child: Text(label),
    );

    switch (d.effectiveStatus) {
      case 'suspended':
        return InfoBanner(
          tone: BannerTone.danger,
          title: t.subSuspended,
          message: t.suspendedMsg,
        );
      case 'blocked':
        return InfoBanner(
          tone: BannerTone.danger,
          title: t.debtBlockedTitle,
          message: t.debtBlockedMsg(formatAmount(b.debt)),
          action: button(t.payDebt),
        );
      case 'expired':
        return InfoBanner(
          tone: BannerTone.danger,
          title: t.subExpired,
          message: t.subscriptionExpiredMsg,
          action: button(t.choosePlan),
        );
      case 'per_delivery':
        if (b.nearLimit) {
          return InfoBanner(
            tone: BannerTone.warning,
            title: t.debtWarnTitle(formatAmount(b.debt)),
            message: t.debtWarnMsg('${b.deliveriesLeft}'),
            action: button(t.payDebt),
          );
        }
      case 'trial':
        if (d.daysLeft <= 7 && d.plan == null) {
          return InfoBanner(
            title: t.trialEndingTitle('${d.daysLeft}'),
            message: t.trialEndingMsg,
            action: button(t.choosePlan),
          );
        }
    }
    return null;
  }
}

/// Disponibilite : le moment fort du tableau de bord.
class _AvailabilityPanel extends StatelessWidget {
  const _AvailabilityPanel({
    required this.online,
    required this.busy,
    required this.onChanged,
  });

  final bool online;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bg = online
        ? (context.isDark ? const Color(0xFF12305F) : AppTheme.blue)
        : Theme.of(context).colorScheme.surface;
    final fg = online ? Colors.white : context.colors.onSurface;
    final sub = online ? Colors.white.withValues(alpha: 0.8) : context.muted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusHero),
        border: online
            ? null
            : Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (online) ...[
                const SpeedLines(width: 26),
                const SizedBox(width: 10),
              ] else ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: context.muted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  online ? t.statusActive : t.statusInactive,
                  style: context.text.headlineSmall?.copyWith(color: fg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            online ? t.activeHint : t.inactiveHint,
            style: context.text.bodyMedium?.copyWith(color: sub),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: online
                ? OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54, width: 1.5),
                    ),
                    onPressed: busy ? null : () => onChanged(false),
                    icon: const Icon(Icons.power_settings_new_rounded),
                    label: Text(t.deactivate),
                  )
                : FilledButton.icon(
                    style: AppTheme.confirmButton,
                    onPressed: busy ? null : () => onChanged(true),
                    icon: busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.power_settings_new_rounded),
                    label: Text(t.activate),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CounterTile extends StatelessWidget {
  const _CounterTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final highlight = count > 0;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$count', style: context.text.headlineMedium),
                    const SizedBox(height: 2),
                    Text(label, style: context.text.bodySmall),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: highlight
                      ? AppTheme.orange.withValues(alpha: 0.16)
                      : context.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: highlight
                      ? context.ink(AppTheme.orange)
                      : context.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formule en cours : essai, mensuel ou a la livraison (avec la dette).
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.driver, required this.billing});

  final DriverProfile driver;
  final DriverBilling billing;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final status = driver.effectiveStatus;
    final perDelivery = status == 'per_delivery' || status == 'blocked';

    final String detail;
    switch (status) {
      case 'trial':
        detail = t.daysLeft('${driver.daysLeft}');
      case 'paid':
        detail = t.expiresOn(formatDate(driver.subscriptionEnd!));
      case 'per_delivery':
      case 'blocked':
        detail = t.debtOfLimit(
          formatAmount(billing.debt),
          formatAmount(AppConfig.debtLimitDa),
        );
      default:
        detail = t.subscriptionExpiredMsg;
    }

    return Card(
      child: InkWell(
        onTap: () => context.push('/driver/subscription'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(t.myPlan, style: context.text.titleMedium),
                  ),
                  SubscriptionChip(status: status),
                ],
              ),
              const SizedBox(height: 8),
              Text(detail, style: context.text.bodyMedium),
              if (perDelivery) ...[
                const SizedBox(height: 12),
                DebtMeter(billing: billing),
              ],
              const SizedBox(height: 4),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: () => context.push('/driver/subscription'),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(t.manageSubscription),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Jauge de dette (formule a la livraison) : orange, rouge a l'approche du plafond.
class DebtMeter extends StatelessWidget {
  const DebtMeter({super.key, required this.billing, this.height = 10});

  final DriverBilling billing;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = billing.nearLimit ? AppTheme.danger : AppTheme.orange;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: billing.debtRatio,
        minHeight: height,
        color: color,
        backgroundColor: context.surfaceAlt,
      ),
    );
  }
}
