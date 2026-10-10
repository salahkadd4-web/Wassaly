import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/driver_profile.dart';
import '../../services/cloudinary_service.dart';
import '../auth/auth_providers.dart';
import 'verification_repository.dart';

final cloudinaryServiceProvider = Provider<CloudinaryService>(
  (ref) => CloudinaryService(),
);

final verificationRepositoryProvider = Provider<VerificationRepository>(
  (ref) => VerificationRepository(
    ref.watch(firestoreProvider),
    ref.watch(cloudinaryServiceProvider),
  ),
);

/// Profil livreur (drivers/{uid}) du compte connecte. Utilise par le routeur
/// pour bloquer un livreur dont la piece d'identite n'est pas validee.
final myDriverProvider = StreamProvider<DriverProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref
      .watch(firestoreProvider)
      .collection('drivers')
      .doc(user.uid)
      .snapshots()
      // Meme precaution que pour users/{uid} : on ignore un "document absent"
      // venant seulement du cache local.
      .where((s) => s.exists || !s.metadata.isFromCache)
      .map((s) => s.exists ? DriverProfile.fromMap(s.id, s.data()!) : null);
});

/// Piece d'identite d'un livreur (driverIdentity/{uid}) : lisible par le
/// livreur lui-meme et par les administrateurs uniquement.
class DriverIdentity {
  const DriverIdentity({required this.uid, required this.idUrl, this.rejectReason});

  final String uid;
  final String idUrl;
  final String? rejectReason;
}

final driverIdentityProvider =
    StreamProvider.family<DriverIdentity?, String>((ref, uid) {
  return ref
      .watch(firestoreProvider)
      .collection('driverIdentity')
      .doc(uid)
      .snapshots()
      .map((s) {
    final data = s.data();
    if (data == null) return null;
    return DriverIdentity(
      uid: uid,
      idUrl: (data['idUrl'] as String?) ?? '',
      rejectReason: data['rejectReason'] as String?,
    );
  });
});
