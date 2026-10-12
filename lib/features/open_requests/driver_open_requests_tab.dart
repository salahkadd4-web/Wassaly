import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_config.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/state_views.dart';
import '../auth/auth_providers.dart';
import '../drivers/driver_providers.dart';
import 'open_request_card.dart';
import 'open_request_providers.dart';

/// Onglet livreur : clients qui cherchent un livreur (demandes ouvertes).
/// Reserve aux livreurs qui peuvent travailler (essai, mois paye, ou formule
/// a la livraison sans dette bloquante).
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
      final blocked = profile?.effectiveStatus == 'blocked';
      return EmptyState(
        icon: Icons.lock_outline_rounded,
        title: blocked ? t.debtBlockedTitle : null,
        message: blocked ? t.openRequestsLockedDebt : t.openRequestsLocked,
        action: FilledButton(
          onPressed: () => context.push('/driver/subscription'),
          child: Text(blocked ? t.payDebt : t.manageSubscription),
        ),
      );
    }

    final requests = ref.watch(driverOpenRequestsProvider);
    return requests.when(
      loading: () => const LoadingState(),
      error: (_, _) => const ErrorState(),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.person_search_outlined,
            title: t.noOpenRequestsTitle,
            message: t.noOpenRequests,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: list.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            if (i == 0) {
              return InfoBanner(
                message: profile.isPerDeliveryMode
                    ? t.openRequestsIntroPaid('${AppConfig.perDeliveryPriceDa}')
                    : t.openRequestsIntro,
              );
            }
            return OpenRequestCard(request: list[i - 1], asDriver: true);
          },
        );
      },
    );
  }
}
