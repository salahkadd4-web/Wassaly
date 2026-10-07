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
  String get signInError =>
      'Connexion impossible. Vérifiez votre connexion internet et réessayez.';

  @override
  String get completeProfile => 'Complétez votre profil';

  @override
  String get phoneLabel => 'Numéro de téléphone';

  @override
  String get phoneHint => '0550 12 34 56';

  @override
  String get phoneInvalid => 'Numéro invalide (exemple : 0550 12 34 56)';

  @override
  String get roleQuestion => 'Quel est votre rôle ?';

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
  String get saveError => 'Enregistrement impossible. Réessayez.';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get profileLoadError =>
      'Impossible de charger votre profil. Réessayez plus tard.';

  @override
  String hello(String name) {
    return 'Bonjour $name';
  }

  @override
  String get genericError => 'Une erreur est survenue. Réessayez.';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get remove => 'Retirer';

  @override
  String get language => 'Langue';

  @override
  String get cannotOpenLink =>
      'Impossible d\'ouvrir l\'application correspondante.';

  @override
  String get tabDrivers => 'Livreurs';

  @override
  String get tabRequests => 'Demandes';

  @override
  String get messages => 'Messages';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get myRequests => 'Mes demandes';

  @override
  String get driversNearby => 'Livreurs à proximité';

  @override
  String get driversAvailableNearby =>
      'Les livreurs disponibles les plus proches de vous';

  @override
  String get noDriversAvailable =>
      'Aucun livreur disponible pour le moment. Tirez vers le bas pour actualiser.';

  @override
  String get available => 'Disponible';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get call => 'Appeler';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get message => 'Message';

  @override
  String get openInMaps => 'Itinéraire';

  @override
  String get locationServiceOff =>
      'Le GPS est désactivé. Activez la localisation pour voir les livreurs proches.';

  @override
  String get locationDenied =>
      'Permission de localisation refusée. Autorisez-la pour trier les livreurs par distance.';

  @override
  String get locationDeniedForever =>
      'La localisation est bloquée. Autorisez-la dans les paramètres de l\'application.';

  @override
  String get locationUnknown =>
      'Position introuvable. Vérifiez le GPS et réessayez.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get gpsPosition => 'Position GPS';

  @override
  String get gpsShared => 'Position GPS partagée';

  @override
  String get driverProfile => 'Profil du livreur';

  @override
  String get driverNotFound => 'Livreur introuvable.';

  @override
  String get city => 'Ville';

  @override
  String get distance => 'Distance';

  @override
  String get positionUpdated => 'Position mise à jour';

  @override
  String get sendRequest => 'Envoyer une demande de livraison';

  @override
  String get driverNotAvailableHint =>
      'Ce livreur n\'est pas disponible pour le moment.';

  @override
  String get newRequest => 'Nouvelle demande';

  @override
  String get requestTo => 'Demande adressée à ce livreur';

  @override
  String get pickup => 'Récupération';

  @override
  String get delivery => 'Livraison';

  @override
  String get addressLabel => 'Adresse';

  @override
  String get placeRequired =>
      'Saisissez une adresse ou partagez votre position.';

  @override
  String get shareMyPosition => 'Partager ma position actuelle';

  @override
  String get noteOptional => 'Note (facultatif)';

  @override
  String get sendToDriver => 'Envoyer au livreur';

  @override
  String get requestSent => 'Demande envoyée au livreur.';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusAccepted => 'Acceptée';

  @override
  String get statusRejected => 'Refusée';

  @override
  String get statusCompleted => 'Terminée';

  @override
  String get statusCancelled => 'Annulée';

  @override
  String get accept => 'Accepter';

  @override
  String get reject => 'Refuser';

  @override
  String get markCompleted => 'Marquer comme terminée';

  @override
  String get cancelRequest => 'Annuler la demande';

  @override
  String get confirmCancelTitle => 'Annuler la demande ?';

  @override
  String get confirmCancelBody => 'Le livreur sera informé de l\'annulation.';

  @override
  String get noRequestsClient => 'Aucune demande pour le moment.';

  @override
  String get noRequestsDriver => 'Aucune demande reçue pour le moment.';

  @override
  String notifNewRequest(String name) {
    return 'Nouvelle demande de $name';
  }

  @override
  String notifRequestCancelled(String name) {
    return '$name a annulé sa demande';
  }

  @override
  String notifRequestAccepted(String name) {
    return '$name a accepté votre demande';
  }

  @override
  String notifRequestRejected(String name) {
    return '$name a refusé votre demande';
  }

  @override
  String get notifRequestCompleted => 'Votre livraison est terminée';

  @override
  String get noConversations => 'Aucune conversation pour le moment.';

  @override
  String get startConversation => 'Envoyez le premier message.';

  @override
  String get typeMessage => 'Écrire un message';

  @override
  String get send => 'Envoyer';

  @override
  String get sendError => 'Message non envoyé. Réessayez.';

  @override
  String get yourAvailability => 'Votre disponibilité';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusInactive => 'Inactif';

  @override
  String get activeHint =>
      'Les clients proches de vous peuvent vous voir et vous contacter.';

  @override
  String get inactiveHint =>
      'Vous êtes masqué. Activez-vous pour recevoir des demandes.';

  @override
  String get activate => 'Je suis disponible';

  @override
  String get deactivate => 'Me rendre indisponible';

  @override
  String get updateMyPosition => 'Mettre à jour ma position';

  @override
  String get positionUpdatedOk => 'Position mise à jour.';

  @override
  String get cityNotSet => 'Ville non renseignée';

  @override
  String get editCity => 'Modifier la ville';

  @override
  String get subscriptionBlocked =>
      'Votre abonnement est expiré ou suspendu. Renouvelez-le pour être visible.';

  @override
  String get subscription => 'Abonnement';

  @override
  String get subTrial => 'Essai gratuit';

  @override
  String get subPaid => 'Abonnement actif';

  @override
  String get subExpired => 'Expiré';

  @override
  String get subSuspended => 'Suspendu';

  @override
  String expiresOn(String date) {
    return 'Expire le $date';
  }

  @override
  String daysLeft(String count) {
    return '$count jour(s) restant(s)';
  }

  @override
  String get subscriptionExpiredMsg =>
      'Votre abonnement n\'est plus valide : vous n\'apparaissez plus aux clients.';

  @override
  String get manageSubscription => 'Gérer mon abonnement';

  @override
  String get renewSubscription => 'Renouveler mon abonnement';

  @override
  String priceLine(String price) {
    return '$price DA par mois';
  }

  @override
  String get paymentSteps =>
      '1. Effectuez le paiement avec les coordonnées ci-dessous.\n2. Saisissez la référence du paiement et envoyez.\n3. L\'administrateur valide et ajoute 30 jours à votre abonnement.';

  @override
  String get paymentReference => 'Référence du paiement';

  @override
  String get paymentReferenceRequired => 'Saisissez la référence du paiement.';

  @override
  String get iHavePaid => 'J\'ai payé, envoyer';

  @override
  String get claimSent => 'Demande envoyée. L\'administrateur va la valider.';

  @override
  String get claimAlreadyPending =>
      'Une demande est déjà en cours de validation.';

  @override
  String get claimsHistory => 'Historique des demandes';

  @override
  String get noClaims => 'Aucune demande de renouvellement.';

  @override
  String get claimPending => 'En validation';

  @override
  String get claimApproved => 'Validée';

  @override
  String get claimRejected => 'Refusée';

  @override
  String get adminPanel => 'Administration';

  @override
  String get accessDenied => 'Accès réservé à l\'administrateur.';

  @override
  String get adminDrivers => 'Livreurs';

  @override
  String get adminPayments => 'Paiements';

  @override
  String get adminClients => 'Clients';

  @override
  String get adminRequests => 'Demandes';

  @override
  String get adminNoDrivers => 'Aucun livreur inscrit.';

  @override
  String get adminNoClients => 'Aucun client inscrit.';

  @override
  String get adminNoClaims => 'Aucun paiement en attente.';

  @override
  String get adminExtend => 'Prolonger de 30 jours';

  @override
  String get adminExtended => 'Abonnement prolongé de 30 jours.';

  @override
  String get adminSuspend => 'Suspendre';

  @override
  String get adminUnsuspend => 'Lever la suspension';

  @override
  String get adminValidate => 'Valider';

  @override
  String get themeToLight => 'Passer en mode clair';

  @override
  String get themeToDark => 'Passer en mode sombre';

  @override
  String get exitTitle => 'Quitter l\'application ?';

  @override
  String get exitBody => 'Voulez-vous vraiment quitter l\'application ?';

  @override
  String get exitConfirm => 'Quitter';

  @override
  String get openRequestsTab => 'Clients';

  @override
  String get openRequestsTitle => 'Clients qui cherchent un livreur';

  @override
  String get noOpenRequests =>
      'Aucun client ne cherche de livreur pour le moment.';

  @override
  String get openRequestsLocked =>
      'Un abonnement valide est nécessaire pour voir les clients qui cherchent un livreur.';

  @override
  String get notifNewOpenRequest => 'Un client cherche un livreur.';

  @override
  String get publishOpenRequest => 'Publier une demande ouverte';

  @override
  String get publishOpenRequestHint =>
      'Les livreurs abonnés la verront et pourront vous contacter.';

  @override
  String get newOpenRequest => 'Demande ouverte';

  @override
  String get openRequestIntro =>
      'Décrivez votre livraison : les livreurs abonnés pourront vous appeler ou vous écrire.';

  @override
  String get publishAction => 'Publier';

  @override
  String get openRequestPublished =>
      'Demande publiée. Les livreurs peuvent maintenant vous contacter.';

  @override
  String get myOpenRequests => 'Mes demandes ouvertes';

  @override
  String get sentRequests => 'Demandes envoyées à un livreur';

  @override
  String get closeOpenRequest => 'Clôturer';

  @override
  String get closeOpenRequestTitle => 'Clôturer la demande ?';

  @override
  String get closeOpenRequestBody => 'Les livreurs ne la verront plus.';

  @override
  String get openRequestOpenLabel => 'Ouverte';

  @override
  String get openRequestClosedLabel => 'Clôturée';

  @override
  String get adminAdmins => 'Admins';

  @override
  String get adminAddTitle => 'Ajouter un administrateur';

  @override
  String get adminAddHint =>
      'La personne doit déjà être inscrite dans l\'application.';

  @override
  String get adminEmailLabel => 'Email du compte Google';

  @override
  String get adminEmailInvalid => 'Email invalide.';

  @override
  String get adminAddButton => 'Ajouter';

  @override
  String get adminAdded => 'Administrateur ajouté.';

  @override
  String get adminUserNotFound =>
      'Aucun compte avec cet email. La personne doit d\'abord s\'inscrire.';

  @override
  String get adminAlready => 'Cette personne est déjà administrateur.';

  @override
  String get adminCurrent => 'Administrateurs actuels';

  @override
  String get adminRemoveTitle => 'Retirer cet administrateur ?';

  @override
  String get adminRemoveBody =>
      'Il perdra l\'accès au panneau d\'administration.';

  @override
  String get adminYou => 'Vous';

  @override
  String get welcomeGreeting => 'Bonjour !';

  @override
  String get welcomeTagline =>
      'Trouvez rapidement un livreur près de chez vous.';

  @override
  String get roleClientShort => 'Je suis client';

  @override
  String get roleClientShortDesc => 'J\'ai besoin d\'un livreur';

  @override
  String get roleDriverShort => 'Je suis livreur';

  @override
  String get roleDriverShortDesc => 'Je livre des colis';

  @override
  String get welcomeGoogleHint =>
      'Touchez votre profil pour continuer avec Google';

  @override
  String get phoneTaken =>
      'Ce numéro est déjà utilisé par un autre compte. Utilisez un autre numéro.';
}
