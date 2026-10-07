import 'package:intl/intl.dart';

import '../constants/app_config.dart';

/// Retire espaces, points et tirets d'un numero saisi.
String normalizePhone(String raw) => raw.replaceAll(RegExp(r'[\s.\-]'), '');

/// Mobile algerien : 05 / 06 / 07 + 8 chiffres.
bool isValidAlgerianMobile(String raw) =>
    RegExp(r'^0[5-7]\d{8}$').hasMatch(normalizePhone(raw));

/// 0550123456 -> 213550123456 (format attendu par wa.me).
String toInternationalPhone(String phone) {
  final p = normalizePhone(phone).replaceAll('+', '');
  if (p.startsWith(AppConfig.countryCode)) return p;
  if (p.startsWith('0')) return '${AppConfig.countryCode}${p.substring(1)}';
  return '${AppConfig.countryCode}$p';
}

/// 0550123456 -> 0550 12 34 56
String prettyPhone(String phone) {
  final p = normalizePhone(phone);
  if (p.length != 10) return phone;
  return '${p.substring(0, 4)} ${p.substring(4, 6)} '
      '${p.substring(6, 8)} ${p.substring(8)}';
}

/// 0.7 -> "700 m" ; 1.34 -> "1,3 km" (virgule en francais).
String formatDistance(double km, {bool comma = true}) {
  if (km < 1) {
    final m = (km * 1000 / 10).round() * 10;
    return '${m < 10 ? 10 : m} m';
  }
  final s = km.toStringAsFixed(1);
  return '${comma ? s.replaceAll('.', ',') : s} km';
}

String formatDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

String formatTime(DateTime d) => DateFormat('HH:mm').format(d);

String formatDateTime(DateTime d) => DateFormat('dd/MM/yyyy HH:mm').format(d);
