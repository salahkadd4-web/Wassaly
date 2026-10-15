import 'package:cloud_firestore/cloud_firestore.dart';

import 'course_route.dart';
import 'geo_place.dart';

class RequestStatus {
  /// Envoyee, le livreur n'a pas encore propose de prix.
  static const pending = 'pending';

  /// Prix en negociation (voir [DeliveryRequest.lastBy]).
  static const negotiating = 'negotiating';

  /// Accord conclu (serveur) : course comptee, coordonnees partagees.
  static const accepted = 'accepted';
  static const rejected = 'rejected';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
}

/// Qui a fait la derniere proposition de prix.
class PriceBy {
  static const driver = 'driver';
  static const client = 'client';
}

class DeliveryRequest {
  const DeliveryRequest({
    required this.id,
    required this.clientId,
    required this.driverId,
    required this.clientName,
    required this.driverName,
    required this.pickupArea,
    required this.deliveryArea,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.distanceKm,
    this.amount,
    this.completedAt,
    this.acceptedAt,
    this.charged = 0,
    this.source = 'direct',
    this.price,
    this.lastBy,
    this.rated,
    this.legacyRoute,
    this.openRequestId,
    this.refunded = false,
  });

  /// Demande ouverte d'origine (source == 'open').
  final String? openRequestId;

  /// Remboursement des 50 DA fait par l'admin (annulation).
  final bool refunded;

  final String id;
  final String clientId;
  final String driverId;
  final String clientName;
  final String driverName;

  /// Quartiers (publics) : tout ce que le livreur sait du trajet avant l'accord.
  final String pickupArea;
  final String deliveryArea;

  /// Distance recuperation -> livraison (si le client a partage les deux GPS).
  final double? distanceKm;
  final String note;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Montant enregistre a la fin de la course (= prix convenu).
  /// Null pour une livraison terminee avant l'ajout du chiffre d'affaires.
  final int? amount;

  /// Date de fin de la livraison (serveur). Null pour les anciennes livraisons.
  final DateTime? completedAt;

  /// Date de l'accord (serveur, Cloud Function).
  final DateTime? acceptedAt;

  /// Montant debite au livreur a l'accord (formule a la livraison), 0 sinon.
  final int charged;

  /// direct (envoyee a un livreur) | open (demande ouverte attribuee a une offre).
  final String source;

  /// Prix en cours de negociation, puis prix convenu apres l'accord.
  final int? price;

  /// Auteur de la derniere proposition : PriceBy.driver | PriceBy.client.
  final String? lastBy;

  /// Note (1 a 5) laissee par le client, ecrite par le serveur ; null si pas encore notee.
  final int? rated;

  /// Anciennes demandes : l'adresse etait dans le document public.
  final CourseRoute? legacyRoute;

  bool get isPending => status == RequestStatus.pending;
  bool get isNegotiating => status == RequestStatus.negotiating;
  bool get isAccepted => status == RequestStatus.accepted;
  bool get isCompleted => status == RequestStatus.completed;

  /// Pas encore d'accord : on peut encore proposer, accepter ou refuser.
  bool get awaitingAgreement => isPending || isNegotiating;
  bool get isOpen => awaitingAgreement || isAccepted;

  /// Les telephones et l'adresse exacte ne sont partages qu'apres l'accord.
  bool get contactShared => isAccepted || isCompleted;

  // Documents prives (adresse exacte, telephones). Pour une course issue
  // d'une demande ouverte, ils sont restes sur la demande ouverte.
  bool get _fromOpen => source == 'open' && openRequestId != null;

  String get routePath => _fromOpen
      ? 'openRequests/$openRequestId/private/route'
      : 'deliveryRequests/$id/private/route';

  String get clientContactPath => _fromOpen
      ? 'openRequests/$openRequestId/private/clientContact'
      : 'deliveryRequests/$id/private/clientContact';

  String get driverContactPath => _fromOpen
      ? 'openRequests/$openRequestId/driverContacts/$driverId'
      : 'deliveryRequests/$id/private/driverContact';

  /// C'est a [asDriver] (livreur ou client) de repondre a la negociation.
  bool myTurn({required bool asDriver}) {
    if (asDriver) return isPending || (isNegotiating && lastBy == PriceBy.client);
    return isNegotiating && lastBy == PriceBy.driver;
  }

  factory DeliveryRequest.fromMap(String id, Map<String, dynamic> map) {
    DateTime ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
    DateTime? opt(dynamic v) => v is Timestamp ? v.toDate() : null;
    final legacy = map['pickup'] is Map || map['delivery'] is Map
        ? CourseRoute(
            pickup: GeoPlace.fromMap(map['pickup'] as Map<String, dynamic>?),
            delivery: GeoPlace.fromMap(map['delivery'] as Map<String, dynamic>?),
          )
        : null;
    return DeliveryRequest(
      id: id,
      clientId: (map['clientId'] as String?) ?? '',
      driverId: (map['driverId'] as String?) ?? '',
      clientName: (map['clientName'] as String?) ?? '',
      driverName: (map['driverName'] as String?) ?? '',
      pickupArea: (map['pickupArea'] as String?) ?? '',
      deliveryArea: (map['deliveryArea'] as String?) ?? '',
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
      note: (map['note'] as String?) ?? '',
      status: (map['status'] as String?) ?? RequestStatus.pending,
      createdAt: ts(map['createdAt']),
      updatedAt: ts(map['updatedAt']),
      amount: (map['amount'] as num?)?.toInt(),
      completedAt: opt(map['completedAt']),
      acceptedAt: opt(map['acceptedAt']),
      charged: (map['charged'] as num?)?.toInt() ?? 0,
      source: (map['source'] as String?) ?? 'direct',
      price: (map['price'] as num?)?.toInt(),
      lastBy: map['lastBy'] as String?,
      rated: (map['rated'] as num?)?.toInt(),
      legacyRoute: legacy,
      openRequestId: map['openRequestId'] as String?,
      refunded: (map['refunded'] as bool?) ?? false,
    );
  }
}
