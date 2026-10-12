import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/app_config.dart';

class ProfileRepository {
  ProfileRepository(this._db);

  final FirebaseFirestore _db;

  /// Crée phones/{numéro} (unicité), users/{uid} (privé) et, pour un livreur,
  /// drivers/{uid} (public) dans une seule écriture groupée.
  /// Pour un livreur, [idPhotoUrl] (pièce d'identité déjà envoyée sur
  /// Cloudinary) est obligatoire : elle est enregistrée dans
  /// driverIdentity/{uid} et le compte démarre "pending" (bloqué jusqu'à la
  /// validation de l'administrateur).
  /// [phone] doit être normalisé (10 chiffres). Si le numéro est déjà pris,
  /// l'écriture échoue avec le code `permission-denied`.
  Future<void> createProfile({
    required User user,
    required String phone,
    required String role,
    String? idPhotoUrl,
  }) async {
    final displayName = user.displayName?.trim() ?? '';
    final email = user.email ?? '';
    final name = displayName.isNotEmpty ? displayName : email.split('@').first;

    final batch = _db.batch();

    // Reserve le numero : refuse par les regles s'il est deja pris.
    batch.set(_db.collection('phones').doc(phone), {
      'uid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(_db.collection('users').doc(user.uid), {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'photo': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (role == 'driver') {
      if (idPhotoUrl == null || idPhotoUrl.isEmpty) {
        throw ArgumentError('La piece d\'identite est obligatoire.');
      }
      batch.set(_db.collection('driverIdentity').doc(user.uid), {
        'uid': user.uid,
        'idUrl': idPhotoUrl,
        'submittedAt': FieldValue.serverTimestamp(),
      });
      final trialEnd = DateTime.now().add(
        const Duration(days: AppConfig.trialDays),
      );
      // Profil public : sans le numero (il reste dans users/{uid}, prive).
      batch.set(_db.collection('drivers').doc(user.uid), {
        'name': name,
        'photo': user.photoURL,
        'active': false,
        'city': null,
        'latitude': null,
        'longitude': null,
        'lastLocationUpdate': null,
        'trialStart': FieldValue.serverTimestamp(),
        'subscriptionStatus': 'trial',
        'subscriptionEnd': Timestamp.fromDate(trialEnd),
        'verificationStatus': 'pending',
      });
    }

    await batch.commit();
  }
}
