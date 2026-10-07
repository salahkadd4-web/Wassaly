import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/open_request.dart';
import '../auth/auth_providers.dart';
import '../drivers/driver_providers.dart';
import 'open_request_repository.dart';

/// Au-dela de cette duree, une demande ouverte n'est plus montree aux livreurs.
const openRequestMaxAge = Duration(hours: 72);

final openRequestRepositoryProvider = Provider<OpenRequestRepository>(
  (ref) => OpenRequestRepository(ref.watch(firestoreProvider)),
);

List<OpenRequest> _parse(
  Iterable<Map<String, dynamic>> docs,
  List<String> ids,
) {
  final list = <OpenRequest>[];
  for (var i = 0; i < ids.length; i++) {
    list.add(OpenRequest.fromMap(ids[i], docs.elementAt(i)));
  }
  return list;
}

/// Demandes ouvertes publiees par le client connecte (les plus recentes d'abord).
final clientOpenRequestsProvider = StreamProvider<List<OpenRequest>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);
  return ref
      .watch(firestoreProvider)
      .collection('openRequests')
      .where('clientId', isEqualTo: user.uid)
      .snapshots()
      .map((s) {
        final list = _parse(
          s.docs.map((d) => d.data()),
          s.docs.map((d) => d.id).toList(),
        );
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
});

/// Demandes ouvertes visibles par le livreur connecte.
/// Liste vide (sans interroger Firestore) tant que son abonnement n'est pas valide :
/// les regles de securite refuseraient la lecture.
final driverOpenRequestsProvider = StreamProvider<List<OpenRequest>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const []);

  final driver = ref.watch(driverProvider(user.uid)).value;
  if (driver == null || !driver.subscriptionValid) {
    return Stream.value(const []);
  }

  return ref
      .watch(firestoreProvider)
      .collection('openRequests')
      .where('status', isEqualTo: OpenRequestStatus.open)
      .limit(100)
      .snapshots()
      .map((s) {
        final limit = DateTime.now().subtract(openRequestMaxAge);
        final list = _parse(
          s.docs.map((d) => d.data()),
          s.docs.map((d) => d.id).toList(),
        ).where((r) => r.createdAt.isAfter(limit)).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
});

/// Nombre de demandes ouvertes visibles par le livreur (pastille de l'onglet).
final openRequestsCountProvider = Provider<int>((ref) {
  return ref.watch(driverOpenRequestsProvider).value?.length ?? 0;
});
