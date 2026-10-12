import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';

/// Motifs de signalement d'un livreur.
class ReportReason {
  /// Le livreur a propose de passer hors de l'application.
  static const offApp = 'off_app';
  static const notDelivered = 'not_delivered';
  static const behavior = 'behavior';
  static const other = 'other';

  static const all = [offApp, notDelivered, behavior, other];
}

/// Signalement refuse par les regles : livreur deja signale par ce client,
/// ou aucun echange (conversation, demande) entre eux.
class ReportNotAllowedException implements Exception {
  const ReportNotAllowedException();
}

class ReportRepository {
  ReportRepository(this._db);

  final FirebaseFirestore _db;

  /// Un signalement par couple client / livreur (id = clientId_driverId).
  /// Autorise apres une conversation, ou avec [requestId] d'une demande entre eux.
  Future<void> report({
    required String clientId,
    required String driverId,
    required String reason,
    required String note,
    String? requestId,
  }) async {
    final ref = _db.collection('reports').doc('${clientId}_$driverId');
    try {
      await ref.set({
        'clientId': clientId,
        'driverId': driverId,
        'reason': reason,
        'note': note.trim(),
        'requestId': ?requestId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      // Deja signale ("set" devient une mise a jour, refusee) ou aucun echange.
      if (e.code == 'permission-denied') throw const ReportNotAllowedException();
      rethrow;
    }
  }
}

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepository(ref.watch(firestoreProvider)),
);
