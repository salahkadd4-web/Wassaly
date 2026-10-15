import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/utils/geohash.dart';

class DriverRepository {
  DriverRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('drivers').doc(uid);

  /// Position + geohash (recherche des livreurs par zone cote client).
  static Map<String, dynamic> _position(Position p) => {
        'latitude': p.latitude,
        'longitude': p.longitude,
        'geohash': geohashForLocation(p.latitude, p.longitude),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      };

  /// Active/desactive le livreur. Si [position] est fournie, elle est enregistree.
  Future<void> setActive(String uid, bool active, {Position? position}) {
    return _doc(uid).update({
      'active': active,
      if (position != null) ..._position(position),
    });
  }

  Future<void> updateLocation(String uid, Position position) {
    return _doc(uid).update(_position(position));
  }

  /// Formule pour la suite : monthly | per_delivery (effet a la fin de la
  /// periode en cours, calcule a la lecture).
  Future<void> setPlan(String uid, String plan) => _doc(uid).update({'plan': plan});

  /// Le livreur signale qu'il a atteint le plafond de dette : il disparait
  /// des listes des clients (seul l'admin le debloque, apres paiement).
  Future<void> markBlocked(String uid) => _doc(uid).update({'billingBlocked': true});

  Future<void> setCity(String uid, String city) {
    final value = city.trim();
    return _doc(uid).update({'city': value.isEmpty ? null : value});
  }
}
