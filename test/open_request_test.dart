import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wassaly/core/constants/app_config.dart';
import 'package:wassaly/models/delivery_request.dart';
import 'package:wassaly/models/open_request.dart';

void main() {
  test('OpenRequest.fromMap lit une demande ouverte (quartiers publics)', () {
    final r = OpenRequest.fromMap('r1', {
      'clientId': 'c1',
      'clientName': 'Sara',
      'pickupArea': 'Centre-ville',
      'deliveryArea': 'Hai Sabah',
      'distanceKm': 3.2,
      'note': 'Colis fragile',
      'status': 'open',
      'createdAt': Timestamp.fromDate(DateTime(2026, 10, 7)),
    });
    expect(r.isOpen, isTrue);
    expect(r.pickupArea, 'Centre-ville');
    expect(r.distanceKm, 3.2);
    expect(r.note, 'Colis fragile');
  });

  test('une demande cloturee n\'est plus ouverte', () {
    final r = OpenRequest.fromMap('r2', {'status': 'closed'});
    expect(r.isOpen, isFalse);
  });

  group('tour de parole', () {
    DeliveryRequest req(String status, [String? lastBy]) => DeliveryRequest.fromMap(
          'r',
          {'status': status, 'lastBy': ?lastBy, 'price': 200},
        );

    test('demande envoyee : le livreur propose, le client attend', () {
      final r = req('pending');
      expect(r.myTurn(asDriver: true), isTrue);
      expect(r.myTurn(asDriver: false), isFalse);
      expect(r.awaitingAgreement, isTrue);
      expect(r.contactShared, isFalse);
    });

    test('le livreur a propose : au client de repondre', () {
      final r = req('negotiating', 'driver');
      expect(r.myTurn(asDriver: false), isTrue);
      expect(r.myTurn(asDriver: true), isFalse);
    });

    test('le client a contre-propose : au livreur de repondre', () {
      final r = req('negotiating', 'client');
      expect(r.myTurn(asDriver: true), isTrue);
      expect(r.myTurn(asDriver: false), isFalse);
    });

    test('accord conclu : plus de negociation, coordonnees partagees', () {
      final r = req('accepted', 'client');
      expect(r.myTurn(asDriver: true), isFalse);
      expect(r.myTurn(asDriver: false), isFalse);
      expect(r.contactShared, isTrue);
    });

    test('offre d\'une demande ouverte', () {
      final o = Offer.fromMap('o1', 'd1', {'price': 180, 'lastBy': 'client', 'status': 'open'});
      expect(o.myTurn(asDriver: true), isTrue);
      expect(o.myTurn(asDriver: false), isFalse);
      final refused = Offer.fromMap('o1', 'd1', {'price': 180, 'lastBy': 'client', 'status': 'refused'});
      expect(refused.myTurn(asDriver: true), isFalse);
    });
  });

  test('ancienne demande : adresse lue dans le document public', () {
    final r = DeliveryRequest.fromMap('r', {
      'status': 'completed',
      'pickup': {'address': 'Place 1er Novembre'},
      'delivery': {'address': 'Hai Sabah', 'latitude': 35.7, 'longitude': -0.6},
    });
    expect(r.legacyRoute?.pickup.address, 'Place 1er Novembre');
    expect(r.legacyRoute?.delivery.hasCoordinates, isTrue);
  });

  test('prix : 100 a 300 DA par pas de 10', () {
    expect(AppConfig.isValidPrice(100), isTrue);
    expect(AppConfig.isValidPrice(110), isTrue);
    expect(AppConfig.isValidPrice(300), isTrue);
    expect(AppConfig.isValidPrice(105), isFalse);
    expect(AppConfig.isValidPrice(90), isFalse);
    expect(AppConfig.isValidPrice(310), isFalse);
  });
}
