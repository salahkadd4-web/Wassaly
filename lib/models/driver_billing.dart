import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_config.dart';

/// Compteurs tenus par le serveur pour reperer les comportements anormaux.
class BillingStats {
  const BillingStats({
    this.accepted = 0,
    this.completed = 0,
    this.cancelledAfterAccept = 0,
    this.conversations = 0,
    this.reports = 0,
  });

  /// Livraisons acceptees (demandes directes et demandes ouvertes prises).
  final int accepted;
  final int completed;

  /// Annulees par le client alors que le livreur avait accepte.
  final int cancelledAfterAccept;

  /// Conversations ouvertes avec ce livreur.
  final int conversations;

  /// Clients differents qui ont signale ce livreur.
  final int reports;

  factory BillingStats.fromMap(Map<String, dynamic>? map) {
    int n(String k) => (map?[k] as num?)?.toInt() ?? 0;
    return BillingStats(
      accepted: n('accepted'),
      completed: n('completed'),
      cancelledAfterAccept: n('cancelledAfterAccept'),
      conversations: n('conversations'),
      reports: n('reports'),
    );
  }
}

/// Facturation d'un livreur (driverBilling/{uid}) : ecrite par les Cloud
/// Functions et l'admin, lue par le livreur et l'admin.
class DriverBilling {
  const DriverBilling({
    required this.uid,
    this.debt = 0,
    this.refundsThisMonth = 0,
    this.refundMonth,
    this.blockedSince,
    this.stats = const BillingStats(),
  });

  final String uid;

  /// Dette en DA (formule a la livraison).
  final int debt;
  final int refundsThisMonth;
  final String? refundMonth;
  final DateTime? blockedSince;
  final BillingStats stats;

  /// Facturation d'un livreur qui n'a encore rien accepte.
  const DriverBilling.empty(this.uid)
      : debt = 0,
        refundsThisMonth = 0,
        refundMonth = null,
        blockedSince = null,
        stats = const BillingStats();

  bool get atLimit => debt >= AppConfig.debtLimitDa;
  bool get nearLimit => debt >= AppConfig.debtWarnDa;

  /// Livraisons encore possibles avant le blocage.
  int get deliveriesLeft {
    final left = (AppConfig.debtLimitDa - debt) ~/ AppConfig.perDeliveryPriceDa;
    return left < 0 ? 0 : left;
  }

  /// Part de la dette (0..1) par rapport au plafond.
  double get debtRatio => (debt / AppConfig.debtLimitDa).clamp(0, 1).toDouble();

  factory DriverBilling.fromMap(String uid, Map<String, dynamic>? map) {
    if (map == null) return DriverBilling.empty(uid);
    final blocked = map['blockedSince'];
    return DriverBilling(
      uid: uid,
      debt: (map['debt'] as num?)?.toInt() ?? 0,
      refundsThisMonth: (map['refundsThisMonth'] as num?)?.toInt() ?? 0,
      refundMonth: map['refundMonth'] as String?,
      blockedSince: blocked is Timestamp ? blocked.toDate() : null,
      stats: BillingStats.fromMap(map['stats'] as Map<String, dynamic>?),
    );
  }
}

/// Mouvement de l'historique : debit d'une livraison, remboursement, paiement.
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.createdAt,
  });

  final String id;

  /// charge | refund | payment
  final String type;
  final int amount;
  final DateTime createdAt;

  /// Effet sur la dette : + pour un debit, - pour un remboursement ou un paiement.
  int get signedAmount => type == 'charge' ? amount : -amount;

  factory LedgerEntry.fromMap(String id, Map<String, dynamic> map) {
    final created = map['createdAt'];
    return LedgerEntry(
      id: id,
      type: (map['type'] as String?) ?? 'charge',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }
}

/// Motifs pour lesquels un livreur apparait dans l'onglet admin "Suspects".
enum SuspicionReason {
  /// Plus de 30 % de livraisons annulees apres acceptation (au moins 5 acceptees).
  cancellations,

  /// Plus de 3 conversations par livraison acceptee (au moins 5 conversations) :
  /// il discute beaucoup mais accepte peu, signe d'arrangements hors application.
  chatsWithoutDeliveries,

  /// Signale par au moins 2 clients differents.
  reports,

  /// Bloque pour dette depuis plus de 7 jours.
  unpaidDebt,
}

List<SuspicionReason> suspicionReasons(DriverBilling b, {DateTime? now}) {
  final s = b.stats;
  final reasons = <SuspicionReason>[];
  if (s.accepted >= 5 && s.cancelledAfterAccept / s.accepted > 0.3) {
    reasons.add(SuspicionReason.cancellations);
  }
  if (s.conversations >= 5 &&
      s.conversations > 3 * (s.accepted == 0 ? 1 : s.accepted)) {
    reasons.add(SuspicionReason.chatsWithoutDeliveries);
  }
  if (s.reports >= 2) reasons.add(SuspicionReason.reports);
  final since = b.blockedSince;
  if (b.atLimit &&
      since != null &&
      (now ?? DateTime.now()).difference(since) > const Duration(days: 7)) {
    reasons.add(SuspicionReason.unpaidDebt);
  }
  return reasons;
}
