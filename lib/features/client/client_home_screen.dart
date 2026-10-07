import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/delivery_request.dart';
import '../../widgets/app_bar_actions.dart';
import '../../widgets/exit_confirm_scope.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/snack.dart';
import '../chat/chat_providers.dart';
import '../chat/conversations_tab.dart';
import '../common/home_tab_provider.dart';
import '../requests/request_providers.dart';
import 'client_requests_tab.dart';
import 'drivers_tab.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final index = ref.watch(homeTabProvider);
    final unread = ref.watch(unreadMessagesCountProvider);

    // Notification dans l'application quand un livreur repond a une demande.
    ref.listen<AsyncValue<List<DeliveryRequest>>>(clientRequestsProvider, (
      prev,
      next,
    ) {
      final before = prev?.value;
      final after = next.value;
      if (before == null || after == null) return;
      final old = {for (final r in before) r.id: r.status};
      for (final r in after) {
        final previous = old[r.id];
        if (previous == null || previous == r.status) continue;
        if (r.status == RequestStatus.accepted) {
          showSnack(context, t.notifRequestAccepted(r.driverName));
        } else if (r.status == RequestStatus.rejected) {
          showSnack(context, t.notifRequestRejected(r.driverName));
        } else if (r.status == RequestStatus.completed) {
          showSnack(context, t.notifRequestCompleted);
        }
      }
    });

    final titles = [t.driversNearby, t.myRequests, t.messages];

    return ExitConfirmScope(
      onBack: () {
        if (index != 0) {
          ref.read(homeTabProvider.notifier).select(0);
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: BrandTitle(
            title: titles[index],
            logo: const LogoMark(size: 34),
          ),
          actions: buildAppBarActions(context, ref),
        ),
        body: IndexedStack(
          index: index,
          children: const [
            DriversTab(),
            ClientRequestsTab(),
            ConversationsTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) =>
              ref.read(homeTabProvider.notifier).select(i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.two_wheeler_outlined),
              selectedIcon: const Icon(Icons.two_wheeler),
              label: t.tabDrivers,
            ),
            NavigationDestination(
              icon: const Icon(Icons.inventory_2_outlined),
              selectedIcon: const Icon(Icons.inventory_2),
              label: t.tabRequests,
            ),
            NavigationDestination(
              icon: Badge(
                label: Text('$unread'),
                isLabelVisible: unread > 0,
                child: const Icon(Icons.chat_bubble_outline),
              ),
              selectedIcon: Badge(
                label: Text('$unread'),
                isLabelVisible: unread > 0,
                child: const Icon(Icons.chat_bubble),
              ),
              label: t.messages,
            ),
          ],
        ),
      ),
    );
  }
}
