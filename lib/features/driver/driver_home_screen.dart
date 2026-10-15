import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/delivery_request.dart';
import '../../models/open_request.dart';
import '../../widgets/app_bar_actions.dart';
import '../../widgets/exit_confirm_scope.dart';
import '../../widgets/logo_mark.dart';
import '../../widgets/snack.dart';
import '../chat/chat_providers.dart';
import '../chat/conversations_tab.dart';
import '../common/home_tab_provider.dart';
import '../notifications/push_providers.dart';
import '../open_requests/driver_open_requests_tab.dart';
import '../open_requests/open_request_providers.dart';
import '../requests/request_providers.dart';
import 'driver_dashboard_tab.dart';
import 'driver_requests_tab.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final index = ref.watch(homeTabProvider);
    final unread = ref.watch(unreadMessagesCountProvider);
    final pending = ref.watch(pendingRequestsCountProvider);
    final openCount = ref.watch(openRequestsCountProvider);

    // Notifications push (application fermee ou en arriere-plan).
    ref.watch(pushProvider);

    // Notification dans l'application : nouvelle demande ou annulation.
    ref.listen<AsyncValue<List<DeliveryRequest>>>(driverRequestsProvider,
        (prev, next) {
      final before = prev?.value;
      final after = next.value;
      if (before == null || after == null) return;
      // Sans notifications push (offre gratuite), chaque etape de la
      // negociation est signalee dans l'application.
      final old = {for (final r in before) r.id: r};
      for (final r in after) {
        final p = old[r.id];
        if (p == null) {
          if (r.isPending) showSnack(context, t.notifNewRequest(r.clientName));
          continue;
        }
        if (r.isNegotiating &&
            r.lastBy == 'client' &&
            (p.lastBy != 'client' || p.price != r.price)) {
          showSnack(context, t.notifPriceProposed(r.clientName, '${r.price}'));
        } else if (p.status != r.status && r.isAccepted) {
          showSnack(context, t.notifOpenRequestTaken(r.clientName));
        } else if (p.status != r.status && r.status == RequestStatus.cancelled) {
          showSnack(context, t.notifRequestCancelled(r.clientName));
        }
      }
    });

    // Notification dans l'application : un client publie une demande ouverte.
    ref.listen<AsyncValue<List<OpenRequest>>>(driverOpenRequestsProvider,
        (prev, next) {
      final before = prev?.value;
      final after = next.value;
      if (before == null || after == null) return;
      final known = {for (final r in before) r.id};
      final recent = DateTime.now().subtract(const Duration(minutes: 2));
      final fresh = after.where(
        (r) => !known.contains(r.id) && r.createdAt.isAfter(recent),
      );
      if (fresh.isNotEmpty) showSnack(context, t.notifNewOpenRequest);
    });

    final titles = [t.appName, t.tabRequests, t.openRequestsTitle, t.messages];

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
          logo: const LogoMark(size: 32),
        ),
        actions: buildAppBarActions(context, ref),
      ),
      body: IndexedStack(
        index: index,
        children: const [
          DriverDashboardTab(),
          DriverRequestsTab(),
          DriverOpenRequestsTab(),
          ConversationsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(homeTabProvider.notifier).select(i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: t.tabHome,
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$pending'),
              isLabelVisible: pending > 0,
              child: const Icon(Icons.inventory_2_outlined),
            ),
            selectedIcon: Badge(
              label: Text('$pending'),
              isLabelVisible: pending > 0,
              child: const Icon(Icons.inventory_2),
            ),
            label: t.tabRequests,
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$openCount'),
              isLabelVisible: openCount > 0,
              child: const Icon(Icons.person_search_outlined),
            ),
            selectedIcon: Badge(
              label: Text('$openCount'),
              isLabelVisible: openCount > 0,
              child: const Icon(Icons.person_search),
            ),
            label: t.openRequestsTab,
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
    ));
  }
}
