import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/delivery_request.dart';
import '../../models/driver_billing.dart';
import '../../models/driver_profile.dart';
import '../../models/subscription_claim.dart';
import '../auth/auth_providers.dart';
import '../auth/models/user_profile.dart';
import 'admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(firestoreProvider)),
);

final adminDriversProvider = StreamProvider<List<DriverProfile>>((ref) {
  return ref.watch(firestoreProvider).collection('drivers').snapshots().map((s) {
    final list = s.docs.map((d) => DriverProfile.fromMap(d.id, d.data())).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  });
});

final adminClientsProvider = StreamProvider<List<UserProfile>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .where('role', isEqualTo: 'client')
      .snapshots()
      .map((s) {
    final list = s.docs.map((d) => UserProfile.fromMap(d.id, d.data())).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  });
});

final adminClaimsProvider = StreamProvider<List<SubscriptionClaim>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('subscriptionRequests')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) {
    final list =
        s.docs.map((d) => SubscriptionClaim.fromMap(d.id, d.data())).toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  });
});

final adminRequestsProvider = StreamProvider<List<DeliveryRequest>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('deliveryRequests')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map(
        (s) =>
            s.docs.map((d) => DeliveryRequest.fromMap(d.id, d.data())).toList(),
      );
});

/// Toutes les livraisons terminees (base du chiffre d'affaires par livreur).
final adminCompletedRequestsProvider =
    StreamProvider<List<DeliveryRequest>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('deliveryRequests')
      .where('status', isEqualTo: 'completed')
      .snapshots()
      .map(
        (s) =>
            s.docs.map((d) => DeliveryRequest.fromMap(d.id, d.data())).toList(),
      );
});

/// Facturation de tous les livreurs (cle = uid) : dette et compteurs anti-fraude.
final adminBillingProvider = StreamProvider<Map<String, DriverBilling>>((ref) {
  return ref.watch(firestoreProvider).collection('driverBilling').snapshots().map(
        (s) => {
          for (final d in s.docs) d.id: DriverBilling.fromMap(d.id, d.data()),
        },
      );
});

/// Signalement d'un livreur par un client.
class DriverReport {
  const DriverReport({
    required this.clientId,
    required this.driverId,
    required this.reason,
    required this.note,
    required this.createdAt,
  });

  final String clientId;
  final String driverId;
  final String reason;
  final String note;
  final DateTime createdAt;
}

/// Signalements, groupes par livreur (les plus recents d'abord).
final adminReportsProvider =
    StreamProvider<Map<String, List<DriverReport>>>((ref) {
  return ref.watch(firestoreProvider).collection('reports').snapshots().map((s) {
    final byDriver = <String, List<DriverReport>>{};
    for (final d in s.docs) {
      final m = d.data();
      final created = m['createdAt'];
      final report = DriverReport(
        clientId: (m['clientId'] as String?) ?? '',
        driverId: (m['driverId'] as String?) ?? '',
        reason: (m['reason'] as String?) ?? 'other',
        note: (m['note'] as String?) ?? '',
        createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      );
      byDriver.putIfAbsent(report.driverId, () => []).add(report);
    }
    for (final list in byDriver.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return byDriver;
  });
});

/// Un administrateur (document admins/{uid}).
class AdminEntry {
  const AdminEntry({required this.uid, required this.email});

  final String uid;
  final String email;
}

final adminListProvider = StreamProvider<List<AdminEntry>>((ref) {
  return ref.watch(firestoreProvider).collection('admins').snapshots().map(
        (s) => s.docs
            .map((d) => AdminEntry(
                  uid: d.id,
                  email: (d.data()['email'] as String?) ?? '',
                ))
            .toList(),
      );
});

/// Profil (users/{uid}) d'un compte, pour afficher le nom d'un admin.
final adminUserProvider =
    FutureProvider.family<UserProfile?, String>((ref, uid) async {
  final snap = await ref.watch(firestoreProvider).collection('users').doc(uid).get();
  final data = snap.data();
  return data == null ? null : UserProfile.fromMap(uid, data);
});
