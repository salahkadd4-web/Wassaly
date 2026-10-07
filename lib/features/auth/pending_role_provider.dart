import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Role choisi sur l'ecran d'accueil ('client' ou 'driver').
/// Il pre-selectionne le role dans l'ecran d'inscription.
class PendingRoleNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? role) => state = role;
}

final pendingRoleProvider = NotifierProvider<PendingRoleNotifier, String?>(
  PendingRoleNotifier.new,
);
