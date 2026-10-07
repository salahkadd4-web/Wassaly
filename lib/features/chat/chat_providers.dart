import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/chat.dart';
import '../auth/auth_providers.dart';
import 'chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(firestoreProvider)),
);

/// Conversations de l'utilisateur connecte (la plus recente d'abord).
final myConversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final user = ref.watch(authStateProvider).value;
  final profile = ref.watch(userProfileProvider).value;
  if (user == null || profile == null) return Stream.value(const []);

  final field = profile.isDriver ? 'driverId' : 'clientId';
  return ref
      .watch(firestoreProvider)
      .collection('conversations')
      .where(field, isEqualTo: user.uid)
      .snapshots()
      .map((s) {
        final list = s.docs
            .map((d) => Conversation.fromMap(d.id, d.data()))
            .toList();
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return list;
      });
});

/// Total des messages non lus (badge de l'onglet Messages).
final unreadMessagesCountProvider = Provider<int>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return 0;
  final list = ref.watch(myConversationsProvider).value ?? const [];
  return list.fold<int>(0, (sum, c) => sum + c.unreadFor(user.uid));
});

final conversationProvider = StreamProvider.family<Conversation?, String>((
  ref,
  id,
) {
  return ref
      .watch(firestoreProvider)
      .collection('conversations')
      .doc(id)
      .snapshots()
      .map((s) => s.exists ? Conversation.fromMap(s.id, s.data()!) : null);
});

final messagesProvider = StreamProvider.family<List<ChatMessage>, String>((
  ref,
  id,
) {
  return ref
      .watch(firestoreProvider)
      .collection('conversations')
      .doc(id)
      .collection('messages')
      .orderBy('createdAt')
      .snapshots()
      .map(
        (s) => s.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList(),
      );
});
