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

  // Formule "a la livraison". Doit rester aligne sur functions/billing.js :
  // c'est le serveur qui debite, ces valeurs ne servent qu'a l'affichage.

  /// Prix d'une livraison acceptee.
  static const int perDeliveryPriceDa = 50;

  /// Dette a partir de laquelle le livreur est bloque (20 livraisons).
  static const int debtLimitDa = 1000;

  /// Dette a partir de laquelle on previent le livreur.
  static const int debtWarnDa = 800;

  /// Une annulation du client est remboursee si elle arrive dans ce delai...
  static const int refundWindowHours = 2;

  /// ... et dans la limite de ce nombre de remboursements par mois.
  static const int maxRefundsPerMonth = 3;

  /// Prix de course que le livreur choisit a l'acceptation (pas de saisie
  /// libre). Doit rester identique a DELIVERY_PRICES_DA (functions/billing.js).
  static const List<int> deliveryPricesDa = [100, 150, 200, 250, 300];

  /// Rayon de recherche des livreurs autour du client.
  static const double searchRadiusKm = 10;

  /// Region des Cloud Functions (REGION dans functions/index.js).
  static const String functionsRegion = 'europe-west1';

  /// Indicatif pays utilise pour WhatsApp (Algerie).
  static const String countryCode = '213';

  /// Moyens de paiement affiches dans l'ecran d'abonnement du livreur.
  /// A MODIFIER avec vos vraies coordonnees (CCP, BaridiMob, ...).
  static const String paymentDetails =
      'BaridiMob / CCP : 00799999002449753636';

  /// Cloudinary : stockage des pieces d'identite des livreurs.
  /// Le nom du "cloud" est la partie apres le @ de votre CLOUDINARY_URL
  /// (cloudinary://API_KEY:API_SECRET@NOM_DU_CLOUD).
  /// Ne mettez JAMAIS la cle API ni le secret dans l'application.
  static const String cloudinaryCloudName = 'xa3xrbpw';

  /// Nom d'un "upload preset" de type Unsigned (voir GUIDE.md, section 6 quater).
  static const String cloudinaryUploadPreset = 'wassaly';

  /// Dossier Cloudinary des pieces d'identite.
  static const String cloudinaryIdFolder = 'wassaly/driver_ids';
}
