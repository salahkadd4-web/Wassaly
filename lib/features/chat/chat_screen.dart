import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
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
    _controller.clear();

    final isClient = myUid == _clientId;
    final myName = ref.read(userProfileProvider).value?.name ?? '';
    final clientName =
        widget.args?.clientName ?? conv?.clientName ?? (isClient ? myName : '');
    final driverName =
        widget.args?.driverName ?? conv?.driverName ?? (isClient ? '' : myName);

    try {
      await ref
          .read(chatRepositoryProvider)
          .send(
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
        await ref
            .read(chatRepositoryProvider)
            .markRead(
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
          Expanded(
            child: messages.when(
              loading: () => const LoadingState(),
              error: (_, __) => const ErrorState(),
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
                  padding: const EdgeInsets.all(12),
                  itemCount: reversed.length,
                  itemBuilder: (context, i) {
                    final m = reversed[i];
                    final mine = m.senderId == me.uid;
                    return Align(
                      alignment: mine
                          ? AlignmentDirectional.centerEnd
                          : AlignmentDirectional.centerStart,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: mine
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surface,
                            border: mine
                                ? null
                                : Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                m.text,
                                style: TextStyle(
                                  color: mine
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatTime(m.createdAt),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: mine
                                      ? Colors.white70
                                      : theme.colorScheme.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
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
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: t.send,
                    onPressed: () => _send(me.uid, conv),
                    icon: const Icon(Icons.send),
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
