import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/map_links.dart';
import '../../l10n/app_localizations.dart';
import '../../models/driver_billing.dart';
import '../../models/driver_profile.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/snack.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../reports/report_repository.dart';
import 'admin_providers.dart';

/// Livreurs au comportement anormal (voir suspicionReasons) : annulations,
/// conversations sans livraisons, signalements, dette impayee.
class AdminSuspectsTab extends ConsumerWidget {
  const AdminSuspectsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final drivers = ref.watch(adminDriversProvider);
    final billing = ref.watch(adminBillingProvider).value ?? const {};
    final reports = ref.watch(adminReportsProvider).value ?? const {};

    return drivers.when(
      loading: () => const LoadingState(),
      error: (_, _) => const ErrorState(),
      data: (list) {
        final suspects = <(DriverProfile, DriverBilling, List<SuspicionReason>)>[];
        for (final d in list) {
          final b = billing[d.uid] ?? DriverBilling.empty(d.uid);
          final reasons = suspicionReasons(b);
          if (reasons.isNotEmpty) suspects.add((d, b, reasons));
        }
        suspects.sort((a, b) => b.$3.length.compareTo(a.$3.length));

        if (suspects.isEmpty) {
          return EmptyState(
            icon: Icons.verified_user_outlined,
            title: t.adminNoSuspectsTitle,
            message: t.adminNoSuspects,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: suspects.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final (d, b, reasons) = suspects[i];
            return _SuspectCard(
              driver: d,
              billing: b,
              reasons: reasons,
              reports: reports[d.uid] ?? const [],
            );
          },
        );
      },
    );
  }
}

class _SuspectCard extends ConsumerWidget {
  const _SuspectCard({
    required this.driver,
    required this.billing,
    required this.reasons,
    required this.reports,
  });

  final DriverProfile driver;
  final DriverBilling billing;
  final List<SuspicionReason> reasons;
  final List<DriverReport> reports;

  String _reason(AppLocalizations t, SuspicionReason r) {
    final s = billing.stats;
    return switch (r) {
      SuspicionReason.cancellations =>
        t.suspectCancellations('${s.cancelledAfterAccept}', '${s.accepted}'),
      SuspicionReason.chatsWithoutDeliveries =>
        t.suspectChats('${s.conversations}', '${s.accepted}'),
      SuspicionReason.reports => t.suspectReports('${s.reports}'),
      SuspicionReason.unpaidDebt => t.suspectDebt(formatAmount(billing.debt)),
    };
  }

  String _reportReason(AppLocalizations t, String reason) => switch (reason) {
        ReportReason.offApp => t.reportReasonOffApp,
        ReportReason.notDelivered => t.reportReasonNotDelivered,
        ReportReason.behavior => t.reportReasonBehavior,
        _ => t.reportReasonOther,
      };

  Future<void> _toggleSuspend(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    try {
      final repo = ref.read(adminRepositoryProvider);
      if (driver.isSuspended) {
        await repo.unsuspend(driver);
      } else {
        await repo.suspend(driver.uid);
      }
    } catch (_) {
      if (context.mounted) showSnack(context, t.genericError);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final s = billing.stats;
    final phone = ref.watch(adminUserProvider(driver.uid)).value?.phone ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DriverAvatar(photo: driver.photo, name: driver.name, radius: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.name, style: context.text.titleMedium),
                      if (phone.isNotEmpty)
                        Text(prettyPhone(phone), style: context.text.bodySmall),
                    ],
                  ),
                ),
                SubscriptionChip(status: driver.effectiveStatus),
              ],
            ),
            const SizedBox(height: 14),
            for (final r in reasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 18, color: context.ink(AppTheme.orange)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_reason(t, r), style: context.text.bodyMedium)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: context.surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusControl),
              ),
              child: Row(
                children: [
                  _Stat(value: s.accepted, label: t.statAccepted),
                  _Stat(value: s.completed, label: t.statCompleted),
                  _Stat(value: s.cancelledAfterAccept, label: t.statCancelled),
                  _Stat(value: s.conversations, label: t.statChats),
                  _Stat(value: s.reports, label: t.statReports),
                ],
              ),
            ),
            if (reports.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(t.reportsTitle, style: context.text.titleSmall),
              const SizedBox(height: 4),
              for (final r in reports.take(3))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text.rich(
                    TextSpan(
                      text: '${_reportReason(t, r.reason)} ',
                      style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: r.note.isEmpty
                              ? formatDate(r.createdAt)
                              : '${r.note} (${formatDate(r.createdAt)})',
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: context.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                if (phone.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchWithFeedback(context, callPhone(phone)),
                      icon: const Icon(Icons.call_outlined, size: 18),
                      label: Text(t.call),
                    ),
                  ),
                if (phone.isNotEmpty) const SizedBox(width: 8),
                Expanded(
                  child: driver.isSuspended
                      ? FilledButton(
                          onPressed: () => _toggleSuspend(context, ref),
                          child: Text(t.adminUnsuspend),
                        )
                      : OutlinedButton(
                          style: AppTheme.dangerOutlined(context),
                          onPressed: () => _toggleSuspend(context, ref),
                          child: Text(t.adminSuspend),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: context.text.titleMedium),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: context.text.labelSmall, maxLines: 1),
          ),
        ],
      ),
    );
  }
}
