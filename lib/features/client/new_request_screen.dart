import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/snack.dart';
import '../../widgets/state_views.dart';
import '../auth/auth_providers.dart';
import '../common/home_tab_provider.dart';
import '../drivers/driver_providers.dart';
import '../requests/request_providers.dart';
import '../requests/route_form.dart';

/// Demande de livraison envoyee a un livreur choisi.
class NewRequestScreen extends ConsumerWidget {
  const NewRequestScreen({super.key, required this.driverId});

  final String driverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final driverAsync = ref.watch(driverProvider(driverId));

    return Scaffold(
      appBar: AppBar(title: Text(t.newRequest)),
      body: driverAsync.when(
        loading: () => const LoadingState(),
        error: (_, _) => const ErrorState(),
        data: (driver) {
          if (driver == null) {
            return EmptyState(
              icon: Icons.person_off_outlined,
              message: t.driverNotFound,
            );
          }
          return RouteForm(
            header: Row(
              children: [
                DriverAvatar(photo: driver.photo, name: driver.name, radius: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.requestTo, style: context.text.labelMedium),
                      const SizedBox(height: 2),
                      Text(driver.name, style: context.text.headlineSmall),
                    ],
                  ),
                ),
              ],
            ),
            submitLabel: t.sendToDriver,
            submitIcon: Icons.send_rounded,
            onSubmit: (course) async {
              final user = ref.read(authStateProvider).value;
              final profile = ref.read(userProfileProvider).value;
              if (user == null || profile == null) return;
              await ref.read(requestRepositoryProvider).create(
                    clientId: user.uid,
                    clientName: profile.name,
                    driverId: driver.uid,
                    driverName: driver.name,
                    course: course,
                  );
              if (!context.mounted) return;
              ref.read(homeTabProvider.notifier).select(1);
              showSnack(context, t.requestSent);
              context.go('/client');
            },
          );
        },
      ),
    );
  }
}
