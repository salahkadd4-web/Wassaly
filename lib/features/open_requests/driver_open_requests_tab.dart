import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/state_views.dart';
import '../auth/auth_providers.dart';
import '../drivers/driver_providers.dart';
import 'open_request_card.dart';
import 'open_request_providers.dart';

/// Onglet livreur : clients qui cherchent un livreur (demandes ouvertes).
/// Reserve aux livreurs dont l'abonnement (essai ou paye) est valide.
class DriverOpenRequestsTab extends ConsumerWidget {
  const DriverOpenRequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const LoadingState();

    final driver = ref.watch(driverProvider(user.uid));
    if (driver.isLoading && !driver.hasValue) return const LoadingState();

    final profile = driver.value;
    if (profile == null || !profile.subscriptionValid) {
      return EmptyState(
        icon: Icons.lock_outline,
        message: t.openRequestsLocked,
        action: FilledButton(
          onPressed: () => context.push('/driver/subscription'),
          child: Text(t.manageSubscription),
        ),
      );
    }

    final requests = ref.watch(driverOpenRequestsProvider);
    return requests.when(
      loading: () => const LoadingState(),
      error: (_, __) => const ErrorState(),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.person_search_outlined,
            message: t.noOpenRequests,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) =>
              OpenRequestCard(request: list[i], asDriver: true),
        );
      },
    );
  }
}
