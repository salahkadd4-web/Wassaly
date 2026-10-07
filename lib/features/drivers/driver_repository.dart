import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class DriverRepository {
  DriverRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('drivers').doc(uid);

  /// Active/desactive le livreur. Si [position] est fournie, elle est enregistree.
  Future<void> setActive(String uid, bool active, {Position? position}) {
    return _doc(uid).update({
      'active': active,
      if (position != null) ...{
        'latitude': position.latitude,
        'longitude': position.longitude,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      },
    });
  }

  Future<void> updateLocation(String uid, Position position) {
    return _doc(uid).update({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setCity(String uid, String city) {
    final value = city.trim();
    return _doc(uid).update({'city': value.isEmpty ? null : value});
  }
}
