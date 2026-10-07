import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onglet selectionne dans l'accueil (client ou livreur).
class HomeTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final homeTabProvider = NotifierProvider<HomeTabNotifier, int>(
  HomeTabNotifier.new,
);
