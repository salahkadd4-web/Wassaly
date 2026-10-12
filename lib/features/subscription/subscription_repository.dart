import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._db);

  final FirebaseFirestore _db;

  /// Le livreur declare avoir paye (reference du paiement) ; l'admin valide.
  /// [kind] : ClaimKind.monthly (un mois + dette eventuelle) ou ClaimKind.debt.
  Future<void> submitClaim({
    required String driverId,
    required String driverName,
    required String driverPhone,
    required String kind,
    required int amount,
    required String reference,
  }) {
    return _db.collection('subscriptionRequests').add({
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'kind': kind,
      'amount': amount,
      'reference': reference.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
