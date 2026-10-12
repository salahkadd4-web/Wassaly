import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wassaly/models/driver_profile.dart';

DriverProfile _driver({
  String status = 'trial',
  Duration? endsIn,
  bool active = true,
  bool withLocation = true,
  String? verification,
  String? plan,
  bool blocked = false,
}) {
  return DriverProfile.fromMap('d1', {
    'name': 'Karim',
    'active': active,
    'latitude': withLocation ? 35.69 : null,
    'longitude': withLocation ? -0.63 : null,
    'subscriptionStatus': status,
    'verificationStatus': ?verification,
    'plan': ?plan,
    'billingBlocked': blocked,
    'subscriptionEnd': endsIn == null
        ? null
        : Timestamp.fromDate(DateTime.now().add(endsIn)),
  });
}

void main() {
  test('essai en cours : valide et disponible', () {
    final d = _driver(endsIn: const Duration(days: 10));
    expect(d.subscriptionValid, isTrue);
    expect(d.effectiveStatus, 'trial');
    expect(d.isAvailable, isTrue);
  });

  test('essai depasse : expire et invisible', () {
    final d = _driver(endsIn: const Duration(days: -1));
    expect(d.subscriptionValid, isFalse);
    expect(d.effectiveStatus, 'expired');
    expect(d.isAvailable, isFalse);
  });

  test('abonnement paye valide', () {
    final d = _driver(status: 'paid', endsIn: const Duration(days: 20));
    expect(d.effectiveStatus, 'paid');
    expect(d.daysLeft, inInclusiveRange(19, 20));
  });

  test('suspendu : jamais visible', () {
    final d = _driver(status: 'suspended', endsIn: const Duration(days: 20));
    expect(d.subscriptionValid, isFalse);
    expect(d.effectiveStatus, 'suspended');
    expect(d.isAvailable, isFalse);
  });

  test('sans position : invisible', () {
    final d = _driver(endsIn: const Duration(days: 5), withLocation: false);
    expect(d.isAvailable, isFalse);
  });

  test('piece d\'identite en attente : bloque et invisible', () {
    final d = _driver(endsIn: const Duration(days: 10), verification: 'pending');
    expect(d.isVerified, isFalse);
    expect(d.isVerificationPending, isTrue);
    expect(d.isAvailable, isFalse);
  });

  test('piece refusee : bloque et invisible', () {
    final d = _driver(endsIn: const Duration(days: 10), verification: 'rejected');
    expect(d.isVerificationRejected, isTrue);
    expect(d.isAvailable, isFalse);
  });

  test('piece validee : disponible', () {
    final d = _driver(endsIn: const Duration(days: 10), verification: 'approved');
    expect(d.isVerified, isTrue);
    expect(d.isAvailable, isTrue);
  });

  test('ancien livreur sans champ de verification : considere verifie', () {
    final d = _driver(endsIn: const Duration(days: 10));
    expect(d.isVerified, isTrue);
  });

  group('formule a la livraison', () {
    test('active et sous le plafond : disponible, facturee', () {
      final d = _driver(status: 'per_delivery', endsIn: const Duration(days: -40));
      expect(d.subscriptionValid, isTrue);
      expect(d.isPerDeliveryMode, isTrue);
      expect(d.effectiveStatus, 'per_delivery');
      expect(d.isAvailable, isTrue);
    });

    test('dette de 1 000 DA atteinte : bloque et invisible', () {
      final d = _driver(status: 'per_delivery', blocked: true);
      expect(d.subscriptionValid, isFalse);
      expect(d.effectiveStatus, 'blocked');
      expect(d.isAvailable, isFalse);
    });

    test('essai fini avec "a la livraison" choisi : bascule avant le job serveur', () {
      final d = _driver(endsIn: const Duration(days: -1), plan: 'per_delivery');
      expect(d.subscriptionValid, isTrue);
      expect(d.isPerDeliveryMode, isTrue);
      expect(d.effectiveStatus, 'per_delivery');
    });

    test('essai en cours avec "a la livraison" choisi : pas encore facture', () {
      final d = _driver(endsIn: const Duration(days: 5), plan: 'per_delivery');
      expect(d.isPerDeliveryMode, isFalse);
      expect(d.effectiveStatus, 'trial');
      expect(d.hasPendingPlanChange, isTrue);
    });

    test('essai fini avec "mensuel" choisi mais non paye : expire', () {
      final d = _driver(endsIn: const Duration(days: -1), plan: 'monthly');
      expect(d.subscriptionValid, isFalse);
      expect(d.effectiveStatus, 'expired');
    });

    test('suspendu reste suspendu', () {
      final d = _driver(status: 'suspended', plan: 'per_delivery');
      expect(d.subscriptionValid, isFalse);
      expect(d.effectiveStatus, 'suspended');
    });
  });
}
