import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _date(dynamic v) => v is Timestamp ? v.toDate() : null;

class DriverProfile {
  const DriverProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.active,
    required this.subscriptionStatus,
    this.photo,
    this.city,
    this.latitude,
    this.longitude,
    this.lastLocationUpdate,
    this.trialStart,
    this.subscriptionEnd,
  });

  final String uid;
  final String name;
  final String phone;
  final String? photo;
  final bool active;
  final String? city;
  final double? latitude;
  final double? longitude;
  final DateTime? lastLocationUpdate;
  final DateTime? trialStart;

  /// trial | paid | expired | suspended
  final String subscriptionStatus;
  final DateTime? subscriptionEnd;

  bool get hasLocation => latitude != null && longitude != null;

  bool get isSuspended => subscriptionStatus == 'suspended';

  /// Abonnement (essai ou paye) encore en cours et non suspendu.
  bool get subscriptionValid {
    final end = subscriptionEnd;
    if (end == null) return false;
    final okStatus =
        subscriptionStatus == 'trial' || subscriptionStatus == 'paid';
    return okStatus && end.isAfter(DateTime.now());
  }

  /// Statut reel : un essai ou un abonnement depasse est "expired".
  String get effectiveStatus {
    if (isSuspended) return 'suspended';
    final end = subscriptionEnd;
    if (end == null || !end.isAfter(DateTime.now())) return 'expired';
    return subscriptionStatus == 'paid' ? 'paid' : 'trial';
  }

  /// Jours restants (arrondi au-dessus), 0 si expire.
  int get daysLeft {
    final end = subscriptionEnd;
    if (end == null) return 0;
    final hours = end.difference(DateTime.now()).inHours;
    if (hours <= 0) return 0;
    return (hours / 24).ceil();
  }

  /// Visible par les clients : actif, abonnement valide, position connue.
  bool get isAvailable => active && subscriptionValid && hasLocation;

  factory DriverProfile.fromMap(String uid, Map<String, dynamic> map) {
    return DriverProfile(
      uid: uid,
      name: (map['name'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      photo: map['photo'] as String?,
      active: (map['active'] as bool?) ?? false,
      city: map['city'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      lastLocationUpdate: _date(map['lastLocationUpdate']),
      trialStart: _date(map['trialStart']),
      subscriptionStatus: (map['subscriptionStatus'] as String?) ?? 'expired',
      subscriptionEnd: _date(map['subscriptionEnd']),
    );
  }
}

/// Livreur + distance par rapport au client (null si position inconnue).
class DriverWithDistance {
  const DriverWithDistance(this.driver, this.distanceKm);

  final DriverProfile driver;
  final double? distanceKm;
}
