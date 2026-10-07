/// Un lieu : adresse ecrite et/ou position GPS.
class GeoPlace {
  const GeoPlace({required this.address, this.latitude, this.longitude});

  final String address;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  Map<String, dynamic> toMap() => {
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory GeoPlace.fromMap(Map<String, dynamic>? map) {
    return GeoPlace(
      address: (map?['address'] as String?) ?? '',
      latitude: (map?['latitude'] as num?)?.toDouble(),
      longitude: (map?['longitude'] as num?)?.toDouble(),
    );
  }
}
