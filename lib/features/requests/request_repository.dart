import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/course_route.dart';
import '../../models/delivery_request.dart';

class RequestRepository {
  RequestRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('deliveryRequests');

  /// Demande a un livreur choisi. L'adresse exacte va dans private/route
  /// (meme ecriture groupee) : le livreur ne la lira qu'apres l'accord.
  Future<void> create({
    required String clientId,
    required String clientName,
    required String driverId,
    required String driverName,
    required CourseDraft course,
  }) {
    final ref = _col.doc();
    final batch = _db.batch()
      ..set(ref, {
        'clientId': clientId,
        'driverId': driverId,
        'clientName': clientName,
        'driverName': driverName,
        ...course.publicFields(),
        'status': RequestStatus.pending,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      })
      ..set(ref.collection('private').doc('route'), course.route.toMap());
    return batch.commit();
  }

  /// Proposition du livreur (premiere offre ou reponse au client).
  Future<void> proposeAsDriver(String id, int price) {
    return _col.doc(id).update({
      'status': RequestStatus.negotiating,
      'price': price,
      'lastBy': PriceBy.driver,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Contre-proposition du client.
  Future<void> counterAsClient(String id, int price) {
    return _col.doc(id).update({
      'price': price,
      'lastBy': PriceBy.client,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Refus (livreur) ou annulation (client). L'accord, lui, passe par
  /// BillingFunctions.agreeDelivery (serveur).
  Future<void> setStatus(String id, String status) {
    return _col.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Termine une livraison acceptee ; [amount] est le prix convenu.
  Future<void> complete(String id, int amount) {
    return _col.doc(id).update({
      'status': RequestStatus.completed,
      'amount': amount,
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
