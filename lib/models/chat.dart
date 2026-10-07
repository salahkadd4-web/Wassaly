import 'package:cloud_firestore/cloud_firestore.dart';

/// Noms des deux participants, transmis a l'ecran de discussion.
class ChatArgs {
  const ChatArgs({required this.clientName, required this.driverName});

  final String clientName;
  final String driverName;
}

class Conversation {
  const Conversation({
    required this.id,
    required this.clientId,
    required this.driverId,
    required this.clientName,
    required this.driverName,
    required this.lastMessage,
    required this.lastSenderId,
    required this.updatedAt,
    required this.clientUnread,
    required this.driverUnread,
  });

  final String id;
  final String clientId;
  final String driverId;
  final String clientName;
  final String driverName;
  final String lastMessage;
  final String lastSenderId;
  final DateTime updatedAt;
  final int clientUnread;
  final int driverUnread;

  String otherName(String myUid) => myUid == clientId ? driverName : clientName;

  int unreadFor(String myUid) =>
      myUid == clientId ? clientUnread : driverUnread;

  ChatArgs get args => ChatArgs(clientName: clientName, driverName: driverName);

  factory Conversation.fromMap(String id, Map<String, dynamic> map) {
    return Conversation(
      id: id,
      clientId: (map['clientId'] as String?) ?? '',
      driverId: (map['driverId'] as String?) ?? '',
      clientName: (map['clientName'] as String?) ?? '',
      driverName: (map['driverName'] as String?) ?? '',
      lastMessage: (map['lastMessage'] as String?) ?? '',
      lastSenderId: (map['lastSenderId'] as String?) ?? '',
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      clientUnread: (map['clientUnread'] as num?)?.toInt() ?? 0,
      driverUnread: (map['driverUnread'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      senderId: (map['senderId'] as String?) ?? '',
      text: (map['text'] as String?) ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
