import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chat.dart';
import '../../models/driver_profile.dart';
import '../../services/location_service.dart';
import '../../widgets/contact_buttons.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/snack.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../auth/auth_providers.dart';
import '../chat/chat_repository.dart';
import '../drivers/driver_providers.dart';
import '../location/location_provider.dart';

/// Ouvre la discussion client -> livreur.
void openChatWithDriver(BuildContext context, WidgetRef ref, DriverProfile d) {
  final me = ref.read(authStateProvider).value;
  if (me == null) return;
  final myName = ref.read(userProfileProvider).value?.name ?? '';
  context.push(
    '/chat/${ChatRepository.idFor(me.uid, d.uid)}',
    extra: ChatArgs(clientName: myName, driverName: d.name),
  );
}

class DriversTab extends ConsumerStatefulWidget {
  const DriversTab({super.key});

  @override
  ConsumerState<DriversTab> createState() => _DriversTabState();
}

class _DriversTabState extends ConsumerState<DriversTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(clientLocationProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider).value;
    final location = ref.watch(clientLocationProvider);
    final drivers = ref.watch(nearbyDriversProvider);
    final comma = Localizations.localeOf(context).languageCode == 'fr';

    return RefreshIndicator(
      onRefresh: () => ref.read(clientLocationProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t.hello(profile?.name ?? ''),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            t.driversAvailableNearby,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (location.loading && location.position == null)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
          if (location.problem != null && location.position == null)
            _LocationBanner(problem: location.problem!),
          drivers.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: LoadingState(),
            ),
            error: (_, __) => const SizedBox(height: 240, child: ErrorState()),
            data: (list) {
              if (list.isEmpty) {
                return SizedBox(
                  height: 280,
                  child: EmptyState(
                    icon: Icons.two_wheeler,
                    message: t.noDriversAvailable,
                  ),
                );
              }
              return Column(
                children: [
                  for (final item in list) ...[
                    _DriverCard(item: item, comma: comma),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({required this.problem});

  final LocationProblem problem;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Consumer(
      builder: (context, ref, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_off, color: AppTheme.orange),
                      const SizedBox(width: 12),
                      Expanded(child: Text(locationMessage(t, problem))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            ref.read(clientLocationProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh),
                        label: Text(t.retry),
                      ),
                      if (problem == LocationProblem.deniedForever)
                        OutlinedButton.icon(
                          onPressed: LocationService.openAppSettings,
                          icon: const Icon(Icons.settings),
                          label: Text(t.openSettings),
                        ),
                      if (problem == LocationProblem.serviceDisabled)
                        OutlinedButton.icon(
                          onPressed: LocationService.openLocationSettings,
                          icon: const Icon(Icons.settings),
                          label: Text(t.openSettings),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DriverCard extends ConsumerWidget {
  const _DriverCard({required this.item, required this.comma});

  final DriverWithDistance item;
  final bool comma;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final d = item.driver;
    final km = item.distanceKm;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/client/driver/${d.uid}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  DriverAvatar(photo: d.photo),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            StatusChip(
                              label: t.available,
                              color: AppTheme.success,
                              icon: Icons.circle,
                            ),
                            if (km != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.near_me, size: 15, color: muted),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatDistance(km, comma: comma),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                            if ((d.city ?? '').isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_city,
                                    size: 15,
                                    color: muted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    d.city!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              ContactButtons(
                phone: d.phone,
                onMessage: () => openChatWithDriver(context, ref, d),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
