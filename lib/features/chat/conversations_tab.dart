import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chat.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/state_views.dart';
import '../auth/auth_providers.dart';
import 'chat_providers.dart';

/// Liste des conversations (identique pour le client et le livreur).
class ConversationsTab extends ConsumerWidget {
  const ConversationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final me = ref.watch(authStateProvider).value;
    final isDriver = ref.watch(userProfileProvider).value?.isDriver ?? false;
    final conversations = ref.watch(myConversationsProvider);

    if (me == null) return const SizedBox.shrink();

    return conversations.when(
      loading: () => const LoadingState(),
      error: (_, __) => const ErrorState(),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.chat_bubble_outline,
            message: t.noConversations,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final c = list[i];
            final unread = c.unreadFor(me.uid);
            return Card(
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: DriverAvatar(
                  radius: 22,
                  icon: isDriver ? Icons.person : Icons.two_wheeler,
                ),
                title: Text(
                  c.otherName(me.uid),
                  style: TextStyle(
                    fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  c.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatTime(c.updatedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (unread > 0) ...[
                      const SizedBox(height: 4),
                      Badge(label: Text('$unread')),
                    ],
                  ],
                ),
                onTap: () => context.push('/chat/${c.id}', extra: c.args),
              ),
            );
          },
        );
      },
    );
  }
}
