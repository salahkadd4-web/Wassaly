import 'dart:math' as math;

/// Geohash : position -> texte dont les prefixes communs designent des zones
/// voisines. Permet a Firestore de chercher "les livreurs a moins de 10 km"
/// avec quelques requetes par plage (orderBy geohash, startAt / endAt).
///
/// Portage de l'algorithme de geofire-common (bibliotheque officielle de
/// Firebase pour ce besoin) : geohashForLocation et geohashQueryBounds.

const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
const int _bitsPerChar = 5;
const int _maxBitsPrecision = 22 * _bitsPerChar;
const double _earthMeriCircumference = 40007860;
const double _metersPerDegreeLatitude = 110574;
const double _earthEqRadius = 6378137.0;
const double _e2 = 0.00669447819799;
const double _epsilon = 1e-12;

/// Precision stockee sur les livreurs (10 caracteres, environ 1 m).
const int geohashPrecision = 10;

String geohashForLocation(double lat, double lng, {int precision = geohashPrecision}) {
  var latMin = -90.0, latMax = 90.0, lngMin = -180.0, lngMax = 180.0;
  final hash = StringBuffer();
  var hashVal = 0;
  var bits = 0;
  var even = true;
  while (hash.length < precision) {
    final val = even ? lng : lat;
    final mid = even ? (lngMin + lngMax) / 2 : (latMin + latMax) / 2;
    if (val > mid) {
      hashVal = (hashVal << 1) + 1;
      if (even) {
        lngMin = mid;
      } else {
        latMin = mid;
      }
    } else {
      hashVal = hashVal << 1;
      if (even) {
        lngMax = mid;
      } else {
        latMax = mid;
      }
    }
    even = !even;
    if (bits < 4) {
      bits++;
    } else {
      bits = 0;
      hash.write(_base32[hashVal]);
      hashVal = 0;
    }
  }
  return hash.toString();
}

double _log2(double x) => math.log(x) / math.ln2;

double _metersToLongitudeDegrees(double distance, double latitude) {
  final radians = latitude * math.pi / 180;
  final num = math.cos(radians) * _earthEqRadius * math.pi / 180;
  final denom = 1 / math.sqrt(1 - _e2 * math.sin(radians) * math.sin(radians));
  final deltaDeg = num * denom;
  if (deltaDeg < _epsilon) return distance > 0 ? 360 : 0;
  return math.min(360, distance / deltaDeg);
}

double _longitudeBitsForResolution(double resolution, double latitude) {
  final degs = _metersToLongitudeDegrees(resolution, latitude);
  return degs.abs() > 0.000001 ? math.max(1, _log2(360 / degs)) : 1;
}

double _latitudeBitsForResolution(double resolution) =>
    math.min(_log2(_earthMeriCircumference / 2 / resolution), _maxBitsPrecision.toDouble());

double _wrapLongitude(double lng) {
  if (lng <= 180 && lng >= -180) return lng;
  final adjusted = lng + 180;
  if (adjusted > 0) return (adjusted % 360) - 180;
  return 180 - (-adjusted % 360);
}

int _boundingBoxBits(double lat, double size) {
  final latDelta = size / _metersPerDegreeLatitude;
  final latNorth = math.min(90.0, lat + latDelta);
  final latSouth = math.max(-90.0, lat - latDelta);
  final bitsLat = _latitudeBitsForResolution(size).floor() * 2;
  final bitsLongNorth = _longitudeBitsForResolution(size, latNorth).floor() * 2 - 1;
  final bitsLongSouth = _longitudeBitsForResolution(size, latSouth).floor() * 2 - 1;
  return [bitsLat, bitsLongNorth, bitsLongSouth, _maxBitsPrecision].reduce(math.min);
}

List<(double, double)> _boundingBoxCoordinates(double lat, double lng, double radius) {
  final latDegrees = radius / _metersPerDegreeLatitude;
  final latNorth = math.min(90.0, lat + latDegrees);
  final latSouth = math.max(-90.0, lat - latDegrees);
  final longDegs = math.max(
    _metersToLongitudeDegrees(radius, latNorth),
    _metersToLongitudeDegrees(radius, latSouth),
  );
  return [
    (lat, lng),
    (lat, _wrapLongitude(lng - longDegs)),
    (lat, _wrapLongitude(lng + longDegs)),
    (latNorth, lng),
    (latNorth, _wrapLongitude(lng - longDegs)),
    (latSouth, lng),
    (latNorth, _wrapLongitude(lng + longDegs)),
    (latSouth, _wrapLongitude(lng - longDegs)),
    (latSouth, _wrapLongitude(lng + longDegs)),
  ];
}

(String, String) _geohashQuery(String geohash, int bits) {
  final precision = (bits / _bitsPerChar).ceil();
  if (geohash.length < precision) return (geohash, '$geohash~');
  final hash = geohash.substring(0, precision);
  final base = hash.substring(0, hash.length - 1);
  final lastValue = _base32.indexOf(hash[hash.length - 1]);
  final significantBits = bits - base.length * _bitsPerChar;
  final unusedBits = _bitsPerChar - significantBits;
  final startValue = (lastValue >> unusedBits) << unusedBits;
  final endValue = startValue + (1 << unusedBits);
  if (endValue > 31) return ('$base${_base32[startValue]}', '$base~');
  return ('$base${_base32[startValue]}', '$base${_base32[endValue]}');
}

/// Plages de geohash [debut, fin] qui couvrent le cercle de [radiusM] metres
/// autour du centre. Les resultats doivent ensuite etre filtres par distance
/// reelle (les plages couvrent un peu plus que le cercle).
List<(String, String)> geohashQueryBounds(double lat, double lng, double radiusM) {
  final queryBits = math.max(1, _boundingBoxBits(lat, radiusM));
  final precision = (queryBits / _bitsPerChar).ceil();
  final result = <(String, String)>[];
  for (final (cLat, cLng) in _boundingBoxCoordinates(lat, lng, radiusM)) {
    final q = _geohashQuery(geohashForLocation(cLat, cLng, precision: precision), queryBits);
    if (!result.contains(q)) result.add(q);
  }
  return result;
}
