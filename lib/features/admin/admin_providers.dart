import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/delivery_request.dart';
import '../../models/driver_profile.dart';
import '../../models/subscription_claim.dart';
import '../auth/auth_providers.dart';
import '../auth/models/user_profile.dart';
import 'admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(firestoreProvider)),
);

final adminDriversProvider = StreamProvider<List<DriverProfile>>((ref) {
  return ref.watch(firestoreProvider).collection('drivers').snapshots().map((
    s,
  ) {
    final list = s.docs
        .map((d) => DriverProfile.fromMap(d.id, d.data()))
        .toList();
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
        final list = s.docs
            .map((d) => UserProfile.fromMap(d.id, d.data()))
            .toList();
        list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
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
        final list = s.docs
            .map((d) => SubscriptionClaim.fromMap(d.id, d.data()))
            .toList();
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

/// Un administrateur (document admins/{uid}).
class AdminEntry {
  const AdminEntry({required this.uid, required this.email});

  final String uid;
  final String email;
}

final adminListProvider = StreamProvider<List<AdminEntry>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('admins')
      .snapshots()
      .map(
        (s) => s.docs
            .map(
              (d) => AdminEntry(
                uid: d.id,
                email: (d.data()['email'] as String?) ?? '',
              ),
            )
            .toList(),
      );
});

/// Profil (users/{uid}) d'un compte, pour afficher le nom d'un admin.
final adminUserProvider = FutureProvider.family<UserProfile?, String>((
  ref,
  uid,
) async {
  final snap = await ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(uid)
      .get();
  final data = snap.data();
  return data == null ? null : UserProfile.fromMap(uid, data);
});
