import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/delivery_request.dart';
import '../../models/geo_place.dart';

class RequestRepository {
  RequestRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('deliveryRequests');

  Future<void> create({
    required String clientId,
    required String clientName,
    required String clientPhone,
    required String driverId,
    required String driverName,
    required GeoPlace pickup,
    required GeoPlace delivery,
    required String note,
  }) {
    return _col.add({
      'clientId': clientId,
      'driverId': driverId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'driverName': driverName,
      'pickup': pickup.toMap(),
      'delivery': delivery.toMap(),
      'note': note.trim(),
      'status': RequestStatus.pending,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setStatus(String id, String status) {
    return _col.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
