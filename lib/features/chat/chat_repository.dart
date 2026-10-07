import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  ChatRepository(this._db);

  final FirebaseFirestore _db;

  /// Identifiant deterministe d'une conversation client <-> livreur.
  static String idFor(String clientId, String driverId) =>
      '${clientId}_$driverId';

  DocumentReference<Map<String, dynamic>> _conv(String id) =>
      _db.collection('conversations').doc(id);

  Future<void> send({
    required String conversationId,
    required String clientId,
    required String driverId,
    required String clientName,
    required String driverName,
    required String senderId,
    required String text,
  }) {
    final convRef = _conv(conversationId);
    final msgRef = convRef.collection('messages').doc();
    final fromClient = senderId == clientId;
    final unreadField = fromClient ? 'driverUnread' : 'clientUnread';

    final batch = _db.batch();
    batch.set(convRef, {
      'clientId': clientId,
      'driverId': driverId,
      'clientName': clientName,
      'driverName': driverName,
      'lastMessage': text,
      'lastSenderId': senderId,
      'updatedAt': FieldValue.serverTimestamp(),
      unreadField: FieldValue.increment(1),
    }, SetOptions(merge: true));
    batch.set(msgRef, {
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return batch.commit();
  }

  /// Remet a zero le compteur de messages non lus de [myUid].
  Future<void> markRead({
    required String conversationId,
    required String clientId,
    required String myUid,
  }) {
    final field = myUid == clientId ? 'clientUnread' : 'driverUnread';
    return _conv(conversationId).update({field: 0});
  }
}
