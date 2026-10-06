// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Wassaly';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get login => 'Connexion';

  @override
  String get driversNearby => 'Livreurs à proximité';

  @override
  String get signInError =>
      'Connexion impossible. Vérifie ta connexion internet et réessaie.';

  @override
  String get completeProfile => 'Complète ton profil';

  @override
  String get phoneLabel => 'Numéro de téléphone';

  @override
  String get phoneHint => '0550 12 34 56';

  @override
  String get phoneInvalid => 'Numéro invalide (exemple : 0550 12 34 56)';

  @override
  String get roleQuestion => 'Quel est ton rôle ?';

  @override
  String get roleClient => 'Client';

  @override
  String get roleClientDesc => 'Je cherche un livreur';

  @override
  String get roleDriver => 'Livreur';

  @override
  String get roleDriverDesc => 'Je propose mes services de livraison';

  @override
  String get continueButton => 'Continuer';

  @override
  String get saveError => 'Enregistrement impossible. Réessaie.';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String hello(String name) {
    return 'Bonjour $name 👋';
  }

  @override
  String get clientHomeSoon =>
      'La liste des livreurs arrive à l\'étape suivante.';

  @override
  String get driverHomeSoon =>
      'Ton tableau de bord livreur arrive à l\'étape suivante.';

  @override
  String get profileLoadError =>
      'Impossible de charger ton profil. Réessaie plus tard.';
}
