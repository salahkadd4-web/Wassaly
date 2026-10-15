import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/course_route.dart';
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
    final list =
        s.docs.map((d) => DeliveryRequest.fromMap(d.id, d.data())).toList();
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

/// Telephone depose par une partie (document {phone} : voir
/// DeliveryRequest.clientContactPath / driverContactPath). Lisible par
/// l'autre partie seulement apres l'accord.
final phoneDocProvider = StreamProvider.family<String?, String>((ref, path) {
  return ref
      .watch(firestoreProvider)
      .doc(path)
      .snapshots()
      .map((s) => s.data()?['phone'] as String?);
});

/// Adresse exacte d'une course (DeliveryRequest.routePath) : toujours pour le
/// client, pour le livreur seulement apres l'accord.
final routeDocProvider = StreamProvider.family<CourseRoute?, String>((ref, path) {
  return ref
      .watch(firestoreProvider)
      .doc(path)
      .snapshots()
      .map((s) => CourseRoute.fromMap(s.data()));
});

/// Nombre de demandes ou c'est au livreur de repondre (proposer un prix,
/// repondre a une contre-proposition).
final pendingRequestsCountProvider = Provider<int>((ref) {
  final list = ref.watch(driverRequestsProvider).value ?? const [];
  return list.where((r) => r.myTurn(asDriver: true)).length;
});
