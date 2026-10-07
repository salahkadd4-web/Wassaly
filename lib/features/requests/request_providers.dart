import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/delivery_request.dart';
import '../auth/auth_providers.dart';
import 'request_repository.dart';

final requestRepositoryProvider = Provider<RequestRepository>(
  (ref) => RequestRepository(ref.watch(firestoreProvider)),
);

Stream<List<DeliveryRequest>> _watch(Ref ref, String field, String uid) {
  return ref
      .watch(firestoreProvider)
      .collection('deliveryRequests')
      .where(field, isEqualTo: uid)
      .snapshots()
      .map((s) {
        final list = s.docs
            .map((d) => DeliveryRequest.fromMap(d.id, d.data()))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
}

/// Demandes envoyees par le client connecte (les plus recentes d'abord).
final clientRequestsProvider = StreamProvider<List<DeliveryRequest>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return _watch(ref, 'clientId', user.uid);
});

/// Demandes recues par le livreur connecte (les plus recentes d'abord).
final driverRequestsProvider = StreamProvider<List<DeliveryRequest>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return _watch(ref, 'driverId', user.uid);
});

/// Nombre de demandes en attente cote livreur.
final pendingRequestsCountProvider = Provider<int>((ref) {
  final list = ref.watch(driverRequestsProvider).value ?? const [];
  return list.where((r) => r.isPending).length;
});
