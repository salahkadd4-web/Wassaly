import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? _date(dynamic v) => v is Timestamp ? v.toDate() : null;

/// Formules proposees apres l'essai gratuit.
class DriverPlan {
  static const monthly = 'monthly';
  static const perDelivery = 'per_delivery';
}

/// Profil public d'un livreur (drivers/{uid}).
///
/// Ne contient pas le numero de telephone : il reste dans users/{uid} et
/// n'est partage qu'apres l'acceptation d'une livraison.
class DriverProfile {
  const DriverProfile({
    required this.uid,
    required this.name,
    required this.active,
    required this.subscriptionStatus,
    this.photo,
    this.city,
    this.latitude,
    this.longitude,
    this.lastLocationUpdate,
    this.trialStart,
    this.subscriptionEnd,
    this.verificationStatus = 'approved',
    this.plan,
    this.billingBlocked = false,
  });

  final String uid;
  final String name;
  final String? photo;
  final bool active;
  final String? city;
  final double? latitude;
  final double? longitude;
  final DateTime? lastLocationUpdate;
  final DateTime? trialStart;

  /// trial | paid | per_delivery | expired | suspended
  final String subscriptionStatus;

  /// Fin de l'essai ou du mois paye (sans objet en formule a la livraison).
  final DateTime? subscriptionEnd;

  /// Formule qui s'applique apres la periode en cours : monthly | per_delivery,
  /// ou null si le livreur n'a pas encore choisi.
  final String? plan;

  /// Formule a la livraison : dette de 1 000 DA atteinte, livreur bloque
  /// jusqu'au paiement. Ecrit uniquement par le serveur et l'admin.
  final bool billingBlocked;

  /// Verification de la piece d'identite : pending | approved | rejected.
  /// Les livreurs inscrits avant cette fonction n'ont pas le champ : ils
  /// sont consideres comme verifies ("approved" par defaut).
  final String verificationStatus;

  bool get isVerified => verificationStatus == 'approved';
  bool get isVerificationPending => verificationStatus == 'pending';
  bool get isVerificationRejected => verificationStatus == 'rejected';

  bool get hasLocation => latitude != null && longitude != null;

  bool get isSuspended => subscriptionStatus == 'suspended';

  bool get isInTrial => subscriptionStatus == 'trial';

  /// Essai ou mois paye encore en cours.
  bool periodRunningAt(DateTime now) {
    final end = subscriptionEnd;
    return (subscriptionStatus == 'trial' || subscriptionStatus == 'paid') &&
        end != null &&
        end.isAfter(now);
  }

  /// Facture 50 DA par livraison acceptee (meme regle que functions/billing.js) :
  /// formule active, ou periode terminee avec "a la livraison" choisi.
  bool perDeliveryModeAt(DateTime now) {
    if (subscriptionStatus == 'per_delivery') return true;
    return (subscriptionStatus == 'trial' || subscriptionStatus == 'paid') &&
        !periodRunningAt(now) &&
        plan == DriverPlan.perDelivery;
  }

  bool get isPerDeliveryMode => perDeliveryModeAt(DateTime.now());

  /// Le livreur peut travailler cote abonnement (la piece d'identite est
  /// verifiee a part, voir [isAvailable]).
  bool subscriptionValidAt(DateTime now) {
    if (isSuspended) return false;
    if (periodRunningAt(now)) return true;
    return perDeliveryModeAt(now) && !billingBlocked;
  }

  bool get subscriptionValid => subscriptionValidAt(DateTime.now());

  /// Statut affiche : trial | paid | per_delivery | blocked | expired | suspended.
  String effectiveStatusAt(DateTime now) {
    if (isSuspended) return 'suspended';
    if (periodRunningAt(now)) return subscriptionStatus;
    if (perDeliveryModeAt(now)) return billingBlocked ? 'blocked' : 'per_delivery';
    return 'expired';
  }

  String get effectiveStatus => effectiveStatusAt(DateTime.now());

  /// Formule qui s'appliquera a la fin de la periode en cours, si elle change.
  bool get hasPendingPlanChange {
    final status = effectiveStatus;
    if (status == 'trial') return plan != null;
    if (status == 'paid') return plan == DriverPlan.perDelivery;
    if (status == 'per_delivery' || status == 'blocked') {
      return plan == DriverPlan.monthly;
    }
    return false;
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
  bool get isAvailable =>
      active && isVerified && subscriptionValid && hasLocation;

  factory DriverProfile.fromMap(String uid, Map<String, dynamic> map) {
    return DriverProfile(
      uid: uid,
      name: (map['name'] as String?) ?? '',
      photo: map['photo'] as String?,
      active: (map['active'] as bool?) ?? false,
      city: map['city'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      lastLocationUpdate: _date(map['lastLocationUpdate']),
      trialStart: _date(map['trialStart']),
      subscriptionStatus: (map['subscriptionStatus'] as String?) ?? 'expired',
      subscriptionEnd: _date(map['subscriptionEnd']),
      verificationStatus: (map['verificationStatus'] as String?) ?? 'approved',
      plan: map['plan'] as String?,
      billingBlocked: (map['billingBlocked'] as bool?) ?? false,
    );
  }
}

/// Livreur + distance par rapport au client (null si position inconnue).
class DriverWithDistance {
  const DriverWithDistance(this.driver, this.distanceKm);

  final DriverProfile driver;
  final double? distanceKm;
}
