import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/delivery_request.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/state_views.dart';
import '../requests/request_card.dart';
import '../requests/request_providers.dart';

/// Demandes du livreur : a traiter, en cours, puis l'historique.
class DriverRequestsTab extends ConsumerWidget {
  const DriverRequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final requests = ref.watch(driverRequestsProvider);

    return requests.when(
      loading: () => const LoadingState(),
      error: (_, _) => const ErrorState(),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            title: t.noRequestsTitle,
            message: t.noRequestsDriver,
          );
        }
        final pending = list.where((r) => r.isPending).toList();
        final current = list.where((r) => r.isAccepted).toList();
        final past = list.where((r) => !r.isOpen).toList();

        List<Widget> section(String title, List<DeliveryRequest> items) => [
              SectionHeader(title: title, count: items.length),
              for (final r in items) ...[
                RequestCard(request: r, asDriver: true),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
            ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            if (pending.isNotEmpty) ...section(t.toHandleRequests, pending),
            if (current.isNotEmpty) ...section(t.currentRequests, current),
            if (past.isNotEmpty) ...section(t.pastRequests, past),
          ],
        );
      },
    );
  }
}
