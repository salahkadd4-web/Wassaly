import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/course_route.dart';
import '../../models/delivery_request.dart';
import '../../models/open_request.dart';

class OpenRequestRepository {
  OpenRequestRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('openRequests');

  DocumentReference<Map<String, dynamic>> _offer(String openId, String driverId) =>
      _col.doc(openId).collection('offers').doc(driverId);

  /// Publication : quartiers et distance visibles des livreurs, adresse exacte
  /// dans private/route (lisible par le client seulement).
  Future<void> create({
    required String clientId,
    required String clientName,
    required CourseDraft course,
  }) {
    final ref = _col.doc();
    final batch = _db.batch()
      ..set(ref, {
        'clientId': clientId,
        'clientName': clientName,
        ...course.publicFields(),
        'status': OpenRequestStatus.open,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      })
      ..set(ref.collection('private').doc('route'), course.route.toMap());
    return batch.commit();
  }

  /// Le client retire sa demande : les livreurs ne la voient plus.
  Future<void> close(String id) {
    return _col.doc(id).update({
      'status': OpenRequestStatus.closed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Premiere offre d'un livreur.
  Future<void> makeOffer({
    required String openId,
    required String driverId,
    required String driverName,
    required int price,
  }) {
    return _offer(openId, driverId).set({
      'driverId': driverId,
      'driverName': driverName,
      'price': price,
      'lastBy': PriceBy.driver,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Contre-proposition, par le livreur ou par le client ([by]).
  Future<void> counterOffer({
    required String openId,
    required String driverId,
    required int price,
    required String by,
  }) {
    return _offer(openId, driverId).update({
      'price': price,
      'lastBy': by,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fin de la negociation avec ce livreur, a l'initiative de [by].
  Future<void> refuseOffer({
    required String openId,
    required String driverId,
    required String by,
  }) {
    return _offer(openId, driverId).update({
      'status': 'refused',
      'refusedBy': by,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
