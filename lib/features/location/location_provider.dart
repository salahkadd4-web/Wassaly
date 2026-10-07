import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/location_service.dart';

class ClientLocationState {
  const ClientLocationState({
    this.position,
    this.problem,
    this.loading = false,
  });

  final Position? position;
  final LocationProblem? problem;
  final bool loading;
}

/// Position du client (utilisee pour trier les livreurs par distance).
class ClientLocationNotifier extends Notifier<ClientLocationState> {
  @override
  ClientLocationState build() => const ClientLocationState();

  Future<void> refresh() async {
    state = ClientLocationState(position: state.position, loading: true);
    try {
      final position = await LocationService.currentPosition();
      state = ClientLocationState(position: position);
    } on LocationException catch (e) {
      state = ClientLocationState(problem: e.problem);
    } catch (_) {
      state = const ClientLocationState(problem: LocationProblem.unknown);
    }
  }
}

final clientLocationProvider =
    NotifierProvider<ClientLocationNotifier, ClientLocationState>(
      ClientLocationNotifier.new,
    );
