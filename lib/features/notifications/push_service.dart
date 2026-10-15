import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Notifications push (Firebase Cloud Messaging) pour les clients et les livreurs.
///
/// L'application enregistre le jeton de l'appareil dans Firestore
/// (`deviceTokens/{uid}`). Ce sont les Cloud Functions du dossier `functions/`
/// qui envoient les notifications (message, demande, suivi de livraison).
class PushService {
  PushService(this._db);

  final FirebaseFirestore _db;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Flux des nouveaux jetons (Firebase en change parfois).
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Demande l'autorisation (Android 13+), recupere le jeton et l'enregistre.
  Future<void> register(String uid, String lang) async {
    try {
      final settings = await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await _messaging.getToken();
      if (token != null) await saveToken(uid, token, lang);
    } catch (e) {
      debugPrint('Push : enregistrement impossible ($e)');
    }
  }

  Future<void> saveToken(String uid, String token, String lang) {
    return _db.collection('deviceTokens').doc(uid).set({
      'tokens': FieldValue.arrayUnion([token]),
      'lang': lang == 'ar' ? 'ar' : 'fr',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Retire l'appareil actuel (a la deconnexion), pour qu'il ne recoive plus
  /// les notifications de ce compte.
  Future<void> unregister(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await _db.collection('deviceTokens').doc(uid).set({
        'tokens': FieldValue.arrayRemove([token]),
        'lang': 'fr',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Push : desinscription impossible ($e)');
    }
  }
}
