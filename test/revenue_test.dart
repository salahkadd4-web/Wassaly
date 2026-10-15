import 'package:flutter_test/flutter_test.dart';
import 'package:wassaly/core/utils/formatters.dart';
import 'package:wassaly/core/utils/revenue.dart';
import 'package:wassaly/models/delivery_request.dart';

DeliveryRequest _req({
  required String driverId,
  required String status,
  int? amount,
  DateTime? completedAt,
}) {
  final when = completedAt ?? DateTime(2026, 1, 1);
  return DeliveryRequest(
    id: '${driverId}_${when.microsecondsSinceEpoch}_$status',
    clientId: 'c',
    driverId: driverId,
    clientName: 'Client',
    driverName: 'Livreur',
    pickupArea: 'A',
    deliveryArea: 'B',
    note: '',
    status: status,
    createdAt: when,
    updatedAt: when,
    amount: amount,
    completedAt: completedAt,
  );
}

void main() {
  // Samedi 10 octobre 2026, 15h00.
  final now = DateTime(2026, 10, 10, 15);

  group('chiffre d\'affaires', () {
    test('ne compte que les livraisons terminees', () {
      final r = computeRevenue([
        _req(driverId: 'd1', status: 'completed', amount: 500, completedAt: now),
        _req(driverId: 'd1', status: 'accepted', amount: 900, completedAt: now),
        _req(driverId: 'd1', status: 'cancelled', amount: 900, completedAt: now),
        _req(driverId: 'd1', status: 'pending'),
      ], now: now);
      expect(r.total, 500);
      expect(r.deliveries, 1);
    });

    test('separe aujourd\'hui, 7 jours, mois et total', () {
      final r = computeRevenue([
        _req(driverId: 'd1', status: 'completed', amount: 1000,
            completedAt: DateTime(2026, 10, 10, 9)), // aujourd'hui
        _req(driverId: 'd1', status: 'completed', amount: 2000,
            completedAt: DateTime(2026, 10, 5)), // 5 jours
        _req(driverId: 'd1', status: 'completed', amount: 4000,
            completedAt: DateTime(2026, 10, 1)), // ce mois, > 7 jours
        _req(driverId: 'd1', status: 'completed', amount: 8000,
            completedAt: DateTime(2026, 9, 20)), // mois dernier
      ], now: now);
      expect(r.today, 1000);
      expect(r.week, 3000);
      expect(r.month, 7000);
      expect(r.total, 15000);
      expect(r.deliveries, 4);
      expect(r.monthDeliveries, 3);
    });

    test('une ancienne livraison sans montant compte 0 et est signalee', () {
      final r = computeRevenue([
        _req(driverId: 'd1', status: 'completed', completedAt: now),
        _req(driverId: 'd1', status: 'completed', amount: 700, completedAt: now),
      ], now: now);
      expect(r.total, 700);
      expect(r.deliveries, 2);
      expect(r.withoutAmount, 1);
    });

    test('regroupe par livreur', () {
      final map = computeRevenueByDriver([
        _req(driverId: 'd1', status: 'completed', amount: 300, completedAt: now),
        _req(driverId: 'd2', status: 'completed', amount: 500, completedAt: now),
        _req(driverId: 'd1', status: 'completed', amount: 200, completedAt: now),
        _req(driverId: 'd2', status: 'rejected'),
      ], now: now);
      expect(map['d1']!.total, 500);
      expect(map['d2']!.total, 500);
      expect(map['d2']!.deliveries, 1);
    });

    test('amountFor et deliveriesFor suivent la periode', () {
      final r = computeRevenue([
        _req(driverId: 'd1', status: 'completed', amount: 100, completedAt: now),
      ], now: now);
      expect(r.amountFor(RevenuePeriod.today), 100);
      expect(r.deliveriesFor(RevenuePeriod.total), 1);
    });
  });

  group('montant', () {
    test('separateur de milliers', () {
      expect(formatAmount(0), '0');
      expect(formatAmount(950), '950');
      expect(formatAmount(1000), '1 000');
      expect(formatAmount(12500), '12 500');
      expect(formatAmount(1234567), '1 234 567');
    });
  });
}
