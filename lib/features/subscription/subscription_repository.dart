import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/driver_profile.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._db);

  final FirebaseFirestore _db;

  /// Le livreur declare avoir paye (reference du paiement) ; l'admin valide.
  Future<void> submitClaim({
    required DriverProfile driver,
    required String reference,
  }) {
    return _db.collection('subscriptionRequests').add({
      'driverId': driver.uid,
      'driverName': driver.name,
      'driverPhone': driver.phone,
      'reference': reference.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
