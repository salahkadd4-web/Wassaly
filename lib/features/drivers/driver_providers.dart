import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/driver_profile.dart';
import '../../services/location_service.dart';
import '../auth/auth_providers.dart';
import '../location/location_provider.dart';
import 'driver_repository.dart';

final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => DriverRepository(ref.watch(firestoreProvider)),
);

/// Profil public d'un livreur (drivers/{uid}).
final driverProvider = StreamProvider.family<DriverProfile?, String>((
  ref,
  uid,
) {
  return ref
      .watch(firestoreProvider)
      .collection('drivers')
      .doc(uid)
      .snapshots()
      .map((s) => s.exists ? DriverProfile.fromMap(s.id, s.data()!) : null);
});

/// Livreurs marques "actifs" (le filtre abonnement/position est fait ensuite).
final activeDriversProvider = StreamProvider<List<DriverProfile>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('drivers')
      .where('active', isEqualTo: true)
      .snapshots()
      .map(
        (s) =>
            s.docs.map((d) => DriverProfile.fromMap(d.id, d.data())).toList(),
      );
});

/// Livreurs disponibles tries par distance (sans distance si GPS refuse).
final nearbyDriversProvider = Provider<AsyncValue<List<DriverWithDistance>>>((
  ref,
) {
  final drivers = ref.watch(activeDriversProvider);
  final position = ref.watch(clientLocationProvider).position;

  return drivers.whenData((list) {
    final result = <DriverWithDistance>[];
    for (final d in list) {
      if (!d.isAvailable) continue;
      double? km;
      if (position != null) {
        km = LocationService.distanceKm(
          position.latitude,
          position.longitude,
          d.latitude!,
          d.longitude!,
        );
      }
      result.add(DriverWithDistance(d, km));
    }
    result.sort((a, b) {
      final da = a.distanceKm;
      final db = b.distanceKm;
      if (da == null && db == null)
        return a.driver.name.compareTo(b.driver.name);
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return result;
  });
});
