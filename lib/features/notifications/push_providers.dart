import 'dart:async';
import 'dart:ui' as ui;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
import '../auth/auth_providers.dart';
import '../common/home_tab_provider.dart';
import 'push_service.dart';

final pushServiceProvider = Provider<PushService>(
  (ref) => PushService(ref.watch(firestoreProvider)),
);

/// Index de l'onglet du tableau de bord livreur a ouvrir selon le type de
/// notification (champ `type` envoye par les Cloud Functions).
int? tabForNotification(Map<String, dynamic> data) {
  switch (data['type']) {
    case 'delivery_request':
      return 1; // Demandes
    case 'open_request':
      return 2; // Demandes ouvertes (clients)
    case 'message':
      return 3; // Messages
  }
  return null;
}

/// Active les notifications push pour le livreur connecte.
/// A observer depuis l'ecran d'accueil du livreur.
final driverPushProvider = Provider<void>((ref) {
  final user = ref.watch(authStateProvider).value;
  final role = ref.watch(userProfileProvider.select((p) => p.value?.role));
  if (user == null || role != 'driver') return;

  final lang = ref.watch(localeProvider)?.languageCode ??
      ui.PlatformDispatcher.instance.locale.languageCode;
  final push = ref.read(pushServiceProvider);

  unawaited(push.register(user.uid, lang));

  void open(RemoteMessage m) {
    final tab = tabForNotification(m.data);
    if (tab != null) ref.read(homeTabProvider.notifier).select(tab);
  }

  // Appui sur une notification (application en arriere-plan)...
  final opened = FirebaseMessaging.onMessageOpenedApp.listen(open);
  // ... ou application fermee puis ouverte par la notification.
  FirebaseMessaging.instance.getInitialMessage().then((m) {
    if (m != null) open(m);
  });
  final refresh = push.onTokenRefresh.listen(
    (token) => push.saveToken(user.uid, token, lang),
  );

  ref.onDispose(() {
    opened.cancel();
    refresh.cancel();
  });
});

/// Deconnexion : retire d'abord l'appareil des notifications du compte.
Future<void> signOutAndUnregisterPush(WidgetRef ref) async {
  final uid = ref.read(authStateProvider).value?.uid;
  if (uid != null) await ref.read(pushServiceProvider).unregister(uid);
  await ref.read(authServiceProvider).signOut();
}
