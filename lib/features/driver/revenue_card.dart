import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/revenue.dart';
import '../../l10n/app_localizations.dart';
import '../requests/request_providers.dart';

/// Chiffre d'affaires du livreur connecte, calcule a partir de ses livraisons
/// terminees (le montant est saisi a la fin de chaque course).
/// Le mois en cours est le chiffre principal ; les autres periodes suivent.
class RevenueCard extends ConsumerWidget {
  const RevenueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final requests = ref.watch(driverRequestsProvider).value ?? const [];
    final r = computeRevenue(requests);

    String da(int v) => t.amountDa(formatAmount(v));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.revenueTitle, style: context.text.titleMedium),
            const SizedBox(height: 12),
            Text(t.revenueMonth, style: context.text.labelMedium),
            const SizedBox(height: 2),
            Text(da(r.month), style: context.text.displaySmall),
            Text(
              t.revenueDeliveries('${r.monthDeliveries}'),
              style: context.text.bodySmall,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: context.surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusControl),
              ),
              child: Row(
                children: [
                  Expanded(child: _Figure(label: t.revenueToday, value: da(r.today))),
                  Expanded(child: _Figure(label: t.revenueWeek, value: da(r.week))),
                  Expanded(child: _Figure(label: t.revenueTotal, value: da(r.total))),
                ],
              ),
            ),
            if (r.withoutAmount > 0) ...[
              const SizedBox(height: 8),
              Text(
                t.revenueNoAmount('${r.withoutAmount}'),
                style: context.text.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: context.text.labelSmall, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: context.text.titleSmall),
        ),
      ],
    );
  }
}
