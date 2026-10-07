import 'package:flutter_test/flutter_test.dart';
import 'package:wassaly/core/utils/formatters.dart';

void main() {
  group('telephone', () {
    test('valide les mobiles algeriens', () {
      expect(isValidAlgerianMobile('0550 12 34 56'), isTrue);
      expect(isValidAlgerianMobile('0661234567'), isTrue);
      expect(isValidAlgerianMobile('0771.23.45.67'), isTrue);
    });

    test('refuse les numeros invalides', () {
      expect(isValidAlgerianMobile('0450123456'), isFalse);
      expect(isValidAlgerianMobile('055012345'), isFalse);
      expect(isValidAlgerianMobile(''), isFalse);
    });

    test('format international pour WhatsApp', () {
      expect(toInternationalPhone('0550123456'), '213550123456');
      expect(toInternationalPhone('+213550123456'), '213550123456');
    });

    test('affichage lisible', () {
      expect(prettyPhone('0550123456'), '0550 12 34 56');
    });
  });

  group('distance', () {
    test('metres sous 1 km', () {
      expect(formatDistance(0.7), '700 m');
    });

    test('kilometres avec virgule', () {
      expect(formatDistance(1.34), '1,3 km');
      expect(formatDistance(1.34, comma: false), '1.3 km');
    });
  });
}
