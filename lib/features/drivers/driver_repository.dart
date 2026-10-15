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

  Future<void> setCity(String uid, String city) {
    final value = city.trim();
    return _doc(uid).update({'city': value.isEmpty ? null : value});
  }
}
