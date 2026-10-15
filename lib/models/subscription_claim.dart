import 'package:cloud_firestore/cloud_firestore.dart';

/// Types de paiement declares par un livreur.
class ClaimKind {
  /// Un mois de formule mensuelle (+ la dette eventuelle).
  static const monthly = 'monthly';

  /// Reglement de la dette de la formule a la livraison.
  static const debt = 'debt';
}

/// Reference de paiement normalisee : majuscules, lettres et chiffres
/// seulement ("bm 123-45" -> "BM12345"). Sert d'identifiant dans paymentRefs
/// pour qu'une meme reference ne soit declaree qu'une fois.
String normalizePaymentReference(String raw) =>
    raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

/// Paiement declare par un livreur (reference BaridiMob / CCP), valide par l'admin.
class SubscriptionClaim {
  const SubscriptionClaim({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.reference,
    required this.status,
    required this.createdAt,
    this.kind = ClaimKind.monthly,
    this.amount = 0,
  });

  final String id;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String reference;

  /// pending | approved | rejected
  final String status;
  final DateTime createdAt;

  /// monthly | debt (les anciennes demandes sans type sont mensuelles).
  final String kind;

  /// Montant declare en DA (0 pour les anciennes demandes).
  final int amount;

  bool get isDebt => kind == ClaimKind.debt;

  bool get isPending => status == 'pending';

  factory SubscriptionClaim.fromMap(String id, Map<String, dynamic> map) {
    return SubscriptionClaim(
      id: id,
      driverId: (map['driverId'] as String?) ?? '',
      driverName: (map['driverName'] as String?) ?? '',
      driverPhone: (map['driverPhone'] as String?) ?? '',
      reference: (map['reference'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'pending',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      kind: (map['kind'] as String?) ?? ClaimKind.monthly,
      amount: (map['amount'] as num?)?.toInt() ?? 0,
    );
  }
}
