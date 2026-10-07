import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../services/location_service.dart';
import '../../widgets/contact_buttons.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../drivers/driver_providers.dart';
import '../location/location_provider.dart';
import 'drivers_tab.dart';

class DriverDetailScreen extends ConsumerWidget {
  const DriverDetailScreen({super.key, required this.driverId});

  final String driverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final async = ref.watch(driverProvider(driverId));
    final position = ref.watch(clientLocationProvider).position;
    final comma = Localizations.localeOf(context).languageCode == 'fr';

    return Scaffold(
      appBar: AppBar(title: Text(t.driverProfile)),
      body: async.when(
        loading: () => const LoadingState(),
        error: (_, __) => const ErrorState(),
        data: (d) {
          if (d == null) {
            return EmptyState(
              icon: Icons.person_off_outlined,
              message: t.driverNotFound,
            );
          }

          double? km;
          if (position != null && d.hasLocation) {
            km = LocationService.distanceKm(
              position.latitude,
              position.longitude,
              d.latitude!,
              d.longitude!,
            );
          }
          final available = d.isAvailable;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(child: DriverAvatar(photo: d.photo, radius: 48)),
              const SizedBox(height: 12),
              Text(
                d.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Center(
                child: StatusChip(
                  label: available ? t.available : t.unavailable,
                  color: available ? AppTheme.success : AppTheme.neutral,
                  icon: Icons.circle,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.phone,
                        label: t.phoneLabel,
                        value: prettyPhone(d.phone),
                      ),
                      if ((d.city ?? '').isNotEmpty)
                        _InfoRow(
                          icon: Icons.location_city,
                          label: t.city,
                          value: d.city!,
                        ),
                      if (km != null)
                        _InfoRow(
                          icon: Icons.near_me,
                          label: t.distance,
                          value: formatDistance(km, comma: comma),
                        ),
                      if (d.lastLocationUpdate != null)
                        _InfoRow(
                          icon: Icons.update,
                          label: t.positionUpdated,
                          value: formatDateTime(d.lastLocationUpdate!),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ContactButtons(
                phone: d.phone,
                onMessage: () => openChatWithDriver(context, ref, d),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: available
                    ? () => context.push('/client/request/${d.uid}')
                    : null,
                icon: const Icon(Icons.local_shipping_outlined),
                label: Text(t.sendRequest),
              ),
              if (!available) ...[
                const SizedBox(height: 8),
                Text(
                  t.driverNotAvailableHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
