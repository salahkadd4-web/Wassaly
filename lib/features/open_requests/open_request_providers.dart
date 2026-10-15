import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/course_route.dart';
import '../../models/open_request.dart';
import '../auth/auth_providers.dart';
import '../drivers/driver_providers.dart';
import 'open_request_repository.dart';

/// Au-dela de cette duree, une demande ouverte n'est plus montree aux livreurs.
const openRequestMaxAge = Duration(hours: 72);

final openRequestRepositoryProvider = Provider<OpenRequestRepository>(
  (ref) => OpenRequestRepository(ref.watch(firestoreProvider)),
);

List<OpenRequest> _parse(Iterable<Map<String, dynamic>> docs, List<String> ids) {
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

/// Adresse exacte d'une demande ouverte (client uniquement).
final openRequestRouteProvider =
    StreamProvider.family<CourseRoute?, String>((ref, openId) {
  return ref
      .watch(firestoreProvider)
      .collection('openRequests')
      .doc(openId)
      .collection('private')
      .doc('route')
      .snapshots()
      .map((s) => CourseRoute.fromMap(s.data()));
});

/// Offres recues sur une demande ouverte (client) : en negociation d'abord,
/// les plus recentes ensuite.
final offersProvider = StreamProvider.family<List<Offer>, String>((ref, openId) {
  return ref
      .watch(firestoreProvider)
      .collection('openRequests')
      .doc(openId)
      .collection('offers')
      .snapshots()
      .map((s) {
    final list = [for (final d in s.docs) Offer.fromMap(openId, d.id, d.data())];
    list.sort((a, b) {
      if (a.isOpen != b.isOpen) return a.isOpen ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  });
});

/// Offre du livreur connecte sur une demande ouverte (null s'il n'en a pas fait).
final myOfferProvider = StreamProvider.family<Offer?, String>((ref, openId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref
      .watch(firestoreProvider)
      .collection('openRequests')
      .doc(openId)
      .collection('offers')
      .doc(user.uid)
      .snapshots()
      .map((s) => s.exists ? Offer.fromMap(openId, s.id, s.data()!) : null);
});

/// Nombre de demandes ouvertes visibles par le livreur (pastille de l'onglet).
final openRequestsCountProvider = Provider<int>((ref) {
  return ref.watch(driverOpenRequestsProvider).value?.length ?? 0;
});
