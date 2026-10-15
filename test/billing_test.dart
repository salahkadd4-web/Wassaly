import 'package:flutter_test/flutter_test.dart';
import 'package:wassaly/core/utils/phone_guard.dart';
import 'package:wassaly/models/delivery_request.dart';
import 'package:wassaly/models/driver_billing.dart';
import 'package:wassaly/models/driver_profile.dart';
import 'package:wassaly/models/subscription_claim.dart';

DriverBilling _billing({
  int debt = 0,
  int accepted = 0,
  int cancelled = 0,
  int chats = 0,
  int reports = 0,
  int ratingCount = 0,
  int ratingSum = 0,
  DateTime? blockedSince,
}) {
  return DriverBilling(
    uid: 'd1',
    debt: debt,
    blockedSince: blockedSince,
    stats: BillingStats(
      accepted: accepted,
      cancelledAfterAccept: cancelled,
      conversations: chats,
      reports: reports,
      ratingCount: ratingCount,
      ratingSum: ratingSum,
    ),
  );
}

void main() {
  group('numeros dans un texte', () {
    test('formats algeriens detectes', () {
      for (final text in [
        '0550123456',
        'appelle moi au 0550 12 34 56',
        '06.61.23.45.67',
        '07-70-12-34-56',
        '+213 550 12 34 56',
        '00213550123456',
        'رقمي ٠٥٥٠١٢٣٤٥٦',
      ]) {
        expect(containsPhoneNumber(text), isTrue, reason: text);
      }
    });

    test('textes ordinaires acceptes', () {
      for (final text in [
        'Colis fragile, 2e etage',
        'Le prix est 1500 DA',
        'Rendez-vous a 14h30 devant la poste',
        'Code postal 31000',
        '',
      ]) {
        expect(containsPhoneNumber(text), isFalse, reason: text);
      }
    });
  });

  group('dette', () {
    test('livraisons restantes avant le blocage', () {
      expect(_billing().deliveriesLeft, 20);
      expect(_billing(debt: 350).deliveriesLeft, 13);
      expect(_billing(debt: 1000).deliveriesLeft, 0);
    });

    test('seuils d\'alerte et de blocage', () {
      expect(_billing(debt: 750).nearLimit, isFalse);
      expect(_billing(debt: 800).nearLimit, isTrue);
      expect(_billing(debt: 950).atLimit, isFalse);
      expect(_billing(debt: 1000).atLimit, isTrue);
      expect(_billing(debt: 500).debtRatio, 0.5);
    });

    test('document absent : facturation vide', () {
      final b = DriverBilling.fromMap('d1', null);
      expect(b.debt, 0);
      expect(b.stats.accepted, 0);
    });
  });

  group('suspicion', () {
    final now = DateTime(2026, 10, 12);

    test('livreur normal : rien', () {
      expect(suspicionReasons(_billing(accepted: 20, cancelled: 2, chats: 30)), isEmpty);
    });

    test('trop d\'annulations apres acceptation', () {
      expect(
        suspicionReasons(_billing(accepted: 10, cancelled: 4)),
        [SuspicionReason.cancellations],
      );
      // Trop peu de livraisons pour conclure.
      expect(suspicionReasons(_billing(accepted: 4, cancelled: 3)), isEmpty);
    });

    test('beaucoup de discussions, peu de livraisons', () {
      expect(
        suspicionReasons(_billing(accepted: 2, chats: 12)),
        [SuspicionReason.chatsWithoutDeliveries],
      );
      expect(
        suspicionReasons(_billing(accepted: 0, chats: 5)),
        [SuspicionReason.chatsWithoutDeliveries],
      );
      expect(suspicionReasons(_billing(accepted: 0, chats: 4)), isEmpty);
    });

    test('signalements', () {
      expect(suspicionReasons(_billing(reports: 1)), isEmpty);
      expect(suspicionReasons(_billing(reports: 2)), [SuspicionReason.reports]);
    });

    test('bloque pour dette depuis plus de 7 jours', () {
      final old = _billing(debt: 1000, blockedSince: now.subtract(const Duration(days: 8)));
      final recent = _billing(debt: 1000, blockedSince: now.subtract(const Duration(days: 2)));
      expect(suspicionReasons(old, now: now), [SuspicionReason.unpaidDebt]);
      expect(suspicionReasons(recent, now: now), isEmpty);
    });
  });

  test('ancienne demande de paiement sans type : mensuelle', () {
    final c = SubscriptionClaim.fromMap('c1', {'reference': 'ABC', 'status': 'pending'});
    expect(c.kind, ClaimKind.monthly);
    expect(c.isDebt, isFalse);
    expect(c.amount, 0);
  });

  group('reference de paiement', () {
    test('normalisee : majuscules, sans espaces ni tirets', () {
      expect(normalizePaymentReference(' bm 123-45/x '), 'BM12345X');
      expect(normalizePaymentReference('0079 9999 0024'), '007999990024');
      expect(normalizePaymentReference('---'), '');
    });

    test('deux saisies differentes de la meme reference donnent la meme cle', () {
      expect(
        normalizePaymentReference('BM-8841 2'),
        normalizePaymentReference('bm 88412'),
      );
    });
  });

  group('notes', () {
    test('moyenne du livreur', () {
      final d = DriverProfile.fromMap('d1', {'ratingCount': 4, 'ratingSum': 18});
      expect(d.ratingAverage, 4.5);
      expect(DriverProfile.fromMap('d2', {}).ratingAverage, isNull);
    });

    test('note moyenne basse : suspect a partir de 3 avis', () {
      expect(
        suspicionReasons(_billing(ratingCount: 3, ratingSum: 6)),
        [SuspicionReason.lowRating],
      );
      expect(suspicionReasons(_billing(ratingCount: 2, ratingSum: 2)), isEmpty);
      expect(suspicionReasons(_billing(ratingCount: 10, ratingSum: 40)), isEmpty);
    });
  });

  test('prix convenu et note lus sur la demande', () {
    final r = DeliveryRequest.fromMap('r1', {'status': 'accepted', 'price': 200, 'rated': 5});
    expect(r.price, 200);
    expect(r.rated, 5);
    final old = DeliveryRequest.fromMap('r2', {'status': 'accepted'});
    expect(old.price, isNull);
    expect(old.rated, isNull);
  });
}
