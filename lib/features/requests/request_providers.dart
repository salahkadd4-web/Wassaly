import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/course_route.dart';
import '../../models/delivery_request.dart';
import '../../models/request_contact.dart';
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

/// Telephones d'une livraison acceptee (lisibles seulement apres acceptation).
final requestContactProvider =
    StreamProvider.family<RequestContact, String>((ref, requestId) {
  return ref
      .watch(firestoreProvider)
      .collection('deliveryRequests')
      .doc(requestId)
      .collection('private')
      .doc('contact')
      .snapshots()
      .map((s) => RequestContact.fromMap(s.data()));
});

/// Adresse exacte d'une course : toujours pour le client, pour le livreur
/// seulement apres l'accord (sinon le flux est en erreur : on renvoie null).
final deliveryRouteProvider =
    StreamProvider.family<CourseRoute?, String>((ref, requestId) {
  return ref
      .watch(firestoreProvider)
      .collection('deliveryRequests')
      .doc(requestId)
      .collection('private')
      .doc('route')
      .snapshots()
      .map((s) => CourseRoute.fromMap(s.data()));
});

/// Nombre de demandes ou c'est au livreur de repondre (proposer un prix,
/// repondre a une contre-proposition).
final pendingRequestsCountProvider = Provider<int>((ref) {
  final list = ref.watch(driverRequestsProvider).value ?? const [];
  return list.where((r) => r.myTurn(asDriver: true)).length;
});
