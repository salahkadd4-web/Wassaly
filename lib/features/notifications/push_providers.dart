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

/// Index de l'onglet de l'accueil a ouvrir selon le type de notification
/// (champ `type` envoye par les Cloud Functions) et le role.
int? tabForNotification(Map<String, dynamic> data, {required bool isDriver}) {
  switch (data['type']) {
    case 'delivery_request':
    case 'request_update':
      return 1; // Demandes
    case 'open_request':
      return isDriver ? 2 : null; // Demandes ouvertes (livreur)
    case 'message':
      return isDriver ? 3 : 2; // Messages
  }
  return null;
}

/// Active les notifications push pour l'utilisateur connecte (client ou
/// livreur). A observer depuis l'ecran d'accueil.
final pushProvider = Provider<void>((ref) {
  final user = ref.watch(authStateProvider).value;
  final role = ref.watch(userProfileProvider.select((p) => p.value?.role));
  if (user == null || role == null) return;
  final isDriver = role == 'driver';

  final lang = ref.watch(localeProvider)?.languageCode ??
      ui.PlatformDispatcher.instance.locale.languageCode;
  final push = ref.read(pushServiceProvider);

  unawaited(push.register(user.uid, lang));

  void open(RemoteMessage m) {
    final tab = tabForNotification(m.data, isDriver: isDriver);
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
