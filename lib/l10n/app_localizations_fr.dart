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
  String get statusActive => 'En ligne';

  @override
  String get statusInactive => 'Hors ligne';

  @override
  String get activeHint =>
      'Les clients proches vous voient et peuvent vous envoyer des demandes.';

  @override
  String get inactiveHint =>
      'Vous êtes masqué. Passez en ligne pour recevoir des demandes.';

  @override
  String get activate => 'Me mettre en ligne';

  @override
  String get deactivate => 'Passer hors ligne';

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
      'Votre formule ne vous permet pas de passer en ligne. Ouvrez Ma formule.';

  @override
  String get subscription => 'Abonnement';

  @override
  String get subTrial => 'Essai gratuit';

  @override
  String get subPaid => 'Mensuelle';

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
      'Choisissez une formule pour réapparaître auprès des clients.';

  @override
  String get manageSubscription => 'Gérer ma formule';

  @override
  String get renewSubscription => 'Renouveler mon abonnement';

  @override
  String priceLine(String price) {
    return '$price DA par mois';
  }

  @override
  String get paymentSteps =>
      '1. Payez avec les coordonnées ci-dessous.\n2. Saisissez la référence du paiement.\n3. L\'équipe Wassaly vérifie et valide.';

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
  String get claimsHistory => 'Mes paiements';

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
  String get openRequestsTitle => 'Courses disponibles';

  @override
  String get noOpenRequests =>
      'Aucun client ne cherche de livreur pour le moment.';

  @override
  String get openRequestsLocked =>
      'Choisissez une formule pour voir les clients qui cherchent un livreur.';

  @override
  String get notifNewOpenRequest => 'Un client cherche un livreur.';

  @override
  String get publishOpenRequest => 'Publier une course';

  @override
  String get publishOpenRequestHint =>
      'Les livreurs proches vous font leurs offres. Vous choisissez, vous pouvez négocier.';

  @override
  String get newOpenRequest => 'Demande ouverte';

  @override
  String get openRequestIntro =>
      'Décrivez votre course. Les livreurs proches voient le quartier et vous font une offre ; vous choisissez.';

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

  @override
  String get idTitle => 'Pièce d\'identité';

  @override
  String get idIntro =>
      'Pour vérifier votre compte, ajoutez une photo lisible de votre pièce d\'identité (carte nationale, permis de conduire ou passeport). Votre compte restera bloqué jusqu\'à sa validation par l\'administrateur.';

  @override
  String get idFromGallery => 'Galerie';

  @override
  String get idFromCamera => 'Appareil photo';

  @override
  String get idChangePhoto => 'Changer la photo';

  @override
  String get idRequired => 'Ajoutez la photo de votre pièce d\'identité.';

  @override
  String get idUploadError =>
      'Envoi de la photo impossible. Vérifiez votre connexion et réessayez.';

  @override
  String get idPickError =>
      'Impossible d\'ouvrir la photo. Vérifiez les autorisations de l\'application.';

  @override
  String get idImageUnavailable => 'Image indisponible.';

  @override
  String get verifTitle => 'Vérification du compte';

  @override
  String get verifPendingTitle => 'Compte en cours de vérification';

  @override
  String get verifPendingBody =>
      'L\'administrateur vérifie votre pièce d\'identité. Vous aurez accès à l\'application dès qu\'elle sera validée.';

  @override
  String get verifRejectedTitle => 'Pièce d\'identité refusée';

  @override
  String get verifRejectedBody =>
      'Votre pièce n\'a pas été acceptée. Envoyez une nouvelle photo lisible pour relancer la vérification.';

  @override
  String verifReason(String reason) {
    return 'Motif : $reason';
  }

  @override
  String get verifResend => 'Envoyer une nouvelle photo';

  @override
  String get verifResent =>
      'Nouvelle photo envoyée. L\'administrateur va la vérifier.';

  @override
  String get verifChipVerified => 'Vérifié';

  @override
  String get verifChipPending => 'À vérifier';

  @override
  String get verifChipRejected => 'Refusé';

  @override
  String get adminVerifications => 'Vérifications';

  @override
  String get adminNoVerifications => 'Aucune vérification en attente.';

  @override
  String get adminViewId => 'Voir la pièce d\'identité';

  @override
  String get adminIdMissing => 'Aucune pièce d\'identité trouvée.';

  @override
  String get adminRejectIdTitle => 'Refuser la pièce d\'identité';

  @override
  String get adminRejectIdHint => 'Motif (affiché au livreur)';

  @override
  String get adminIdApproved => 'Livreur vérifié.';

  @override
  String get adminIdRejected => 'Pièce refusée.';

  @override
  String get revenueTitle => 'Chiffre d\'affaires';

  @override
  String get revenueToday => 'Aujourd\'hui';

  @override
  String get revenueWeek => '7 derniers jours';

  @override
  String get revenueMonth => 'Ce mois';

  @override
  String get revenueTotal => 'Total';

  @override
  String revenueDeliveries(String count) {
    return '$count livraison(s) terminée(s)';
  }

  @override
  String revenueNoAmount(String count) {
    return '$count ancienne(s) livraison(s) sans montant (non comptées)';
  }

  @override
  String amountDa(String amount) {
    return '$amount DA';
  }

  @override
  String get completeDialogTitle => 'Montant de la livraison';

  @override
  String get completeDialogHint =>
      'Saisissez le prix de la course encaissé auprès du client.';

  @override
  String get amountLabel => 'Montant (DA)';

  @override
  String get amountInvalid => 'Montant invalide';

  @override
  String get completeConfirm => 'Terminer';

  @override
  String requestAmount(String amount) {
    return 'Montant : $amount';
  }

  @override
  String get adminRevenue => 'Chiffre d\'affaires';

  @override
  String get adminRevenueAll => 'Tous les livreurs';

  @override
  String get adminNoRevenue => 'Aucune livraison terminée.';

  @override
  String get welcomeHeadline =>
      'Vos colis livrés par des livreurs de votre quartier.';

  @override
  String get welcomeForWho =>
      'Clients et livreurs utilisent la même application.';

  @override
  String get onboardingIntro =>
      'Encore une étape : votre numéro et votre rôle.';

  @override
  String get phonePrivacyHint =>
      'Il n\'est partagé qu\'avec le client ou le livreur d\'une livraison acceptée.';

  @override
  String get roleDriverTrial => '2 mois gratuits';

  @override
  String get accountMenu => 'Mon compte';

  @override
  String get tabHome => 'Accueil';

  @override
  String get publishHeroTitle => 'Besoin d\'un livreur ?';

  @override
  String get sendRequestShort => 'Demander';

  @override
  String get phoneAfterAccept =>
      'Son numéro s\'affichera après l\'accord sur le prix.';

  @override
  String get contactAfterAccept =>
      'Le numéro du livreur s\'affichera après l\'accord sur le prix.';

  @override
  String get noRequestsTitle => 'Aucune demande';

  @override
  String get currentRequests => 'En cours';

  @override
  String get pastRequests => 'Historique';

  @override
  String get toHandleRequests => 'À traiter';

  @override
  String get addressHint => 'Rue, quartier ou repère';

  @override
  String get noteHint => 'Ex. : colis fragile, 2e étage';

  @override
  String get phoneNotAllowed =>
      'Pas de numéro de téléphone ici : il est partagé une fois la livraison acceptée.';

  @override
  String get phoneNotAllowedChat =>
      'Message non envoyé : les numéros s\'échangent une fois la livraison acceptée.';

  @override
  String get chatSafetyNotice =>
      'Les numéros de téléphone s\'échangent une fois la livraison acceptée.';

  @override
  String get noConversationsTitle => 'Aucune conversation';

  @override
  String notifOpenRequestTaken(String name) {
    return 'Accord conclu avec $name';
  }

  @override
  String openRequestTakenBy(String name) {
    return 'Attribuée à $name';
  }

  @override
  String get reportDriver => 'Signaler ce livreur';

  @override
  String reportTitle(String name) {
    return 'Signaler $name';
  }

  @override
  String get reportIntro =>
      'L\'équipe Wassaly examine chaque signalement. Le livreur ne voit pas qui l\'a signalé.';

  @override
  String get reportReasonOffApp =>
      'Il m\'a proposé de passer hors de l\'application';

  @override
  String get reportReasonNotDelivered => 'Livraison non effectuée';

  @override
  String get reportReasonBehavior => 'Comportement inapproprié';

  @override
  String get reportReasonOther => 'Autre';

  @override
  String get reportNoteLabel => 'Ce qui s\'est passé (facultatif)';

  @override
  String get reportSend => 'Envoyer le signalement';

  @override
  String get reportSent => 'Signalement envoyé';

  @override
  String get reportNotAllowed =>
      'Signalement impossible : vous avez déjà signalé ce livreur, ou vous n\'avez pas encore échangé avec lui.';

  @override
  String acceptWithPrice(String price) {
    return 'Accepter ($price DA)';
  }

  @override
  String get acceptChargeTitle => 'Accepter cette livraison ?';

  @override
  String acceptChargeBody(String price, String newDebt, String limit) {
    return '$price DA seront ajoutés à votre solde, qui passera à $newDebt DA. À $limit DA, vous devrez payer avant d\'accepter de nouvelles livraisons.';
  }

  @override
  String get takeAction => 'Je prends cette demande';

  @override
  String takeWithPrice(String price) {
    return 'Je prends ($price DA)';
  }

  @override
  String get takeTitle => 'Prendre cette demande ?';

  @override
  String get takeBody =>
      'Le client sera prévenu et vous aurez accès à son numéro.';

  @override
  String takeChargeBody(String price, String newDebt, String limit) {
    return '$price DA seront ajoutés à votre solde, qui passera à $newDebt DA (blocage à $limit DA). Vous aurez ensuite accès au numéro du client.';
  }

  @override
  String get takeConfirm => 'Je la prends';

  @override
  String takeDone(String name) {
    return 'Demande prise. Contactez $name depuis l\'onglet Demandes.';
  }

  @override
  String get takeHint =>
      'Le contact du client s\'affiche une fois la demande prise.';

  @override
  String get openRequestsIntro =>
      'Faites une offre au client. Il compare les offres, peut négocier et choisit son livreur.';

  @override
  String openRequestsIntroPaid(String price) {
    return 'Faites une offre au client. S\'il l\'accepte, $price DA sont ajoutés à votre solde.';
  }

  @override
  String get openRequestsLockedDebt =>
      'Votre solde a atteint 1 000 DA. Réglez-le pour voir et prendre les demandes.';

  @override
  String get noOpenRequestsTitle => 'Aucune demande pour l\'instant';

  @override
  String get pendingRequestsLabel => 'Demandes en attente';

  @override
  String get unreadMessagesLabel => 'Messages non lus';

  @override
  String get myPosition => 'Ma position';

  @override
  String get positionNeverShared => 'Jamais partagée';

  @override
  String get suspendedMsg =>
      'Votre compte est suspendu. Contactez l\'équipe Wassaly.';

  @override
  String trialEndingTitle(String days) {
    return 'Votre essai se termine dans $days jour(s)';
  }

  @override
  String get trialEndingMsg =>
      'Choisissez votre formule pour continuer à recevoir des demandes : 1 000 DA par mois ou 50 DA par livraison.';

  @override
  String get myPlan => 'Ma formule';

  @override
  String get noActivePlan => 'Aucune formule active';

  @override
  String get subPerDelivery => 'À la livraison';

  @override
  String get subBlocked => 'Bloqué';

  @override
  String get choosePlan => 'Choisir une formule';

  @override
  String get choosePlanConfirm => 'Choisir cette formule';

  @override
  String get planForLater => 'Formule pour la suite';

  @override
  String get planSaved => 'Formule enregistrée';

  @override
  String get planMonthlyTitle => 'Mensuelle';

  @override
  String planMonthlyPrice(String price) {
    return '$price DA par mois';
  }

  @override
  String get planMonthlyDesc =>
      'Livraisons illimitées pendant 30 jours. Vous payez d\'avance.';

  @override
  String get planPerDeliveryTitle => 'À la livraison';

  @override
  String planPerDeliveryPrice(String price) {
    return '$price DA par livraison';
  }

  @override
  String planPerDeliveryDesc(String limit) {
    return 'Rien à avancer. Chaque livraison acceptée s\'ajoute à votre solde, à régler avant d\'atteindre $limit DA.';
  }

  @override
  String planEffectOn(String date) {
    return 'Prendra effet le $date, à la fin de votre période en cours.';
  }

  @override
  String planEffectAfterPayment(String amount) {
    return 'Prendra effet dès que votre paiement de $amount DA sera validé.';
  }

  @override
  String get planEffectNow =>
      'Prend effet tout de suite : 50 DA par livraison acceptée.';

  @override
  String trialUntil(String days, String date) {
    return 'Encore $days jour(s) gratuit(s), jusqu\'au $date.';
  }

  @override
  String get debtLabel => 'Votre solde à régler';

  @override
  String debtLimitSuffix(String limit) {
    return 'sur $limit DA';
  }

  @override
  String debtOfLimit(String debt, String limit) {
    return 'Solde : $debt DA sur $limit DA';
  }

  @override
  String deliveriesLeft(String count) {
    return 'Encore $count livraison(s) avant le blocage.';
  }

  @override
  String get debtBlockedTitle => 'Solde à régler';

  @override
  String debtBlockedMsg(String debt) {
    return 'Vous devez $debt DA. Réglez ce montant pour accepter de nouvelles livraisons.';
  }

  @override
  String debtWarnTitle(String debt) {
    return 'Votre solde atteint $debt DA';
  }

  @override
  String debtWarnMsg(String count) {
    return 'Encore $count livraison(s) avant le blocage. Pensez à régler votre solde.';
  }

  @override
  String get payTitle => 'Payer';

  @override
  String get payDebt => 'Régler mon solde';

  @override
  String get payMonth => 'Payer le mois';

  @override
  String get amountToPay => 'Montant à payer';

  @override
  String monthPlusDebt(String month, String debt) {
    return '$month DA pour le mois et $debt DA de solde';
  }

  @override
  String iHavePaidAmount(String amount) {
    return 'J\'ai payé $amount DA';
  }

  @override
  String claimTitle(String kind, String amount) {
    return '$kind : $amount';
  }

  @override
  String get ledgerTitle => 'Mouvements du solde';

  @override
  String get ledgerCharge => 'Livraison acceptée';

  @override
  String get ledgerRefund => 'Remboursement (annulation)';

  @override
  String get ledgerPayment => 'Paiement validé';

  @override
  String get billingErrorDebtLimit =>
      'Votre solde a atteint 1 000 DA. Réglez-le dans Ma formule pour accepter de nouvelles livraisons.';

  @override
  String get billingErrorNotEligible =>
      'Votre formule ne vous permet pas d\'accepter de livraison. Ouvrez Ma formule.';

  @override
  String get billingErrorNotPending => 'Cette demande n\'est plus en attente.';

  @override
  String get billingErrorAlreadyTaken =>
      'Un autre livreur a pris cette demande avant vous.';

  @override
  String get adminSuspects => 'Suspects';

  @override
  String get adminNoSuspectsTitle => 'Rien à signaler';

  @override
  String get adminNoSuspects =>
      'Aucun livreur ne présente de comportement inhabituel.';

  @override
  String get adminPaymentApproved => 'Paiement validé';

  @override
  String suspectCancellations(String cancelled, String accepted) {
    return '$cancelled livraisons annulées après acceptation, sur $accepted';
  }

  @override
  String suspectChats(String chats, String accepted) {
    return '$chats conversations pour $accepted livraisons acceptées';
  }

  @override
  String suspectReports(String count) {
    return 'Signalé par $count clients';
  }

  @override
  String suspectDebt(String debt) {
    return 'Bloqué depuis plus de 7 jours avec $debt DA de solde';
  }

  @override
  String get statAccepted => 'Acceptées';

  @override
  String get statCompleted => 'Terminées';

  @override
  String get statCancelled => 'Annulées';

  @override
  String get statChats => 'Discussions';

  @override
  String get statReports => 'Signalements';

  @override
  String get reportsTitle => 'Signalements';

  @override
  String noDriversInRadius(String km) {
    return 'Aucun livreur en ligne à moins de $km km. Publiez une course : elle sera visible dès qu\'un livreur se connecte.';
  }

  @override
  String get acceptPriceTitle => 'Accepter la livraison';

  @override
  String get pricePickHint =>
      'Choisissez le prix de la course. Le client le voit tout de suite.';

  @override
  String priceSheetFee(String fee, String debtAfter, String limit) {
    return '$fee DA seront ajoutés à votre solde, qui passera à $debtAfter DA (blocage à $limit DA).';
  }

  @override
  String confirmWithPrice(String label, String price) {
    return '$label : $price DA';
  }

  @override
  String get agreedPrice => 'Prix convenu';

  @override
  String get completeConfirmTitle => 'Terminer la livraison ?';

  @override
  String completeConfirmBody(String price) {
    return 'Le montant enregistré sera le prix convenu : $price DA.';
  }

  @override
  String get rateDelivery => 'Noter la livraison';

  @override
  String rateTitle(String name) {
    return 'Comment s\'est passée la livraison avec $name ?';
  }

  @override
  String get rateCommentLabel => 'Un commentaire ? (facultatif)';

  @override
  String get rateSend => 'Envoyer la note';

  @override
  String get ratingSent => 'Merci, votre note a été enregistrée';

  @override
  String get ratingAlreadySent => 'Cette livraison a déjà été notée.';

  @override
  String get yourRating => 'Votre note';

  @override
  String get paymentReferenceUsed =>
      'Cette référence de paiement a déjà été déclarée. Vérifiez-la ou contactez l\'équipe Wassaly.';

  @override
  String suspectLowRating(String average, String count) {
    return 'Note moyenne de $average sur $count avis';
  }

  @override
  String get areaLabel => 'Quartier';

  @override
  String get areaHint => 'Ex. : Hai Sabah, Centre-ville';

  @override
  String get areaRequired => 'Indiquez le quartier';

  @override
  String get exactAddressLabel => 'Adresse exacte';

  @override
  String get exactAddressPrivacy =>
      'Les livreurs voient seulement le quartier. L\'adresse exacte et votre position sont partagées après l\'accord sur le prix.';

  @override
  String get exactAddressAfterAgreement =>
      'Adresse exacte visible après l\'accord sur le prix';

  @override
  String courseDistance(String distance) {
    return 'Distance de la course : $distance';
  }

  @override
  String get statusNegotiating => 'En négociation';

  @override
  String get proposePriceTitle => 'Proposer un prix';

  @override
  String get proposePriceHint => 'Proposez votre prix au client.';

  @override
  String get proposeAction => 'Proposer';

  @override
  String get counterAction => 'Contre-proposer';

  @override
  String counterTitle(String name) {
    return 'Votre prix pour $name';
  }

  @override
  String counterHint(String price) {
    return 'Proposition actuelle : $price DA. Ajustez de 10 DA en 10 DA.';
  }

  @override
  String get yourProposal => 'Votre proposition';

  @override
  String waitingAnswer(String name) {
    return 'En attente de la réponse de $name';
  }

  @override
  String otherProposes(String name) {
    return '$name propose';
  }

  @override
  String waitingDriverPrice(String name) {
    return 'En attente du prix de $name';
  }

  @override
  String acceptAmount(String price) {
    return 'Accepter $price DA';
  }

  @override
  String agreeTitle(String price) {
    return 'Conclure à $price DA ?';
  }

  @override
  String agreeBody(String name) {
    return 'Le numéro et l\'adresse exacte seront partagés avec $name.';
  }

  @override
  String agreeFee(String fee, String debtAfter, String limit) {
    return '$fee DA seront ajoutés à votre solde, qui passera à $debtAfter DA (blocage à $limit DA).';
  }

  @override
  String get agreeAction => 'Conclure l\'accord';

  @override
  String agreementDone(String name) {
    return 'Accord conclu avec $name';
  }

  @override
  String get refuseTitle => 'Refuser cette demande ?';

  @override
  String get refuseBody =>
      'Le client sera prévenu et pourra choisir un autre livreur.';

  @override
  String get waitingClientRequests => 'En attente du client';

  @override
  String notifPriceProposed(String name, String price) {
    return '$name propose $price DA';
  }

  @override
  String get makeOfferTitle => 'Faire une offre';

  @override
  String get makeOfferHint =>
      'Le client compare les offres et peut négocier. Ses coordonnées et l\'adresse exacte s\'affichent après l\'accord.';

  @override
  String get withdrawOffer => 'Retirer mon offre';

  @override
  String get offerRefusedByClient => 'Le client a refusé votre offre.';

  @override
  String get offerWithdrawn => 'Vous avez retiré votre offre.';

  @override
  String get waitingOffers => 'En attente des offres des livreurs…';

  @override
  String offersCount(String count) {
    return 'Offres reçues : $count';
  }

  @override
  String get billingErrorNotYourTurn =>
      'C\'est à l\'autre partie de répondre à cette proposition.';

  @override
  String get billingErrorDriverUnavailable =>
      'Ce livreur ne peut plus accepter de course pour le moment. Choisissez un autre livreur.';
}
