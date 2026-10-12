import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../services/location_service.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../drivers/driver_providers.dart';
import '../location/location_provider.dart';
import '../reports/report_sheet.dart';
import 'drivers_tab.dart';

/// Fiche d'un livreur, vue par le client. Le numero n'est pas affiche :
/// il est partage une fois la demande acceptee.
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
        error: (_, _) => const ErrorState(),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Center(child: DriverAvatar(photo: d.photo, name: d.name, radius: 44)),
              const SizedBox(height: 14),
              Text(
                d.name,
                textAlign: TextAlign.center,
                style: context.text.headlineSmall,
              ),
              const SizedBox(height: 8),
              Center(
                child: StatusChip(
                  label: available ? t.available : t.unavailable,
                  color: available ? AppTheme.success : AppTheme.neutral,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: context.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                ),
                child: Column(
                  children: [
                    if (km != null)
                      _InfoRow(
                        icon: Icons.near_me_outlined,
                        label: t.distance,
                        value: formatDistance(km, comma: comma),
                      ),
                    if ((d.city ?? '').isNotEmpty)
                      _InfoRow(
                        icon: Icons.location_city_outlined,
                        label: t.city,
                        value: d.city!,
                      ),
                    if (d.lastLocationUpdate != null)
                      _InfoRow(
                        icon: Icons.update_rounded,
                        label: t.positionUpdated,
                        value: formatDateTime(d.lastLocationUpdate!),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              InfoBanner(
                icon: Icons.lock_outline_rounded,
                message: t.phoneAfterAccept,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: AppTheme.goButton,
                onPressed:
                    available ? () => context.push('/client/request/${d.uid}') : null,
                icon: const Icon(Icons.send_rounded),
                label: Text(t.sendRequest),
              ),
              if (!available) ...[
                const SizedBox(height: 8),
                Text(
                  t.driverNotAvailableHint,
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall,
                ),
              ],
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => openChatWithDriver(context, ref, d),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: Text(t.message),
              ),
              const SizedBox(height: 16),
              Center(
                child: ReportDriverLink(driverId: d.uid, driverName: d.name),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.muted),
          const SizedBox(width: 12),
          Text(label, style: context.text.bodyMedium?.copyWith(color: context.muted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              // Distances, dates : toujours "700 m", meme en arabe.
              textDirection: TextDirection.ltr,
              textAlign: Directionality.of(context) == TextDirection.rtl
                  ? TextAlign.start
                  : TextAlign.end,
              style: context.text.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
