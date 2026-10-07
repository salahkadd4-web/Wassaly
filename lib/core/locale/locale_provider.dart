import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'wassaly_locale';

/// null = suivre la langue du telephone. Le choix est memorise sur l'appareil.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code == 'fr' || code == 'ar') {
        state = Locale(code!);
      }
    } catch (_) {
      // Pas grave : on garde la langue du telephone.
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_prefKey);
      } else {
        await prefs.setString(_prefKey, locale.languageCode);
      }
    } catch (_) {}
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
