import 'package:cloud_firestore/cloud_firestore.dart';

import 'geo_place.dart';

class OpenRequestStatus {
  static const open = 'open';
  static const closed = 'closed';

  /// Prise par un livreur (Cloud Function takeOpenRequest) : elle est devenue
  /// une livraison suivie (deliveryRequests/[OpenRequest.deliveryRequestId]).
  static const taken = 'taken';
}

/// Demande publiee par un client qui cherche un livreur.
/// Visible par les livreurs qui peuvent travailler (collection openRequests),
/// sans le numero du client : le premier livreur qui la prend l'obtient.
class OpenRequest {
  const OpenRequest({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.pickup,
    required this.delivery,
    required this.note,
    required this.status,
    required this.createdAt,
    this.takenByName,
    this.deliveryRequestId,
  });

  final String id;
  final String clientId;
  final String clientName;
  final GeoPlace pickup;
  final GeoPlace delivery;
  final String note;
  final String status;
  final DateTime createdAt;

  /// Nom du livreur qui l'a prise.
  final String? takenByName;
  final String? deliveryRequestId;

  bool get isOpen => status == OpenRequestStatus.open;
  bool get isTaken => status == OpenRequestStatus.taken;

  factory OpenRequest.fromMap(String id, Map<String, dynamic> map) {
    final created = map['createdAt'];
    return OpenRequest(
      id: id,
      clientId: (map['clientId'] as String?) ?? '',
      clientName: (map['clientName'] as String?) ?? '',
      pickup: GeoPlace.fromMap(map['pickup'] as Map<String, dynamic>?),
      delivery: GeoPlace.fromMap(map['delivery'] as Map<String, dynamic>?),
      note: (map['note'] as String?) ?? '',
      status: (map['status'] as String?) ?? OpenRequestStatus.open,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      takenByName: map['takenByName'] as String?,
      deliveryRequestId: map['deliveryRequestId'] as String?,
    );
  }
}
