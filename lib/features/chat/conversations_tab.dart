import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
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
    final conversations = ref.watch(myConversationsProvider);

    if (me == null) return const SizedBox.shrink();

    return conversations.when(
      loading: () => const LoadingState(),
      error: (_, _) => const ErrorState(),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: t.noConversationsTitle,
            message: t.noConversations,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: list.length,
          separatorBuilder: (_, _) => const Divider(indent: 76, endIndent: 16),
          itemBuilder: (context, i) => _ConversationRow(conv: list[i], myUid: me.uid),
        );
      },
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.conv, required this.myUid});

  final Conversation conv;
  final String myUid;

  @override
  Widget build(BuildContext context) {
    final unread = conv.unreadFor(myUid);
    final name = conv.otherName(myUid);
    return InkWell(
      onTap: () => context.push('/chat/${conv.id}', extra: conv.args),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            DriverAvatar(name: name, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conv.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      color: unread > 0 ? context.colors.onSurface : context.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatTime(conv.updatedAt),
                  style: context.text.labelSmall?.copyWith(
                    color: unread > 0 ? context.ink(AppTheme.orange) : null,
                  ),
                ),
                const SizedBox(height: 6),
                if (unread > 0)
                  Badge(label: Text('$unread'))
                else
                  const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
