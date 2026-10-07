import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/state_views.dart';
import '../requests/request_card.dart';
import '../requests/request_providers.dart';

class DriverRequestsTab extends ConsumerWidget {
  const DriverRequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final requests = ref.watch(driverRequestsProvider);

    return requests.when(
      loading: () => const LoadingState(),
      error: (_, __) => const ErrorState(),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            message: t.noRequestsDriver,
          );
        }
        // Les demandes en attente d'abord, puis les acceptees, puis le reste.
        int rank(String s) => s == 'pending' ? 0 : (s == 'accepted' ? 1 : 2);
        final sorted = [...list]
          ..sort((a, b) {
            final r = rank(a.status).compareTo(rank(b.status));
            return r != 0 ? r : b.createdAt.compareTo(a.createdAt);
          });
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sorted.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) =>
              RequestCard(request: sorted[i], asDriver: true),
        );
      },
    );
  }
}
