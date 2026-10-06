import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// null = suivre la langue du téléphone.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void setLocale(Locale? locale) => state = locale;
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
