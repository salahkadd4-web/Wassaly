import 'package:cloud_firestore/cloud_firestore.dart';

import 'geo_place.dart';

class OpenRequestStatus {
  static const open = 'open';
  static const closed = 'closed';
}

/// Demande publiee par un client qui cherche un livreur.
/// Visible par tous les livreurs abonnes (collection openRequests).
class OpenRequest {
  const OpenRequest({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.pickup,
    required this.delivery,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final GeoPlace pickup;
  final GeoPlace delivery;
  final String note;
  final String status;
  final DateTime createdAt;

  bool get isOpen => status == OpenRequestStatus.open;

  factory OpenRequest.fromMap(String id, Map<String, dynamic> map) {
    final created = map['createdAt'];
    return OpenRequest(
      id: id,
      clientId: (map['clientId'] as String?) ?? '',
      clientName: (map['clientName'] as String?) ?? '',
      clientPhone: (map['clientPhone'] as String?) ?? '',
      pickup: GeoPlace.fromMap(map['pickup'] as Map<String, dynamic>?),
      delivery: GeoPlace.fromMap(map['delivery'] as Map<String, dynamic>?),
      note: (map['note'] as String?) ?? '',
      status: (map['status'] as String?) ?? OpenRequestStatus.open,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }
}
