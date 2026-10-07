import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wassaly/models/open_request.dart';

void main() {
  test('OpenRequest.fromMap lit une demande ouverte', () {
    final r = OpenRequest.fromMap('r1', {
      'clientId': 'c1',
      'clientName': 'Sara',
      'clientPhone': '0550123456',
      'pickup': {'address': 'Place 1er Novembre'},
      'delivery': {'address': 'Hai Sabah', 'latitude': 35.7, 'longitude': -0.6},
      'note': 'Colis fragile',
      'status': 'open',
      'createdAt': Timestamp.fromDate(DateTime(2026, 10, 7)),
    });
    expect(r.isOpen, isTrue);
    expect(r.delivery.hasCoordinates, isTrue);
    expect(r.pickup.hasCoordinates, isFalse);
    expect(r.note, 'Colis fragile');
  });

  test('une demande cloturee n\'est plus ouverte', () {
    final r = OpenRequest.fromMap('r2', {'status': 'closed'});
    expect(r.isOpen, isFalse);
  });
}
