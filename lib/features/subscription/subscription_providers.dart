import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/subscription_claim.dart';
import '../auth/auth_providers.dart';
import 'subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => SubscriptionRepository(ref.watch(firestoreProvider)),
);

/// Demandes de renouvellement du livreur connecte.
final myClaimsProvider = StreamProvider<List<SubscriptionClaim>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref
      .watch(firestoreProvider)
      .collection('subscriptionRequests')
      .where('driverId', isEqualTo: user.uid)
      .snapshots()
      .map((s) {
        final list = s.docs
            .map((d) => SubscriptionClaim.fromMap(d.id, d.data()))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
});
