import 'package:geolocator/geolocator.dart';

enum LocationProblem { serviceDisabled, denied, deniedForever, unknown }

class LocationException implements Exception {
  const LocationException(this.problem);

  final LocationProblem problem;

  @override
  String toString() => 'LocationException($problem)';
}

class LocationService {
  /// Position actuelle, apres verification du service GPS et des permissions.
  static Future<Position> currentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationException(LocationProblem.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(LocationProblem.denied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationProblem.deniedForever);
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (_) {
      throw const LocationException(LocationProblem.unknown);
    }
  }

  /// Distance approximative (ligne droite) en kilometres.
  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }

  static Future<bool> openAppSettings() => Geolocator.openAppSettings();

  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();
}
