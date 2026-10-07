import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/geo_place.dart';
import '../../models/open_request.dart';

class OpenRequestRepository {
  OpenRequestRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('openRequests');

  Future<void> create({
    required String clientId,
    required String clientName,
    required String clientPhone,
    required GeoPlace pickup,
    required GeoPlace delivery,
    required String note,
  }) {
    return _col.add({
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'pickup': pickup.toMap(),
      'delivery': delivery.toMap(),
      'note': note.trim(),
      'status': OpenRequestStatus.open,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Le client retire sa demande : les livreurs ne la voient plus.
  Future<void> close(String id) {
    return _col.doc(id).update({
      'status': OpenRequestStatus.closed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
