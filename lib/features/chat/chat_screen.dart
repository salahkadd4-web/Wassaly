import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/phone_guard.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chat.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/snack.dart';
import '../../widgets/state_views.dart';
import '../auth/auth_providers.dart';
import 'chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId, this.args});

  final String conversationId;
  final ChatArgs? args;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  bool _marking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _clientId => widget.conversationId.split('_').first;
  String get _driverId => widget.conversationId.split('_').last;

  Future<void> _send(String myUid, Conversation? conv) async {
    final t = AppLocalizations.of(context)!;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    // Les numeros ne s'echangent qu'apres l'acceptation (regle Firestore).
    if (containsPhoneNumber(text)) {
      showSnack(context, t.phoneNotAllowedChat);
      return;
    }
    _controller.clear();

    final isClient = myUid == _clientId;
    final myName = ref.read(userProfileProvider).value?.name ?? '';
    final clientName =
        widget.args?.clientName ?? conv?.clientName ?? (isClient ? myName : '');
    final driverName =
        widget.args?.driverName ?? conv?.driverName ?? (isClient ? '' : myName);

    try {
      await ref.read(chatRepositoryProvider).send(
            conversationId: widget.conversationId,
            clientId: _clientId,
            driverId: _driverId,
            clientName: clientName,
            driverName: driverName,
            senderId: myUid,
            text: text,
          );
    } catch (_) {
      if (!mounted) return;
      _controller.text = text;
      showSnack(context, t.sendError);
    }
  }

  void _markReadIfNeeded(Conversation? conv, String myUid) {
    if (conv == null || _marking || conv.unreadFor(myUid) == 0) return;
    _marking = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(chatRepositoryProvider).markRead(
              conversationId: widget.conversationId,
              clientId: _clientId,
              myUid: myUid,
            );
      } catch (_) {
        // Non bloquant.
      }
      _marking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final me = ref.watch(authStateProvider).value;
    if (me == null) return const Scaffold();

    final conv = ref.watch(conversationProvider(widget.conversationId)).value;
    _markReadIfNeeded(conv, me.uid);

    final isClient = me.uid == _clientId;
    final clientName = widget.args?.clientName ?? conv?.clientName ?? '';
    final driverName = widget.args?.driverName ?? conv?.driverName ?? '';
    final otherName = isClient ? driverName : clientName;

    final messages = ref.watch(messagesProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(title: Text(otherName.isEmpty ? t.messages : otherName)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: context.surfaceAlt,
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 14, color: context.muted),
                const SizedBox(width: 8),
                Expanded(child: Text(t.chatSafetyNotice, style: context.text.bodySmall)),
              ],
            ),
          ),
          Expanded(
            child: messages.when(
              loading: () => const LoadingState(),
              error: (_, _) => const ErrorState(),
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.chat_bubble_outline,
                    message: t.startConversation,
                  );
                }
                final reversed = list.reversed.toList();
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  itemCount: reversed.length,
                  itemBuilder: (context, i) {
                    final m = reversed[i];
                    final mine = m.senderId == me.uid;
                    // Messages consecutifs du meme auteur : groupes visuellement.
                    final next = i > 0 ? reversed[i - 1] : null;
                    final lastOfGroup = next == null || next.senderId != m.senderId;
                    return _Bubble(
                      text: m.text,
                      time: formatTime(m.createdAt),
                      mine: mine,
                      tail: lastOfGroup,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 1000,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: t.typeMessage,
                        counterText: '',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: t.send,
                    style: IconButton.styleFrom(minimumSize: const Size(46, 46)),
                    onPressed: () => _send(me.uid, conv),
                    icon: const Icon(Icons.send_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.time,
    required this.mine,
    required this.tail,
  });

  final String text;
  final String time;
  final bool mine;

  /// Dernier message d'un groupe : coin "queue" et espace apres.
  final bool tail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const r = Radius.circular(18);
    const small = Radius.circular(6);
    final fg = mine ? Colors.white : theme.colorScheme.onSurface;
    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Container(
          margin: EdgeInsets.only(top: 2, bottom: tail ? 10 : 2),
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 7),
          decoration: BoxDecoration(
            color: mine ? theme.colorScheme.primary : theme.colorScheme.surface,
            border: mine ? null : Border.all(color: theme.dividerColor),
            borderRadius: BorderRadiusDirectional.only(
              topStart: r,
              topEnd: r,
              bottomStart: mine || !tail ? r : small,
              bottomEnd: mine && tail ? small : r,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(text, style: context.text.bodyMedium?.copyWith(color: fg)),
              const SizedBox(height: 2),
              Text(
                time,
                style: context.text.labelSmall?.copyWith(
                  color: mine ? Colors.white70 : context.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
