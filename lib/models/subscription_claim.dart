import 'package:cloud_firestore/cloud_firestore.dart';

/// Demande de renouvellement d'abonnement envoyee par un livreur.
class SubscriptionClaim {
  const SubscriptionClaim({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.reference,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String reference;

  /// pending | approved | rejected
  final String status;
  final DateTime createdAt;

  bool get isPending => status == 'pending';

  factory SubscriptionClaim.fromMap(String id, Map<String, dynamic> map) {
    return SubscriptionClaim(
      id: id,
      driverId: (map['driverId'] as String?) ?? '',
      driverName: (map['driverName'] as String?) ?? '',
      driverPhone: (map['driverPhone'] as String?) ?? '',
      reference: (map['reference'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'pending',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
