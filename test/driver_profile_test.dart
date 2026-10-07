import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wassaly/models/driver_profile.dart';

DriverProfile _driver({
  String status = 'trial',
  Duration? endsIn,
  bool active = true,
  bool withLocation = true,
}) {
  return DriverProfile.fromMap('d1', {
    'name': 'Karim',
    'phone': '0550123456',
    'active': active,
    'latitude': withLocation ? 35.69 : null,
    'longitude': withLocation ? -0.63 : null,
    'subscriptionStatus': status,
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
}
