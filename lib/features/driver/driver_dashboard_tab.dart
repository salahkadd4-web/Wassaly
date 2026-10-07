import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/driver_profile.dart';
import '../../services/location_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/snack.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../auth/auth_providers.dart';
import '../chat/chat_providers.dart';
import '../common/home_tab_provider.dart';
import '../drivers/driver_providers.dart';
import '../requests/request_providers.dart';

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
          decoration: InputDecoration(
            labelText: t.city,
            prefixIcon: const Icon(Icons.location_city),
          ),
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
    final theme = Theme.of(context);
    final me = ref.watch(authStateProvider).value;
    final profile = ref.watch(userProfileProvider).value;
    if (me == null) return const SizedBox.shrink();

    final async = ref.watch(driverProvider(me.uid));
    final pending = ref.watch(pendingRequestsCountProvider);
    final unread = ref.watch(unreadMessagesCountProvider);

    return async.when(
      loading: () => const LoadingState(),
      error: (_, __) => const ErrorState(),
      data: (d) {
        if (d == null) {
          return EmptyState(
            icon: Icons.person_off_outlined,
            message: t.driverNotFound,
          );
        }

        // Un abonnement expire ou suspendu retire automatiquement le livreur de la liste.
        if (d.active && !d.subscriptionValid && !_autoDeactivated) {
          _autoDeactivated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(driverRepositoryProvider)
                .setActive(d.uid, false)
                .catchError((_) {});
          });
        }

        final active = d.active && d.subscriptionValid;
        final statusColor = active ? AppTheme.success : AppTheme.neutral;
        final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              t.hello(profile?.name ?? d.name),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // --- Disponibilite ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      t.yourAvailability,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        active ? Icons.two_wheeler : Icons.pause,
                        size: 42,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      active ? t.statusActive : t.statusInactive,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      active ? t.activeHint : t.inactiveHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: active
                          ? OutlinedButton.icon(
                              onPressed: _busy
                                  ? null
                                  : () => _setActive(d, false),
                              icon: const Icon(Icons.power_settings_new),
                              label: Text(t.deactivate),
                            )
                          : FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.success,
                              ),
                              onPressed: _busy
                                  ? null
                                  : () => _setActive(d, true),
                              icon: _busy
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.power_settings_new),
                              label: Text(t.activate),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // --- Position ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (d.city ?? '').isEmpty ? t.cityNotSet : d.city!,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          tooltip: t.editCity,
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _editCity(d),
                        ),
                      ],
                    ),
                    if (d.lastLocationUpdate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${t.positionUpdated} : ${formatDateTime(d.lastLocationUpdate!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _updatePosition(d),
                      icon: const Icon(Icons.my_location),
                      label: Text(t.updateMyPosition),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // --- Compteurs ---
            Row(
              children: [
                Expanded(
                  child: _CounterCard(
                    icon: Icons.inventory_2_outlined,
                    label: t.tabRequests,
                    count: pending,
                    onTap: () => ref.read(homeTabProvider.notifier).select(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CounterCard(
                    icon: Icons.chat_bubble_outline,
                    label: t.messages,
                    count: unread,
                    onTap: () => ref.read(homeTabProvider.notifier).select(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- Abonnement ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.workspace_premium_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.subscription,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        SubscriptionChip(status: d.effectiveStatus),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (d.subscriptionEnd != null)
                      Text(
                        t.expiresOn(formatDate(d.subscriptionEnd!)),
                        style: theme.textTheme.bodyMedium,
                      ),
                    if (d.subscriptionValid)
                      Text(
                        t.daysLeft('${d.daysLeft}'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          t.subscriptionExpiredMsg,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.danger,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: d.subscriptionValid && d.daysLeft > 7
                          ? OutlinedButton.icon(
                              onPressed: () =>
                                  context.push('/driver/subscription'),
                              icon: const Icon(Icons.payments_outlined),
                              label: Text(t.manageSubscription),
                            )
                          : FilledButton.icon(
                              onPressed: () =>
                                  context.push('/driver/subscription'),
                              icon: const Icon(Icons.autorenew),
                              label: Text(t.renewSubscription),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({
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
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: count > 0 ? AppTheme.orange : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
