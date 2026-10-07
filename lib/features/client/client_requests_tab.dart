import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/state_views.dart';
import '../open_requests/open_request_card.dart';
import '../open_requests/open_request_providers.dart';
import '../requests/request_card.dart';
import '../requests/request_providers.dart';

class ClientRequestsTab extends ConsumerWidget {
  const ClientRequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final requests = ref.watch(clientRequestsProvider);
    final openAsync = ref.watch(clientOpenRequestsProvider);

    if (requests.isLoading && !requests.hasValue) return const LoadingState();
    if (requests.hasError && !requests.hasValue) return const ErrorState();

    final list = requests.value ?? const [];
    final openList = (openAsync.value ?? const []).where((r) => r.isOpen);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          onPressed: () => context.push('/client/open-request'),
          icon: const Icon(Icons.campaign_outlined),
          label: Text(t.publishOpenRequest),
        ),
        const SizedBox(height: 6),
        Text(
          t.publishOpenRequestHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        if (openList.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(t.myOpenRequests, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          for (final r in openList) ...[
            OpenRequestCard(request: r, asDriver: false),
            const SizedBox(height: 12),
          ],
        ],
        const SizedBox(height: 20),
        Text(t.sentRequests, style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              t.noRequestsClient,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: muted),
            ),
          )
        else
          for (final r in list) ...[
            RequestCard(request: r, asDriver: false),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}
