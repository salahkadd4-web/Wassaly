import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_config.dart';
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
  Future<void> extend(
    String uid, {
    int days = AppConfig.subscriptionDays,
  }) async {
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
    return _driver(uid)
        .update({'subscriptionStatus': 'suspended', 'active': false});
  }

  /// Leve la suspension : "paid" si la date de fin n'est pas depassee, sinon "expired".
  Future<void> unsuspend(DriverProfile d) {
    final end = d.subscriptionEnd;
    final stillValid = end != null && end.isAfter(DateTime.now());
    return _driver(d.uid)
        .update({'subscriptionStatus': stillValid ? 'paid' : 'expired'});
  }

  Future<void> deactivate(String uid) => _driver(uid).update({'active': false});

  Future<void> approveClaim(SubscriptionClaim claim) async {
    await extend(claim.driverId);
    await _db.collection('subscriptionRequests').doc(claim.id).update({
      'status': 'approved',
      'reviewedAt': FieldValue.serverTimestamp(),
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
