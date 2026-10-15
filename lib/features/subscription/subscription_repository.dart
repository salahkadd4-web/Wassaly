import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/subscription_claim.dart';

/// La reference de paiement a deja ete declaree (par ce livreur ou un autre).
class PaymentReferenceUsedException implements Exception {
  const PaymentReferenceUsedException();
}

class SubscriptionRepository {
  SubscriptionRepository(this._db);

  final FirebaseFirestore _db;

  /// Le livreur declare avoir paye (reference du paiement) ; l'admin valide.
  /// [kind] : ClaimKind.monthly (un mois + dette eventuelle) ou ClaimKind.debt.
  ///
  /// La reference est reservee dans paymentRefs/{reference normalisee} dans la
  /// meme ecriture groupee : si elle existe deja, les regles refusent tout et
  /// [PaymentReferenceUsedException] est levee.
  Future<void> submitClaim({
    required String driverId,
    required String driverName,
    required String driverPhone,
    required String kind,
    required int amount,
    required String reference,
  }) async {
    final key = normalizePaymentReference(reference);
    final claimRef = _db.collection('subscriptionRequests').doc();
    final batch = _db.batch()
      ..set(claimRef, {
        'driverId': driverId,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'kind': kind,
        'amount': amount,
        'reference': reference.trim(),
        'referenceKey': key,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..set(_db.collection('paymentRefs').doc(key), {
        'driverId': driverId,
        'claimId': claimRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PaymentReferenceUsedException();
      rethrow;
    }
  }
}
