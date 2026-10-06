class AppConfig {
  /// "Web client ID" de Google (client_type 3 dans android/app/google-services.json).
  /// C'est un identifiant public, pas un secret.
  static const String googleServerClientId =
      '1072750896345-muf560dk45rumk0dgtmqs7qr0cjr0322.apps.googleusercontent.com';

  /// Durée de l'essai gratuit des livreurs (2 mois).
  static const int trialDays = 60;
}
