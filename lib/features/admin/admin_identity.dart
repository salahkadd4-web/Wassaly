import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/driver_profile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/snack.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../verification/verification_providers.dart';
import 'admin_providers.dart';

/// Pastille : pending | approved | rejected.
class VerificationChip extends StatelessWidget {
  const VerificationChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    switch (status) {
      case 'pending':
        return StatusChip(
          label: t.verifChipPending,
          color: AppTheme.orange,
          icon: Icons.badge_outlined,
        );
      case 'rejected':
        return StatusChip(
          label: t.verifChipRejected,
          color: AppTheme.danger,
          icon: Icons.gpp_bad_outlined,
        );
      default:
        return StatusChip(
          label: t.verifChipVerified,
          color: AppTheme.success,
          icon: Icons.verified_user_outlined,
        );
    }
  }
}

/// Ouvre la piece d'identite d'un livreur en plein ecran (zoom possible).
void showIdViewer(BuildContext context, DriverProfile driver) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => _IdViewerScreen(driver: driver)),
  );
}

class _IdViewerScreen extends ConsumerWidget {
  const _IdViewerScreen({required this.driver});

  final DriverProfile driver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final async = ref.watch(driverIdentityProvider(driver.uid));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(driver.name)),
      body: async.when(
        loading: () => const LoadingState(),
        error: (_, __) => const ErrorState(),
        data: (identity) {
          if (identity == null || identity.idUrl.isEmpty) {
            return EmptyState(
              icon: Icons.image_not_supported_outlined,
              message: t.adminIdMissing,
            );
          }
          return InteractiveViewer(
            maxScale: 6,
            child: Center(
              child: Image.network(
                identity.idUrl,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, __, ___) => EmptyState(
                  icon: Icons.broken_image_outlined,
                  message: t.idImageUnavailable,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Onglet "Verifications" : livreurs dont la piece est en attente.
class AdminVerificationsTab extends ConsumerWidget {
  const AdminVerificationsTab({super.key});

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    DriverProfile d,
  ) async {
    final t = AppLocalizations.of(context)!;
    try {
      await ref.read(adminRepositoryProvider).approveIdentity(d.uid);
      if (context.mounted) showSnack(context, t.adminIdApproved);
    } catch (_) {
      if (context.mounted) showSnack(context, t.genericError);
    }
  }

  Future<void> _reject(
    BuildContext context,
    WidgetRef ref,
    DriverProfile d,
  ) async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.adminRejectIdTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 120,
          decoration: InputDecoration(labelText: t.adminRejectIdHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.reject),
          ),
        ],
      ),
    );
    final reason = controller.text;
    controller.dispose();
    if (ok != true) return;
    try {
      await ref
          .read(adminRepositoryProvider)
          .rejectIdentity(d.uid, reason: reason);
      if (context.mounted) showSnack(context, t.adminIdRejected);
    } catch (_) {
      if (context.mounted) showSnack(context, t.genericError);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final async = ref.watch(adminDriversProvider);

    return async.when(
      loading: () => const LoadingState(),
      error: (_, __) => const ErrorState(),
      data: (all) {
        final list = all.where((d) => d.isVerificationPending).toList();
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.verified_user_outlined,
            message: t.adminNoVerifications,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final d = list[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(prettyPhone(d.phone)),
                    const SizedBox(height: 12),
                    _IdPreview(driver: d),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.danger,
                            ),
                            onPressed: () => _reject(context, ref, d),
                            icon: const Icon(Icons.close),
                            label: Text(t.reject),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.success,
                            ),
                            onPressed: () => _approve(context, ref, d),
                            icon: const Icon(Icons.check),
                            label: Text(t.adminValidate),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _IdPreview extends ConsumerWidget {
  const _IdPreview({required this.driver});

  final DriverProfile driver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final async = ref.watch(driverIdentityProvider(driver.uid));

    return async.when(
      loading: () => const SizedBox(height: 180, child: LoadingState()),
      error: (_, __) => const SizedBox(height: 180, child: ErrorState()),
      data: (identity) {
        if (identity == null || identity.idUrl.isEmpty) {
          return SizedBox(
            height: 120,
            child: EmptyState(
              icon: Icons.image_not_supported_outlined,
              message: t.adminIdMissing,
            ),
          );
        }
        return InkWell(
          onTap: () => showIdViewer(context, driver),
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.network(
                identity.idUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, __, ___) => EmptyState(
                  icon: Icons.broken_image_outlined,
                  message: t.idImageUnavailable,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
