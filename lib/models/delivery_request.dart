import 'package:cloud_firestore/cloud_firestore.dart';

import 'geo_place.dart';

class RequestStatus {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const rejected = 'rejected';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
}

class DeliveryRequest {
  const DeliveryRequest({
    required this.id,
    required this.clientId,
    required this.driverId,
    required this.clientName,
    required this.clientPhone,
    required this.driverName,
    required this.pickup,
    required this.delivery,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String clientId;
  final String driverId;
  final String clientName;
  final String clientPhone;
  final String driverName;
  final GeoPlace pickup;
  final GeoPlace delivery;
  final String note;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPending => status == RequestStatus.pending;
  bool get isAccepted => status == RequestStatus.accepted;
  bool get isOpen => isPending || isAccepted;

  factory DeliveryRequest.fromMap(String id, Map<String, dynamic> map) {
    DateTime ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
    return DeliveryRequest(
      id: id,
      clientId: (map['clientId'] as String?) ?? '',
      driverId: (map['driverId'] as String?) ?? '',
      clientName: (map['clientName'] as String?) ?? '',
      clientPhone: (map['clientPhone'] as String?) ?? '',
      driverName: (map['driverName'] as String?) ?? '',
      pickup: GeoPlace.fromMap(map['pickup'] as Map<String, dynamic>?),
      delivery: GeoPlace.fromMap(map['delivery'] as Map<String, dynamic>?),
      note: (map['note'] as String?) ?? '',
      status: (map['status'] as String?) ?? RequestStatus.pending,
      createdAt: ts(map['createdAt']),
      updatedAt: ts(map['updatedAt']),
    );
  }
}
