import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:wassaly/core/utils/geohash.dart';

double _km(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.sqrt(a));
}

bool _inBounds(String hash, List<(String, String)> bounds) =>
    bounds.any((b) => hash.compareTo(b.$1) >= 0 && hash.compareTo(b.$2) <= 0);

void main() {
  test('geohash de reference (geofire)', () {
    expect(geohashForLocation(57.64911, 10.40744), 'u4pruydqqv');
    expect(geohashForLocation(0, 0), '7zzzzzzzzz');
    expect(geohashForLocation(35.6971, -0.6308, precision: 5).length, 5);
  });

  test('tout livreur a moins de 10 km d\'Oran est couvert par les plages', () {
    const lat = 35.6971, lng = -0.6308; // Oran
    final bounds = geohashQueryBounds(lat, lng, 10000);
    expect(bounds, isNotEmpty);
    expect(bounds.length, lessThanOrEqualTo(9));

    final rnd = math.Random(42);
    var inside = 0;
    for (var i = 0; i < 2000; i++) {
      final pLat = lat + (rnd.nextDouble() - 0.5) * 0.25;
      final pLng = lng + (rnd.nextDouble() - 0.5) * 0.3;
      if (_km(lat, lng, pLat, pLng) > 10) continue;
      inside++;
      expect(_inBounds(geohashForLocation(pLat, pLng), bounds), isTrue,
          reason: 'point ($pLat, $pLng)');
    }
    expect(inside, greaterThan(200));
  });

  test('un livreur a Alger (350 km) n\'est pas dans les plages d\'Oran', () {
    final bounds = geohashQueryBounds(35.6971, -0.6308, 10000);
    expect(_inBounds(geohashForLocation(36.7538, 3.0588), bounds), isFalse);
  });
}
