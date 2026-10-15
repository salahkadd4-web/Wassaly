import 'geo_place.dart';

/// Adresse exacte d'une course (document private/route) : lisible par le
/// client, et par le livreur seulement apres l'accord sur le prix.
class CourseRoute {
  const CourseRoute({required this.pickup, required this.delivery});

  final GeoPlace pickup;
  final GeoPlace delivery;

  Map<String, dynamic> toMap() => {
        'pickup': pickup.toMap(),
        'delivery': delivery.toMap(),
      };

  /// Null si le document n'existe pas (ou n'est pas encore lisible).
  static CourseRoute? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return CourseRoute(
      pickup: GeoPlace.fromMap(map['pickup'] as Map<String, dynamic>?),
      delivery: GeoPlace.fromMap(map['delivery'] as Map<String, dynamic>?),
    );
  }
}

/// Course saisie par le client (formulaire) : quartiers et distance publics,
/// adresse exacte privee.
class CourseDraft {
  const CourseDraft({
    required this.pickupArea,
    required this.deliveryArea,
    required this.route,
    required this.note,
    this.distanceKm,
  });

  final String pickupArea;
  final String deliveryArea;
  final CourseRoute route;
  final String note;
  final double? distanceKm;

  /// Champs publics du document (demande directe ou ouverte).
  Map<String, dynamic> publicFields() => {
        'pickupArea': pickupArea.trim(),
        'deliveryArea': deliveryArea.trim(),
        'distanceKm': distanceKm == null
            ? null
            : (distanceKm! * 10).roundToDouble() / 10,
        'note': note.trim(),
      };
}
