import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/map_links.dart';
import '../../l10n/app_localizations.dart';
import '../../models/delivery_request.dart';
import '../../models/driver_profile.dart';
import '../../models/subscription_claim.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/snack.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../auth/auth_providers.dart';
import '../auth/models/user_profile.dart';
import 'admin_providers.dart';
import 'admin_repository.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final admin = ref.watch(isAdminProvider);

    return admin.when(
      loading: () => const Scaffold(body: LoadingState()),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: Text(t.adminPanel)),
        body: const ErrorState(),
      ),
      data: (isAdmin) {
        if (!isAdmin) {
          return Scaffold(
            appBar: AppBar(title: Text(t.adminPanel)),
            body: EmptyState(icon: Icons.lock_outline, message: t.accessDenied),
          );
        }
        final claimsCount = ref.watch(adminClaimsProvider).value?.length ?? 0;

        return DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: Text(t.adminPanel),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: AppTheme.orange,
                tabs: [
                  Tab(text: t.adminDrivers),
                  Tab(
                    child: Badge(
                      label: Text('$claimsCount'),
                      isLabelVisible: claimsCount > 0,
                      offset: const Offset(10, -6),
                      child: Text(t.adminPayments),
                    ),
                  ),
                  Tab(text: t.adminClients),
                  Tab(text: t.adminRequests),
                  Tab(text: t.adminAdmins),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                _DriversAdminTab(),
                _ClaimsAdminTab(),
                _ClientsAdminTab(),
                _RequestsAdminTab(),
                _AdminsAdminTab(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Livreurs

enum _DriverAction { extend, suspend, unsuspend, deactivate, call }

class _DriversAdminTab extends ConsumerWidget {
  const _DriversAdminTab();

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    DriverProfile d,
    _DriverAction action,
  ) async {
    final t = AppLocalizations.of(context)!;
    final repo = ref.read(adminRepositoryProvider);
    try {
      switch (action) {
        case _DriverAction.extend:
          await repo.extend(d.uid);
          if (context.mounted) showSnack(context, t.adminExtended);
        case _DriverAction.suspend:
          await repo.suspend(d.uid);
        case _DriverAction.unsuspend:
          await repo.unsuspend(d);
        case _DriverAction.deactivate:
          await repo.deactivate(d.uid);
        case _DriverAction.call:
          if (context.mounted) {
            await launchWithFeedback(context, callPhone(d.phone));
          }
      }
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
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(icon: Icons.two_wheeler, message: t.adminNoDrivers);
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final d = list[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
                child: Row(
                  children: [
                    DriverAvatar(photo: d.photo, radius: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(prettyPhone(d.phone)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              StatusChip(
                                label: d.active
                                    ? t.statusActive
                                    : t.statusInactive,
                                color: d.active
                                    ? AppTheme.success
                                    : AppTheme.neutral,
                                icon: Icons.circle,
                              ),
                              SubscriptionChip(status: d.effectiveStatus),
                            ],
                          ),
                          if (d.subscriptionEnd != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                t.expiresOn(formatDate(d.subscriptionEnd!)),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<_DriverAction>(
                      onSelected: (a) => _run(context, ref, d, a),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: _DriverAction.extend,
                          child: _MenuRow(
                            Icons.add_circle_outline,
                            t.adminExtend,
                          ),
                        ),
                        if (d.isSuspended)
                          PopupMenuItem(
                            value: _DriverAction.unsuspend,
                            child: _MenuRow(
                              Icons.play_circle_outline,
                              t.adminUnsuspend,
                            ),
                          )
                        else
                          PopupMenuItem(
                            value: _DriverAction.suspend,
                            child: _MenuRow(
                              Icons.pause_circle_outline,
                              t.adminSuspend,
                            ),
                          ),
                        if (d.active)
                          PopupMenuItem(
                            value: _DriverAction.deactivate,
                            child: _MenuRow(
                              Icons.power_settings_new,
                              t.deactivate,
                            ),
                          ),
                        PopupMenuItem(
                          value: _DriverAction.call,
                          child: _MenuRow(Icons.call, t.call),
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

class _MenuRow extends StatelessWidget {
  const _MenuRow(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Flexible(child: Text(label)),
      ],
    );
  }
}

// ---------------------------------------------------------------- Paiements

class _ClaimsAdminTab extends ConsumerWidget {
  const _ClaimsAdminTab();

  Future<void> _review(
    BuildContext context,
    WidgetRef ref,
    SubscriptionClaim c, {
    required bool approve,
  }) async {
    final t = AppLocalizations.of(context)!;
    final repo = ref.read(adminRepositoryProvider);
    try {
      if (approve) {
        await repo.approveClaim(c);
        if (context.mounted) showSnack(context, t.adminExtended);
      } else {
        await repo.rejectClaim(c);
      }
    } catch (_) {
      if (context.mounted) showSnack(context, t.genericError);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final async = ref.watch(adminClaimsProvider);

    return async.when(
      loading: () => const LoadingState(),
      error: (_, __) => const ErrorState(),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.payments_outlined,
            message: t.adminNoClaims,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final c = list[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.driverName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(prettyPhone(c.driverPhone)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(c.reference)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDateTime(c.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.danger,
                            ),
                            onPressed: () =>
                                _review(context, ref, c, approve: false),
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
                            onPressed: () =>
                                _review(context, ref, c, approve: true),
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

// ---------------------------------------------------------------- Clients

class _ClientsAdminTab extends ConsumerWidget {
  const _ClientsAdminTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final async = ref.watch(adminClientsProvider);

    return async.when(
      loading: () => const LoadingState(),
      error: (_, __) => const ErrorState(),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.people_outline,
            message: t.adminNoClients,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final UserProfile u = list[i];
            return Card(
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: DriverAvatar(
                  photo: u.photo,
                  radius: 20,
                  icon: Icons.person,
                ),
                title: Text(u.name),
                subtitle: Text('${prettyPhone(u.phone)}\n${u.email}'),
                isThreeLine: true,
                trailing: IconButton(
                  tooltip: t.call,
                  icon: const Icon(Icons.call),
                  onPressed: () =>
                      launchWithFeedback(context, callPhone(u.phone)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Demandes

class _RequestsAdminTab extends ConsumerWidget {
  const _RequestsAdminTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final async = ref.watch(adminRequestsProvider);

    return async.when(
      loading: () => const LoadingState(),
      error: (_, __) => const ErrorState(),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            message: t.noRequestsClient,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => _AdminRequestTile(request: list[i]),
        );
      },
    );
  }
}

class _AdminRequestTile extends StatelessWidget {
  const _AdminRequestTile({required this.request});

  final DeliveryRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String addr(String a) => a.isEmpty ? '-' : a;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${request.clientName}  >  ${request.driverName}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                RequestStatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.upload_outlined, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(addr(request.pickup.address))),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.home_outlined, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(addr(request.delivery.address))),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formatDateTime(request.createdAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Admins

class _AdminsAdminTab extends ConsumerStatefulWidget {
  const _AdminsAdminTab();

  @override
  ConsumerState<_AdminsAdminTab> createState() => _AdminsAdminTabState();
}

class _AdminsAdminTabState extends ConsumerState<_AdminsAdminTab> {
  final _emailCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final t = AppLocalizations.of(context)!;
    final email = _emailCtrl.text.trim();
    if (!email.contains('@') || email.length < 5) {
      showSnack(context, t.adminEmailInvalid);
      return;
    }
    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    setState(() => _busy = true);
    try {
      final result = await ref
          .read(adminRepositoryProvider)
          .addAdminByEmail(email, me.uid);
      if (!mounted) return;
      switch (result) {
        case AddAdminResult.added:
          _emailCtrl.clear();
          showSnack(context, t.adminAdded);
        case AddAdminResult.notFound:
          showSnack(context, t.adminUserNotFound);
        case AddAdminResult.alreadyAdmin:
          showSnack(context, t.adminAlready);
      }
    } catch (_) {
      if (mounted) showSnack(context, t.genericError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(String uid) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.adminRemoveTitle),
        content: Text(t.adminRemoveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.yes),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminRepositoryProvider).removeAdmin(uid);
    } catch (_) {
      if (mounted) showSnack(context, t.genericError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final myUid = ref.watch(authStateProvider).value?.uid;
    final async = ref.watch(adminListProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.adminAddTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  t.adminAddHint,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: t.adminEmailLabel,
                    prefixIcon: const Icon(Icons.alternate_email),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _busy ? null : _add,
                  icon: _busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add_alt_1),
                  label: Text(t.adminAddButton),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(t.adminCurrent, style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        async.when(
          loading: () =>
              const Padding(padding: EdgeInsets.all(24), child: LoadingState()),
          error: (_, __) =>
              const Padding(padding: EdgeInsets.all(24), child: ErrorState()),
          data: (list) => Column(
            children: [
              for (final a in list) ...[
                _AdminTile(
                  entry: a,
                  isMe: a.uid == myUid,
                  onRemove: () => _remove(a.uid),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminTile extends ConsumerWidget {
  const _AdminTile({
    required this.entry,
    required this.isMe,
    required this.onRemove,
  });

  final AdminEntry entry;
  final bool isMe;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final profile = ref.watch(adminUserProvider(entry.uid)).value;
    final name = (profile?.name.isNotEmpty ?? false)
        ? profile!.name
        : entry.uid;
    final email = (profile?.email.isNotEmpty ?? false)
        ? profile!.email
        : entry.email;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.admin_panel_settings_outlined),
        title: Text(name),
        subtitle: email.isEmpty ? null : Text(email),
        trailing: isMe
            ? StatusChip(label: t.adminYou, color: AppTheme.success)
            : IconButton(
                tooltip: t.remove,
                icon: const Icon(Icons.person_remove_outlined),
                onPressed: onRemove,
              ),
      ),
    );
  }
}
