import '../../models/delivery_request.dart';

/// Periodes de calcul du chiffre d'affaires.
enum RevenuePeriod { today, week, month, total }

/// Chiffre d'affaires d'un livreur, calcule a partir de ses livraisons terminees.
///
/// Seules les demandes au statut "completed" comptent. Le montant est celui
/// saisi par le livreur a la fin de la course. Les anciennes livraisons sans
/// montant ne rapportent rien mais sont signalees dans [withoutAmount].
class RevenueSummary {
  const RevenueSummary({
    this.today = 0,
    this.week = 0,
    this.month = 0,
    this.total = 0,
    this.deliveries = 0,
    this.todayDeliveries = 0,
    this.weekDeliveries = 0,
    this.monthDeliveries = 0,
    this.withoutAmount = 0,
  });

  /// Aujourd'hui (depuis minuit, heure locale).
  final int today;

  /// 7 derniers jours, aujourd'hui compris.
  final int week;

  /// Depuis le 1er du mois en cours.
  final int month;

  /// Depuis toujours.
  final int total;

  /// Nombre de livraisons terminees (toutes periodes).
  final int deliveries;
  final int todayDeliveries;
  final int weekDeliveries;
  final int monthDeliveries;

  /// Livraisons terminees sans montant (avant la fonction chiffre d'affaires).
  final int withoutAmount;

  int amountFor(RevenuePeriod p) => switch (p) {
        RevenuePeriod.today => today,
        RevenuePeriod.week => week,
        RevenuePeriod.month => month,
        RevenuePeriod.total => total,
      };

  int deliveriesFor(RevenuePeriod p) => switch (p) {
        RevenuePeriod.today => todayDeliveries,
        RevenuePeriod.week => weekDeliveries,
        RevenuePeriod.month => monthDeliveries,
        RevenuePeriod.total => deliveries,
      };
}

/// Calcule le chiffre d'affaires d'un ensemble de livraisons.
/// [now] est injectable pour les tests.
RevenueSummary computeRevenue(
  Iterable<DeliveryRequest> requests, {
  DateTime? now,
}) {
  final n = now ?? DateTime.now();
  final startOfToday = DateTime(n.year, n.month, n.day);
  final startOfWeek = DateTime(n.year, n.month, n.day - 6);
  final startOfMonth = DateTime(n.year, n.month);

  var today = 0, week = 0, month = 0, total = 0;
  var count = 0, todayCount = 0, weekCount = 0, monthCount = 0;
  var withoutAmount = 0;

  for (final r in requests) {
    if (!r.isCompleted) continue;
    final amount = r.amount ?? 0;
    final when = (r.completedAt ?? r.updatedAt).toLocal();

    count++;
    total += amount;
    if (r.amount == null) withoutAmount++;

    if (!when.isBefore(startOfMonth)) {
      month += amount;
      monthCount++;
    }
    if (!when.isBefore(startOfWeek)) {
      week += amount;
      weekCount++;
    }
    if (!when.isBefore(startOfToday)) {
      today += amount;
      todayCount++;
    }
  }

  return RevenueSummary(
    today: today,
    week: week,
    month: month,
    total: total,
    deliveries: count,
    todayDeliveries: todayCount,
    weekDeliveries: weekCount,
    monthDeliveries: monthCount,
    withoutAmount: withoutAmount,
  );
}

/// Chiffre d'affaires de chaque livreur (cle = uid du livreur).
Map<String, RevenueSummary> computeRevenueByDriver(
  Iterable<DeliveryRequest> requests, {
  DateTime? now,
}) {
  final grouped = <String, List<DeliveryRequest>>{};
  for (final r in requests) {
    if (!r.isCompleted || r.driverId.isEmpty) continue;
    grouped.putIfAbsent(r.driverId, () => []).add(r);
  }
  return {
    for (final e in grouped.entries) e.key: computeRevenue(e.value, now: now),
  };
}
