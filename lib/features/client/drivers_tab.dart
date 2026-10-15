import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ratings/rating_sheet.dart';
import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chat.dart';
import '../../models/driver_profile.dart';
import '../../services/location_service.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/section_header.dart';
import '../../widgets/snack.dart';
import '../../widgets/state_views.dart';
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

/// Accueil du client : publier une course, ou choisir un livreur proche.
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
    final count = drivers.value?.length;

    return RefreshIndicator(
      onRefresh: () => ref.read(clientLocationProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(
            t.hello(profile?.name.split(' ').first ?? ''),
            style: context.text.headlineMedium,
          ),
          const SizedBox(height: 16),
          const _PublishHero(),
          const SizedBox(height: 24),
          SectionHeader(title: t.driversNearby, count: count),
          if (location.loading && location.position == null)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
          if (location.problem != null && location.position == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LocationBanner(problem: location.problem!),
            ),
          // Sans position, impossible de chercher dans le rayon : le bandeau
          // ci-dessus explique quoi faire, la course ouverte reste possible.
          if (location.position == null && location.problem != null)
            const SizedBox.shrink()
          else if (location.position == null)
            const Padding(padding: EdgeInsets.all(32), child: LoadingState())
          else
            drivers.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: LoadingState(),
              ),
              error: (_, _) => const SizedBox(height: 240, child: ErrorState()),
              data: (list) {
                if (list.isEmpty) {
                  return SizedBox(
                    height: 260,
                    child: EmptyState(
                      icon: Icons.two_wheeler,
                      message: t.noDriversInRadius(
                        '${AppConfig.searchRadiusKm.round()}',
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final item in list) ...[
                      _DriverCard(item: item, comma: comma),
                      const SizedBox(height: 10),
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

/// Carte principale du client : publier une course a tous les livreurs.
class _PublishHero extends StatelessWidget {
  const _PublishHero();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF12305F) : AppTheme.blue,
        borderRadius: BorderRadius.circular(AppTheme.radiusHero),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  t.publishHeroTitle,
                  style: context.text.titleLarge?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const _MiniRoute(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            t.publishOpenRequestHint,
            style: context.text.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: AppTheme.goButton,
            onPressed: () => context.push('/client/open-request'),
            icon: const Icon(Icons.campaign_rounded),
            label: Text(t.publishOpenRequest),
          ),
        ],
      ),
    );
  }
}

/// Petit trace de course decoratif (depart orange -> arrivee).
class _MiniRoute extends StatelessWidget {
  const _MiniRoute();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: 22,
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.orange, width: 3.5),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < 4; i++)
                  Container(width: 2, height: 4, color: Colors.white54),
              ],
            ),
          ),
          const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}

class _LocationBanner extends ConsumerWidget {
  const _LocationBanner({required this.problem});

  final LocationProblem problem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return InfoBanner(
      tone: BannerTone.warning,
      icon: Icons.location_off_outlined,
      message: locationMessage(t, problem),
      action: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () =>
                ref.read(clientLocationProvider.notifier).refresh(),
            child: Text(t.retry),
          ),
          if (problem == LocationProblem.deniedForever ||
              problem == LocationProblem.serviceDisabled)
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed: problem == LocationProblem.deniedForever
                  ? LocationService.openAppSettings
                  : LocationService.openLocationSettings,
              child: Text(t.openSettings),
            ),
        ],
      ),
    );
  }
}

/// Livreur disponible : la distance, l'information qui decide, est mise en avant.
class _DriverCard extends ConsumerWidget {
  const _DriverCard({required this.item, required this.comma});

  final DriverWithDistance item;
  final bool comma;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final d = item.driver;
    final km = item.distanceKm;

    return Card(
      child: InkWell(
        onTap: () => context.push('/client/driver/${d.uid}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      DriverAvatar(photo: d.photo, name: d.name, radius: 24),
                      PositionedDirectional(
                        end: 0,
                        bottom: 0,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, style: context.text.titleMedium),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                (d.city ?? '').isNotEmpty ? d.city! : t.available,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodySmall,
                              ),
                            ),
                            if (d.ratingAverage != null) ...[
                              const SizedBox(width: 10),
                              RatingBadge(average: d.ratingAverage, count: d.ratingCount),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (km != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatDistance(km, comma: comma),
                          textDirection: TextDirection.ltr,
                          style: context.text.titleLarge,
                        ),
                        Text(t.distance, style: context.text.labelSmall),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 46),
                      ),
                      onPressed: () => context.push('/client/request/${d.uid}'),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: Text(t.sendRequestShort),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: t.message,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(46, 46),
                      backgroundColor: context.surfaceAlt,
                      foregroundColor: context.colors.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusControl,
                        ),
                      ),
                    ),
                    onPressed: () => openChatWithDriver(context, ref, d),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
