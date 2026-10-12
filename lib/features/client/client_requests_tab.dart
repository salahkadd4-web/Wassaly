import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/state_views.dart';
import '../open_requests/open_request_card.dart';
import '../open_requests/open_request_providers.dart';
import '../requests/request_card.dart';
import '../requests/request_providers.dart';

/// Demandes du client : en cours d'abord, puis l'historique.
class ClientRequestsTab extends ConsumerWidget {
  const ClientRequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final requests = ref.watch(clientRequestsProvider);
    final openAsync = ref.watch(clientOpenRequestsProvider);

    if (requests.isLoading && !requests.hasValue) return const LoadingState();
    if (requests.hasError && !requests.hasValue) return const ErrorState();

    final list = requests.value ?? const [];
    final openList = (openAsync.value ?? const []).where((r) => r.isOpen).toList();
    final current = list.where((r) => r.isOpen).toList();
    final past = list.where((r) => !r.isOpen).toList();

    if (list.isEmpty && openList.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: t.noRequestsTitle,
        message: t.noRequestsClient,
        action: FilledButton.icon(
          onPressed: () => context.push('/client/open-request'),
          icon: const Icon(Icons.campaign_rounded),
          label: Text(t.publishOpenRequest),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        if (openList.isNotEmpty) ...[
          SectionHeader(title: t.myOpenRequests, count: openList.length),
          for (final r in openList) ...[
            OpenRequestCard(request: r, asDriver: false),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
        ],
        if (current.isNotEmpty) ...[
          SectionHeader(title: t.currentRequests, count: current.length),
          for (final r in current) ...[
            RequestCard(request: r, asDriver: false),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
        ],
        if (past.isNotEmpty) ...[
          SectionHeader(title: t.pastRequests, count: past.length),
          for (final r in past) ...[
            RequestCard(request: r, asDriver: false),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}
