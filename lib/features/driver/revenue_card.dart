import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/revenue.dart';
import '../../l10n/app_localizations.dart';
import '../requests/request_providers.dart';

/// Chiffre d'affaires du livreur connecte, calcule a partir de ses livraisons
/// terminees (le montant est saisi a la fin de chaque course).
class RevenueCard extends ConsumerWidget {
  const RevenueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final requests = ref.watch(driverRequestsProvider).value ?? const [];
    final r = computeRevenue(requests);

    String da(int v) => t.amountDa(formatAmount(v));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child:
                      Text(t.revenueTitle, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _Figure(label: t.revenueToday, value: da(r.today))),
                Expanded(child: _Figure(label: t.revenueWeek, value: da(r.week))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _Figure(label: t.revenueMonth, value: da(r.month))),
                Expanded(
                  child: _Figure(
                    label: t.revenueTotal,
                    value: da(r.total),
                    highlight: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              t.revenueDeliveries('${r.deliveries}'),
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            if (r.withoutAmount > 0)
              Text(
                t.revenueNoAmount('${r.withoutAmount}'),
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
          ],
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: highlight ? AppTheme.success : null,
          ),
        ),
      ],
    );
  }
}
