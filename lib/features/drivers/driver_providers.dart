import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../core/utils/geohash.dart';
import '../../models/driver_profile.dart';
import '../../services/location_service.dart';
import '../auth/auth_providers.dart';
import '../location/location_provider.dart';
import 'driver_repository.dart';

final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => DriverRepository(ref.watch(firestoreProvider)),
);

/// Profil public d'un livreur (drivers/{uid}).
final driverProvider = StreamProvider.family<DriverProfile?, String>((ref, uid) {
  return ref
      .watch(firestoreProvider)
      .collection('drivers')
      .doc(uid)
      .snapshots()
      .map((s) => s.exists ? DriverProfile.fromMap(s.id, s.data()!) : null);
});

/// Fusionne les resultats de plusieurs flux (une requete par plage de geohash).
Stream<List<T>> _mergeLatest<T>(List<Stream<List<T>>> streams) {
  final latest = List<List<T>?>.filled(streams.length, null);
  final subs = <StreamSubscription<List<T>>>[];
  late final StreamController<List<T>> controller;
  controller = StreamController<List<T>>(
    onListen: () {
      for (var i = 0; i < streams.length; i++) {
        subs.add(streams[i].listen(
          (value) {
            latest[i] = value;
            if (latest.every((l) => l != null)) {
              controller.add([for (final l in latest) ...l!]);
            }
          },
          onError: controller.addError,
        ));
      }
    },
    onCancel: () async {
      for (final s in subs) {
        await s.cancel();
      }
    },
  );
  return controller.stream;
}

/// Livreurs disponibles a moins de [AppConfig.searchRadiusKm] du client,
/// du plus proche au plus loin. Firestore ne lit que les livreurs en ligne
/// dont le geohash tombe dans la zone (index active + geohash), puis la
/// distance reelle est verifiee. Liste vide tant que la position du client
/// est inconnue (le bandeau de localisation l'explique).
final nearbyDriversProvider = StreamProvider<List<DriverWithDistance>>((ref) {
  final position = ref.watch(clientLocationProvider.select((s) => s.position));
  if (position == null) return Stream.value(const []);

  final lat = position.latitude;
  final lng = position.longitude;
  final drivers = ref.watch(firestoreProvider).collection('drivers');
  final queries = [
    for (final (start, end) in geohashQueryBounds(lat, lng, AppConfig.searchRadiusKm * 1000))
      drivers
          .where('active', isEqualTo: true)
          .orderBy('geohash')
          .startAt([start])
          .endAt([end])
          .snapshots()
          .map((s) => [for (final d in s.docs) DriverProfile.fromMap(d.id, d.data())]),
  ];

  return _mergeLatest(queries).map((list) {
    final byUid = <String, DriverWithDistance>{};
    for (final d in list) {
      if (!d.isAvailable) continue;
      final km = LocationService.distanceKm(lat, lng, d.latitude!, d.longitude!);
      if (km > AppConfig.searchRadiusKm) continue;
      byUid[d.uid] = DriverWithDistance(d, km);
    }
    return byUid.values.toList()
      ..sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
  });
});
