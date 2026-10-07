import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/location_service.dart';

void showSnack(BuildContext context, String message) {
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

/// Message utilisateur pour un probleme de localisation.
String locationMessage(AppLocalizations t, LocationProblem problem) {
  switch (problem) {
    case LocationProblem.serviceDisabled:
      return t.locationServiceOff;
    case LocationProblem.denied:
      return t.locationDenied;
    case LocationProblem.deniedForever:
      return t.locationDeniedForever;
    case LocationProblem.unknown:
      return t.locationUnknown;
  }
}

/// Lance une action externe (appel, WhatsApp, Maps) et previent en cas d'echec.
Future<void> launchWithFeedback(
  BuildContext context,
  Future<bool> action,
) async {
  final t = AppLocalizations.of(context)!;
  final ok = await action;
  if (!ok && context.mounted) {
    showSnack(context, t.cannotOpenLink);
  }
}
