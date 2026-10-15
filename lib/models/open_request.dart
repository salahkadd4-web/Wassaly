import 'package:cloud_firestore/cloud_firestore.dart';

class OpenRequestStatus {
  static const open = 'open';
  static const closed = 'closed';

  /// Attribuee : un accord a ete conclu avec un livreur (Cloud Function
  /// agreeOffer) ; elle est devenue la livraison [OpenRequest.deliveryRequestId].
  static const taken = 'taken';
}

/// Demande publiee par un client qui cherche un livreur.
/// Les livreurs voient les quartiers et la distance ; l'adresse exacte
/// (private/route) n'est donnee qu'au livreur retenu, apres l'accord.
class OpenRequest {
  const OpenRequest({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.pickupArea,
    required this.deliveryArea,
    required this.note,
    required this.status,
    required this.createdAt,
    this.distanceKm,
    this.takenByName,
    this.deliveryRequestId,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String pickupArea;
  final String deliveryArea;
  final double? distanceKm;
  final String note;
  final String status;
  final DateTime createdAt;

  /// Livreur retenu (apres l'accord).
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
      pickupArea: (map['pickupArea'] as String?) ?? '',
      deliveryArea: (map['deliveryArea'] as String?) ?? '',
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
      note: (map['note'] as String?) ?? '',
      status: (map['status'] as String?) ?? OpenRequestStatus.open,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      takenByName: map['takenByName'] as String?,
      deliveryRequestId: map['deliveryRequestId'] as String?,
    );
  }
}

/// Offre d'un livreur sur une demande ouverte (openRequests/{id}/offers/{uid}).
class Offer {
  const Offer({
    required this.openRequestId,
    required this.driverId,
    required this.driverName,
    required this.price,
    required this.lastBy,
    required this.status,
    required this.updatedAt,
    this.refusedBy,
  });

  final String openRequestId;
  final String driverId;
  final String driverName;

  /// Prix en cours (derniere proposition).
  final int price;

  /// driver | client : auteur de la derniere proposition.
  final String lastBy;

  /// open (en negociation) | refused | closed (un autre livreur a ete retenu) | agreed.
  final String status;
  final String? refusedBy;
  final DateTime updatedAt;

  bool get isOpen => status == 'open';

  /// C'est a [asDriver] (livreur ou client) de repondre.
  bool myTurn({required bool asDriver}) =>
      isOpen && lastBy == (asDriver ? 'client' : 'driver');

  factory Offer.fromMap(String openRequestId, String driverId, Map<String, dynamic> map) {
    final updated = map['updatedAt'];
    return Offer(
      openRequestId: openRequestId,
      driverId: driverId,
      driverName: (map['driverName'] as String?) ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      lastBy: (map['lastBy'] as String?) ?? 'driver',
      status: (map['status'] as String?) ?? 'open',
      refusedBy: map['refusedBy'] as String?,
      updatedAt: updated is Timestamp ? updated.toDate() : DateTime.now(),
    );
  }
}
