import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_config.dart';
import '../../models/driver_billing.dart';
import '../../models/driver_profile.dart';
import '../../models/subscription_claim.dart';

enum AddAdminResult { added, notFound, alreadyAdmin }

class AdminRepository {
  AdminRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _driver(String uid) =>
      _db.collection('drivers').doc(uid);

  /// Prolonge l'abonnement de [days] jours a partir de la fin actuelle
  /// (ou de maintenant si deja expire) et le marque comme paye.
  Future<void> extend(String uid, {int days = AppConfig.subscriptionDays}) async {
    final snap = await _driver(uid).get();
    final data = snap.data();
    final current = data?['subscriptionEnd'];
    final now = DateTime.now();
    var base = now;
    if (current is Timestamp && current.toDate().isAfter(now)) {
      base = current.toDate();
    }
    await _driver(uid).update({
      'subscriptionStatus': 'paid',
      'subscriptionEnd': Timestamp.fromDate(base.add(Duration(days: days))),
    });
  }

  Future<void> suspend(String uid) {
    return _driver(uid).update({
      'subscriptionStatus': 'suspended',
      'active': false,
    });
  }

  /// Leve la suspension : "paid" si la date de fin n'est pas depassee,
  /// sinon "per_delivery" si c'est sa formule, sinon "expired".
  Future<void> unsuspend(DriverProfile d) {
    final end = d.subscriptionEnd;
    final stillValid = end != null && end.isAfter(DateTime.now());
    final String status;
    if (stillValid) {
      status = 'paid';
    } else if (d.plan == DriverPlan.perDelivery) {
      status = 'per_delivery';
    } else {
      status = 'expired';
    }
    return _driver(d.uid).update({'subscriptionStatus': status});
  }

  /// Valide la piece d'identite : le livreur est debloque.
  Future<void> approveIdentity(String uid) async {
    final batch = _db.batch();
    batch.update(_driver(uid), {
      'verificationStatus': 'approved',
      'verifiedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection('driverIdentity').doc(uid), {
      'rejectReason': FieldValue.delete(),
    });
    await batch.commit();
  }

  /// Refuse la piece d'identite : le livreur reste bloque et peut renvoyer
  /// une nouvelle photo. [reason] est affiche au livreur.
  Future<void> rejectIdentity(String uid, {String? reason}) async {
    final clean = reason?.trim() ?? '';
    final batch = _db.batch();
    batch.update(_driver(uid), {
      'verificationStatus': 'rejected',
      'active': false,
    });
    batch.update(_db.collection('driverIdentity').doc(uid), {
      'rejectReason': clean.isEmpty ? FieldValue.delete() : clean,
    });
    await batch.commit();
  }

  Future<void> deactivate(String uid) => _driver(uid).update({'active': false});

  /// Valide un paiement declare. Le montant rembourse d'abord la dette
  /// (formule a la livraison) ; un paiement mensuel ajoute ensuite 30 jours.
  /// Les anciennes demandes sans montant valent un mois.
  Future<void> approveClaim(SubscriptionClaim claim) {
    final driverRef = _driver(claim.driverId);
    final billingRef = _db.collection('driverBilling').doc(claim.driverId);
    final claimRef = _db.collection('subscriptionRequests').doc(claim.id);

    return _db.runTransaction((tx) async {
      final driverSnap = await tx.get(driverRef);
      final billingSnap = await tx.get(billingRef);
      final driver = DriverProfile.fromMap(claim.driverId, driverSnap.data() ?? {});
      final debt = DriverBilling.fromMap(claim.driverId, billingSnap.data()).debt;

      final paid = claim.amount > 0
          ? claim.amount
          : AppConfig.monthlyPriceDa + debt;
      final toDebt = paid < debt ? paid : debt;
      final newDebt = debt - toDebt;
      final driverUpdate = <String, dynamic>{};

      if (toDebt > 0) {
        tx.set(
          billingRef,
          {
            'debt': newDebt,
            if (newDebt < AppConfig.debtLimitDa) 'blockedSince': null,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        tx.set(billingRef.collection('ledger').doc('payment_${claim.id}'), {
          'type': 'payment',
          'amount': toDebt,
          'claimId': claim.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (newDebt < AppConfig.debtLimitDa) driverUpdate['billingBlocked'] = false;
      }

      if (!claim.isDebt && newDebt == 0) {
        final now = DateTime.now();
        final end = driver.subscriptionEnd;
        final running = driver.periodRunningAt(now) && end != null;
        final base = running ? end : now;
        driverUpdate.addAll({
          'subscriptionStatus': 'paid',
          'subscriptionEnd': Timestamp.fromDate(
            base.add(const Duration(days: AppConfig.subscriptionDays)),
          ),
          'plan': DriverPlan.monthly,
          'billingBlocked': false,
        });
      }

      if (driverUpdate.isNotEmpty && !driver.isSuspended) {
        tx.update(driverRef, driverUpdate);
      } else if (driverUpdate.isNotEmpty) {
        // Suspendu : on enregistre le paiement sans lever la suspension.
        driverUpdate.remove('subscriptionStatus');
        tx.update(driverRef, driverUpdate);
      }
      tx.update(claimRef, {
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> rejectClaim(SubscriptionClaim claim) {
    return _db.collection('subscriptionRequests').doc(claim.id).update({
      'status': 'rejected',
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Donne le role administrateur au compte inscrit avec cet email.
  Future<AddAdminResult> addAdminByEmail(String email, String addedBy) async {
    final clean = email.trim();
    final users = _db.collection('users');
    var snap = await users
        .where('email', isEqualTo: clean.toLowerCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty && clean != clean.toLowerCase()) {
      snap = await users.where('email', isEqualTo: clean).limit(1).get();
    }
    if (snap.docs.isEmpty) return AddAdminResult.notFound;

    final doc = snap.docs.first;
    final ref = _db.collection('admins').doc(doc.id);
    if ((await ref.get()).exists) return AddAdminResult.alreadyAdmin;

    await ref.set({
      'email': (doc.data()['email'] as String?) ?? clean,
      'addedBy': addedBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return AddAdminResult.added;
  }

  Future<void> removeAdmin(String uid) =>
      _db.collection('admins').doc(uid).delete();
}
