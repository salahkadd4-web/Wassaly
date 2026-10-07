class AppConfig {
  /// "Web client ID" de Google (client_type 3 dans android/app/google-services.json).
  /// C'est un identifiant public, pas un secret.
  static const String googleServerClientId =
      '1072750896345-muf560dk45rumk0dgtmqs7qr0cjr0322.apps.googleusercontent.com';

  /// Duree de l'essai gratuit des livreurs (2 mois).
  static const int trialDays = 60;

  /// Duree ajoutee a chaque abonnement valide.
  static const int subscriptionDays = 30;

  /// Prix mensuel affiche aux livreurs.
  static const int monthlyPriceDa = 1000;

  /// Indicatif pays utilise pour WhatsApp (Algerie).
  static const String countryCode = '213';

  /// Moyens de paiement affiches dans l'ecran d'abonnement du livreur.
  /// A MODIFIER avec vos vraies coordonnees (CCP, BaridiMob, ...).
  static const String paymentDetails =
      'BaridiMob / CCP : a renseigner dans lib/core/constants/app_config.dart';
}
