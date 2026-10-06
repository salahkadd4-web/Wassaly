import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'models/user_profile.dart';
import 'profile_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(firebaseAuthProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(firestoreProvider)),
);

/// Utilisateur Firebase connecté (null si déconnecté).
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

/// Profil Firestore (users/{uid}). Émet null si le profil n'existe pas encore.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots()
      // On ignore un "document absent" venant seulement du cache local,
      // pour ne pas renvoyer un utilisateur existant vers l'inscription.
      .where((s) => s.exists || !s.metadata.isFromCache)
      .map((s) => s.exists ? UserProfile.fromMap(s.id, s.data()!) : null);
});
