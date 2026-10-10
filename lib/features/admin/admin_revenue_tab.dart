import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/revenue.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/state_views.dart';
import 'admin_providers.dart';

/// Chiffre d'affaires de chaque livreur (livraisons terminees), avec le total
/// de tous les livreurs et un filtre par periode.
class AdminRevenueTab extends ConsumerStatefulWidget {
  const AdminRevenueTab({super.key});

  @override
  ConsumerState<AdminRevenueTab> createState() => _AdminRevenueTabState();
}

class _AdminRevenueTabState extends ConsumerState<AdminRevenueTab> {
  RevenuePeriod _period = RevenuePeriod.month;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final completed = ref.watch(adminCompletedRequestsProvider);
    final drivers = ref.watch(adminDriversProvider);

    if (completed.isLoading || drivers.isLoading) return const LoadingState();
    if (completed.hasError || drivers.hasError) return const ErrorState();

    final requests = completed.value ?? const [];
    final byDriver = computeRevenueByDriver(requests);
    final all = computeRevenue(requests);

    // Tous les livreurs (meme sans livraison), plus ceux dont le profil a disparu.
    final entries = <_Entry>[
      for (final d in drivers.value ?? const [])
        _Entry(
          uid: d.uid,
          name: d.name,
          photo: d.photo,
          summary: byDriver[d.uid] ?? const RevenueSummary(),
        ),
    ];
    final known = {for (final e in entries) e.uid};
    for (final e in byDriver.entries) {
      if (known.contains(e.key)) continue;
      final name = requests.firstWhere((r) => r.driverId == e.key).driverName;
      entries.add(_Entry(uid: e.key, name: name, summary: e.value));
    }
    entries.sort((a, b) {
      final c = b.summary
          .amountFor(_period)
          .compareTo(a.summary.amountFor(_period));
      return c != 0 ? c : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    String da(int v) => t.amountDa(formatAmount(v));
    String label(RevenuePeriod p) => switch (p) {
          RevenuePeriod.today => t.revenueToday,
          RevenuePeriod.week => t.revenueWeek,
          RevenuePeriod.month => t.revenueMonth,
          RevenuePeriod.total => t.revenueTotal,
        };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final p in RevenuePeriod.values)
              ChoiceChip(
                label: Text(label(p)),
                selected: _period == p,
                onSelected: (_) => setState(() => _period = p),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.adminRevenueAll, style: theme.textTheme.bodySmall),
                      Text(
                        da(all.amountFor(_period)),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                      Text(
                        t.revenueDeliveries('${all.deliveriesFor(_period)}'),
                        style:
                            theme.textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            message: t.adminNoRevenue,
          )
        else
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: DriverAvatar(photo: e.photo, radius: 20),
                  title: Text(e.name, style: theme.textTheme.titleMedium),
                  subtitle: Text(
                    t.revenueDeliveries('${e.summary.deliveriesFor(_period)}'),
                  ),
                  trailing: Text(
                    da(e.summary.amountFor(_period)),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _Entry {
  const _Entry({
    required this.uid,
    required this.name,
    required this.summary,
    this.photo,
  });

  final String uid;
  final String name;
  final String? photo;
  final RevenueSummary summary;
}
