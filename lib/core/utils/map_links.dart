import 'package:url_launcher/url_launcher.dart';

import '../../models/geo_place.dart';
import 'formatters.dart';

Future<bool> _open(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

Future<bool> callPhone(String phone) =>
    _open(Uri(scheme: 'tel', path: normalizePhone(phone)));

Future<bool> openWhatsApp(String phone) =>
    _open(Uri.parse('https://wa.me/${toInternationalPhone(phone)}'));

/// URL Google Maps d'itineraire vers un lieu (GPS si dispo, sinon adresse).
Uri mapsDirectionsUri(GeoPlace place) {
  if (place.hasCoordinates) {
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${place.latitude},${place.longitude}',
    );
  }
  return Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': place.address,
  });
}

Future<bool> openDirections(GeoPlace place) => _open(mapsDirectionsUri(place));
