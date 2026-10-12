import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Wassaly'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get welcome;

  /// No description provided for @chooseLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get chooseLanguage;

  /// No description provided for @continueWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continueWithGoogle;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @signInError.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible. Vérifiez votre connexion internet et réessayez.'**
  String get signInError;

  /// No description provided for @completeProfile.
  ///
  /// In fr, this message translates to:
  /// **'Complétez votre profil'**
  String get completeProfile;

  /// No description provided for @phoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In fr, this message translates to:
  /// **'0550 12 34 56'**
  String get phoneHint;

  /// No description provided for @phoneInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide (exemple : 0550 12 34 56)'**
  String get phoneInvalid;

  /// No description provided for @roleQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Quel est votre rôle ?'**
  String get roleQuestion;

  /// No description provided for @roleClient.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get roleClient;

  /// No description provided for @roleClientDesc.
  ///
  /// In fr, this message translates to:
  /// **'Je cherche un livreur'**
  String get roleClientDesc;

  /// No description provided for @roleDriver.
  ///
  /// In fr, this message translates to:
  /// **'Livreur'**
  String get roleDriver;

  /// No description provided for @roleDriverDesc.
  ///
  /// In fr, this message translates to:
  /// **'Je propose mes services de livraison'**
  String get roleDriverDesc;

  /// No description provided for @continueButton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueButton;

  /// No description provided for @saveError.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement impossible. Réessayez.'**
  String get saveError;

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOut;

  /// No description provided for @profileLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger votre profil. Réessayez plus tard.'**
  String get profileLoadError;

  /// No description provided for @hello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}'**
  String hello(String name);

  /// No description provided for @genericError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get genericError;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @remove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get remove;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @cannotOpenLink.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir l\'application correspondante.'**
  String get cannotOpenLink;

  /// No description provided for @tabDrivers.
  ///
  /// In fr, this message translates to:
  /// **'Livreurs'**
  String get tabDrivers;

  /// No description provided for @tabRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes'**
  String get tabRequests;

  /// No description provided for @messages.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @myRequests.
  ///
  /// In fr, this message translates to:
  /// **'Mes demandes'**
  String get myRequests;

  /// No description provided for @driversNearby.
  ///
  /// In fr, this message translates to:
  /// **'Livreurs à proximité'**
  String get driversNearby;

  /// No description provided for @driversAvailableNearby.
  ///
  /// In fr, this message translates to:
  /// **'Les livreurs disponibles les plus proches de vous'**
  String get driversAvailableNearby;

  /// No description provided for @noDriversAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livreur disponible pour le moment. Tirez vers le bas pour actualiser.'**
  String get noDriversAvailable;

  /// No description provided for @available.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible'**
  String get unavailable;

  /// No description provided for @call.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get call;

  /// No description provided for @whatsapp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @message.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @openInMaps.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire'**
  String get openInMaps;

  /// No description provided for @locationServiceOff.
  ///
  /// In fr, this message translates to:
  /// **'Le GPS est désactivé. Activez la localisation pour voir les livreurs proches.'**
  String get locationServiceOff;

  /// No description provided for @locationDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission de localisation refusée. Autorisez-la pour trier les livreurs par distance.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In fr, this message translates to:
  /// **'La localisation est bloquée. Autorisez-la dans les paramètres de l\'application.'**
  String get locationDeniedForever;

  /// No description provided for @locationUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Position introuvable. Vérifiez le GPS et réessayez.'**
  String get locationUnknown;

  /// No description provided for @openSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les paramètres'**
  String get openSettings;

  /// No description provided for @gpsPosition.
  ///
  /// In fr, this message translates to:
  /// **'Position GPS'**
  String get gpsPosition;

  /// No description provided for @gpsShared.
  ///
  /// In fr, this message translates to:
  /// **'Position GPS partagée'**
  String get gpsShared;

  /// No description provided for @driverProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil du livreur'**
  String get driverProfile;

  /// No description provided for @driverNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Livreur introuvable.'**
  String get driverNotFound;

  /// No description provided for @city.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get city;

  /// No description provided for @distance.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @positionUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Position mise à jour'**
  String get positionUpdated;

  /// No description provided for @sendRequest.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer une demande de livraison'**
  String get sendRequest;

  /// No description provided for @driverNotAvailableHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce livreur n\'est pas disponible pour le moment.'**
  String get driverNotAvailableHint;

  /// No description provided for @newRequest.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle demande'**
  String get newRequest;

  /// No description provided for @requestTo.
  ///
  /// In fr, this message translates to:
  /// **'Demande adressée à ce livreur'**
  String get requestTo;

  /// No description provided for @pickup.
  ///
  /// In fr, this message translates to:
  /// **'Récupération'**
  String get pickup;

  /// No description provided for @delivery.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get delivery;

  /// No description provided for @addressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get addressLabel;

  /// No description provided for @placeRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez une adresse ou partagez votre position.'**
  String get placeRequired;

  /// No description provided for @shareMyPosition.
  ///
  /// In fr, this message translates to:
  /// **'Partager ma position actuelle'**
  String get shareMyPosition;

  /// No description provided for @noteOptional.
  ///
  /// In fr, this message translates to:
  /// **'Note (facultatif)'**
  String get noteOptional;

  /// No description provided for @sendToDriver.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer au livreur'**
  String get sendToDriver;

  /// No description provided for @requestSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée au livreur.'**
  String get requestSent;

  /// No description provided for @statusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Acceptée'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusée'**
  String get statusRejected;

  /// No description provided for @statusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get statusCancelled;

  /// No description provided for @accept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get reject;

  /// No description provided for @markCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme terminée'**
  String get markCompleted;

  /// No description provided for @cancelRequest.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la demande'**
  String get cancelRequest;

  /// No description provided for @confirmCancelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la demande ?'**
  String get confirmCancelTitle;

  /// No description provided for @confirmCancelBody.
  ///
  /// In fr, this message translates to:
  /// **'Le livreur sera informé de l\'annulation.'**
  String get confirmCancelBody;

  /// No description provided for @noRequestsClient.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande pour le moment.'**
  String get noRequestsClient;

  /// No description provided for @noRequestsDriver.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande reçue pour le moment.'**
  String get noRequestsDriver;

  /// No description provided for @notifNewRequest.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle demande de {name}'**
  String notifNewRequest(String name);

  /// No description provided for @notifRequestCancelled.
  ///
  /// In fr, this message translates to:
  /// **'{name} a annulé sa demande'**
  String notifRequestCancelled(String name);

  /// No description provided for @notifRequestAccepted.
  ///
  /// In fr, this message translates to:
  /// **'{name} a accepté votre demande'**
  String notifRequestAccepted(String name);

  /// No description provided for @notifRequestRejected.
  ///
  /// In fr, this message translates to:
  /// **'{name} a refusé votre demande'**
  String notifRequestRejected(String name);

  /// No description provided for @notifRequestCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Votre livraison est terminée'**
  String get notifRequestCompleted;

  /// No description provided for @noConversations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversation pour le moment.'**
  String get noConversations;

  /// No description provided for @startConversation.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez le premier message.'**
  String get startConversation;

  /// No description provided for @typeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Écrire un message'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get send;

  /// No description provided for @sendError.
  ///
  /// In fr, this message translates to:
  /// **'Message non envoyé. Réessayez.'**
  String get sendError;

  /// No description provided for @yourAvailability.
  ///
  /// In fr, this message translates to:
  /// **'Votre disponibilité'**
  String get yourAvailability;

  /// No description provided for @statusActive.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get statusInactive;

  /// No description provided for @activeHint.
  ///
  /// In fr, this message translates to:
  /// **'Les clients proches vous voient et peuvent vous envoyer des demandes.'**
  String get activeHint;

  /// No description provided for @inactiveHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes masqué. Passez en ligne pour recevoir des demandes.'**
  String get inactiveHint;

  /// No description provided for @activate.
  ///
  /// In fr, this message translates to:
  /// **'Me mettre en ligne'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In fr, this message translates to:
  /// **'Passer hors ligne'**
  String get deactivate;

  /// No description provided for @updateMyPosition.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour ma position'**
  String get updateMyPosition;

  /// No description provided for @positionUpdatedOk.
  ///
  /// In fr, this message translates to:
  /// **'Position mise à jour.'**
  String get positionUpdatedOk;

  /// No description provided for @cityNotSet.
  ///
  /// In fr, this message translates to:
  /// **'Ville non renseignée'**
  String get cityNotSet;

  /// No description provided for @editCity.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la ville'**
  String get editCity;

  /// No description provided for @subscriptionBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Votre formule ne vous permet pas de passer en ligne. Ouvrez Ma formule.'**
  String get subscriptionBlocked;

  /// No description provided for @subscription.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement'**
  String get subscription;

  /// No description provided for @subTrial.
  ///
  /// In fr, this message translates to:
  /// **'Essai gratuit'**
  String get subTrial;

  /// No description provided for @subPaid.
  ///
  /// In fr, this message translates to:
  /// **'Mensuelle'**
  String get subPaid;

  /// No description provided for @subExpired.
  ///
  /// In fr, this message translates to:
  /// **'Expiré'**
  String get subExpired;

  /// No description provided for @subSuspended.
  ///
  /// In fr, this message translates to:
  /// **'Suspendu'**
  String get subSuspended;

  /// No description provided for @expiresOn.
  ///
  /// In fr, this message translates to:
  /// **'Expire le {date}'**
  String expiresOn(String date);

  /// No description provided for @daysLeft.
  ///
  /// In fr, this message translates to:
  /// **'{count} jour(s) restant(s)'**
  String daysLeft(String count);

  /// No description provided for @subscriptionExpiredMsg.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une formule pour réapparaître auprès des clients.'**
  String get subscriptionExpiredMsg;

  /// No description provided for @manageSubscription.
  ///
  /// In fr, this message translates to:
  /// **'Gérer ma formule'**
  String get manageSubscription;

  /// No description provided for @renewSubscription.
  ///
  /// In fr, this message translates to:
  /// **'Renouveler mon abonnement'**
  String get renewSubscription;

  /// No description provided for @priceLine.
  ///
  /// In fr, this message translates to:
  /// **'{price} DA par mois'**
  String priceLine(String price);

  /// No description provided for @paymentSteps.
  ///
  /// In fr, this message translates to:
  /// **'1. Payez avec les coordonnées ci-dessous.\n2. Saisissez la référence du paiement.\n3. L\'équipe Wassaly vérifie et valide.'**
  String get paymentSteps;

  /// No description provided for @paymentReference.
  ///
  /// In fr, this message translates to:
  /// **'Référence du paiement'**
  String get paymentReference;

  /// No description provided for @paymentReferenceRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez la référence du paiement.'**
  String get paymentReferenceRequired;

  /// No description provided for @iHavePaid.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai payé, envoyer'**
  String get iHavePaid;

  /// No description provided for @claimSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée. L\'administrateur va la valider.'**
  String get claimSent;

  /// No description provided for @claimAlreadyPending.
  ///
  /// In fr, this message translates to:
  /// **'Une demande est déjà en cours de validation.'**
  String get claimAlreadyPending;

  /// No description provided for @claimsHistory.
  ///
  /// In fr, this message translates to:
  /// **'Mes paiements'**
  String get claimsHistory;

  /// No description provided for @noClaims.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande de renouvellement.'**
  String get noClaims;

  /// No description provided for @claimPending.
  ///
  /// In fr, this message translates to:
  /// **'En validation'**
  String get claimPending;

  /// No description provided for @claimApproved.
  ///
  /// In fr, this message translates to:
  /// **'Validée'**
  String get claimApproved;

  /// No description provided for @claimRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusée'**
  String get claimRejected;

  /// No description provided for @adminPanel.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get adminPanel;

  /// No description provided for @accessDenied.
  ///
  /// In fr, this message translates to:
  /// **'Accès réservé à l\'administrateur.'**
  String get accessDenied;

  /// No description provided for @adminDrivers.
  ///
  /// In fr, this message translates to:
  /// **'Livreurs'**
  String get adminDrivers;

  /// No description provided for @adminPayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get adminPayments;

  /// No description provided for @adminClients.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get adminClients;

  /// No description provided for @adminRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes'**
  String get adminRequests;

  /// No description provided for @adminNoDrivers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livreur inscrit.'**
  String get adminNoDrivers;

  /// No description provided for @adminNoClients.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client inscrit.'**
  String get adminNoClients;

  /// No description provided for @adminNoClaims.
  ///
  /// In fr, this message translates to:
  /// **'Aucun paiement en attente.'**
  String get adminNoClaims;

  /// No description provided for @adminExtend.
  ///
  /// In fr, this message translates to:
  /// **'Prolonger de 30 jours'**
  String get adminExtend;

  /// No description provided for @adminExtended.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement prolongé de 30 jours.'**
  String get adminExtended;

  /// No description provided for @adminSuspend.
  ///
  /// In fr, this message translates to:
  /// **'Suspendre'**
  String get adminSuspend;

  /// No description provided for @adminUnsuspend.
  ///
  /// In fr, this message translates to:
  /// **'Lever la suspension'**
  String get adminUnsuspend;

  /// No description provided for @adminValidate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get adminValidate;

  /// No description provided for @themeToLight.
  ///
  /// In fr, this message translates to:
  /// **'Passer en mode clair'**
  String get themeToLight;

  /// No description provided for @themeToDark.
  ///
  /// In fr, this message translates to:
  /// **'Passer en mode sombre'**
  String get themeToDark;

  /// No description provided for @exitTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter l\'application ?'**
  String get exitTitle;

  /// No description provided for @exitBody.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment quitter l\'application ?'**
  String get exitBody;

  /// No description provided for @exitConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get exitConfirm;

  /// No description provided for @openRequestsTab.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get openRequestsTab;

  /// No description provided for @openRequestsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Courses disponibles'**
  String get openRequestsTitle;

  /// No description provided for @noOpenRequests.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client ne cherche de livreur pour le moment.'**
  String get noOpenRequests;

  /// No description provided for @openRequestsLocked.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une formule pour voir les clients qui cherchent un livreur.'**
  String get openRequestsLocked;

  /// No description provided for @notifNewOpenRequest.
  ///
  /// In fr, this message translates to:
  /// **'Un client cherche un livreur.'**
  String get notifNewOpenRequest;

  /// No description provided for @publishOpenRequest.
  ///
  /// In fr, this message translates to:
  /// **'Publier une course'**
  String get publishOpenRequest;

  /// No description provided for @publishOpenRequestHint.
  ///
  /// In fr, this message translates to:
  /// **'Tous les livreurs proches la voient. Le premier qui la prend vous contacte.'**
  String get publishOpenRequestHint;

  /// No description provided for @newOpenRequest.
  ///
  /// In fr, this message translates to:
  /// **'Demande ouverte'**
  String get newOpenRequest;

  /// No description provided for @openRequestIntro.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre course. Le premier livreur qui la prend obtient votre numéro et vous contacte.'**
  String get openRequestIntro;

  /// No description provided for @publishAction.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get publishAction;

  /// No description provided for @openRequestPublished.
  ///
  /// In fr, this message translates to:
  /// **'Demande publiée. Les livreurs peuvent maintenant vous contacter.'**
  String get openRequestPublished;

  /// No description provided for @myOpenRequests.
  ///
  /// In fr, this message translates to:
  /// **'Mes demandes ouvertes'**
  String get myOpenRequests;

  /// No description provided for @sentRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes envoyées à un livreur'**
  String get sentRequests;

  /// No description provided for @closeOpenRequest.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer'**
  String get closeOpenRequest;

  /// No description provided for @closeOpenRequestTitle.
  ///
  /// In fr, this message translates to:
  /// **'Clôturer la demande ?'**
  String get closeOpenRequestTitle;

  /// No description provided for @closeOpenRequestBody.
  ///
  /// In fr, this message translates to:
  /// **'Les livreurs ne la verront plus.'**
  String get closeOpenRequestBody;

  /// No description provided for @openRequestOpenLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte'**
  String get openRequestOpenLabel;

  /// No description provided for @openRequestClosedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Clôturée'**
  String get openRequestClosedLabel;

  /// No description provided for @adminAdmins.
  ///
  /// In fr, this message translates to:
  /// **'Admins'**
  String get adminAdmins;

  /// No description provided for @adminAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un administrateur'**
  String get adminAddTitle;

  /// No description provided for @adminAddHint.
  ///
  /// In fr, this message translates to:
  /// **'La personne doit déjà être inscrite dans l\'application.'**
  String get adminAddHint;

  /// No description provided for @adminEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email du compte Google'**
  String get adminEmailLabel;

  /// No description provided for @adminEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide.'**
  String get adminEmailInvalid;

  /// No description provided for @adminAddButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get adminAddButton;

  /// No description provided for @adminAdded.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur ajouté.'**
  String get adminAdded;

  /// No description provided for @adminUserNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte avec cet email. La personne doit d\'abord s\'inscrire.'**
  String get adminUserNotFound;

  /// No description provided for @adminAlready.
  ///
  /// In fr, this message translates to:
  /// **'Cette personne est déjà administrateur.'**
  String get adminAlready;

  /// No description provided for @adminCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Administrateurs actuels'**
  String get adminCurrent;

  /// No description provided for @adminRemoveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer cet administrateur ?'**
  String get adminRemoveTitle;

  /// No description provided for @adminRemoveBody.
  ///
  /// In fr, this message translates to:
  /// **'Il perdra l\'accès au panneau d\'administration.'**
  String get adminRemoveBody;

  /// No description provided for @adminYou.
  ///
  /// In fr, this message translates to:
  /// **'Vous'**
  String get adminYou;

  /// No description provided for @welcomeGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour !'**
  String get welcomeGreeting;

  /// No description provided for @welcomeTagline.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez rapidement un livreur près de chez vous.'**
  String get welcomeTagline;

  /// No description provided for @roleClientShort.
  ///
  /// In fr, this message translates to:
  /// **'Je suis client'**
  String get roleClientShort;

  /// No description provided for @roleClientShortDesc.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai besoin d\'un livreur'**
  String get roleClientShortDesc;

  /// No description provided for @roleDriverShort.
  ///
  /// In fr, this message translates to:
  /// **'Je suis livreur'**
  String get roleDriverShort;

  /// No description provided for @roleDriverShortDesc.
  ///
  /// In fr, this message translates to:
  /// **'Je livre des colis'**
  String get roleDriverShortDesc;

  /// No description provided for @welcomeGoogleHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez votre profil pour continuer avec Google'**
  String get welcomeGoogleHint;

  /// No description provided for @phoneTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro est déjà utilisé par un autre compte. Utilisez un autre numéro.'**
  String get phoneTaken;

  /// No description provided for @idTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pièce d\'identité'**
  String get idTitle;

  /// No description provided for @idIntro.
  ///
  /// In fr, this message translates to:
  /// **'Pour vérifier votre compte, ajoutez une photo lisible de votre pièce d\'identité (carte nationale, permis de conduire ou passeport). Votre compte restera bloqué jusqu\'à sa validation par l\'administrateur.'**
  String get idIntro;

  /// No description provided for @idFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get idFromGallery;

  /// No description provided for @idFromCamera.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo'**
  String get idFromCamera;

  /// No description provided for @idChangePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get idChangePhoto;

  /// No description provided for @idRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez la photo de votre pièce d\'identité.'**
  String get idRequired;

  /// No description provided for @idUploadError.
  ///
  /// In fr, this message translates to:
  /// **'Envoi de la photo impossible. Vérifiez votre connexion et réessayez.'**
  String get idUploadError;

  /// No description provided for @idPickError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir la photo. Vérifiez les autorisations de l\'application.'**
  String get idPickError;

  /// No description provided for @idImageUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Image indisponible.'**
  String get idImageUnavailable;

  /// No description provided for @verifTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérification du compte'**
  String get verifTitle;

  /// No description provided for @verifPendingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Compte en cours de vérification'**
  String get verifPendingTitle;

  /// No description provided for @verifPendingBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'administrateur vérifie votre pièce d\'identité. Vous aurez accès à l\'application dès qu\'elle sera validée.'**
  String get verifPendingBody;

  /// No description provided for @verifRejectedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pièce d\'identité refusée'**
  String get verifRejectedTitle;

  /// No description provided for @verifRejectedBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre pièce n\'a pas été acceptée. Envoyez une nouvelle photo lisible pour relancer la vérification.'**
  String get verifRejectedBody;

  /// No description provided for @verifReason.
  ///
  /// In fr, this message translates to:
  /// **'Motif : {reason}'**
  String verifReason(String reason);

  /// No description provided for @verifResend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer une nouvelle photo'**
  String get verifResend;

  /// No description provided for @verifResent.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle photo envoyée. L\'administrateur va la vérifier.'**
  String get verifResent;

  /// No description provided for @verifChipVerified.
  ///
  /// In fr, this message translates to:
  /// **'Vérifié'**
  String get verifChipVerified;

  /// No description provided for @verifChipPending.
  ///
  /// In fr, this message translates to:
  /// **'À vérifier'**
  String get verifChipPending;

  /// No description provided for @verifChipRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusé'**
  String get verifChipRejected;

  /// No description provided for @adminVerifications.
  ///
  /// In fr, this message translates to:
  /// **'Vérifications'**
  String get adminVerifications;

  /// No description provided for @adminNoVerifications.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vérification en attente.'**
  String get adminNoVerifications;

  /// No description provided for @adminViewId.
  ///
  /// In fr, this message translates to:
  /// **'Voir la pièce d\'identité'**
  String get adminViewId;

  /// No description provided for @adminIdMissing.
  ///
  /// In fr, this message translates to:
  /// **'Aucune pièce d\'identité trouvée.'**
  String get adminIdMissing;

  /// No description provided for @adminRejectIdTitle.
  ///
  /// In fr, this message translates to:
  /// **'Refuser la pièce d\'identité'**
  String get adminRejectIdTitle;

  /// No description provided for @adminRejectIdHint.
  ///
  /// In fr, this message translates to:
  /// **'Motif (affiché au livreur)'**
  String get adminRejectIdHint;

  /// No description provided for @adminIdApproved.
  ///
  /// In fr, this message translates to:
  /// **'Livreur vérifié.'**
  String get adminIdApproved;

  /// No description provided for @adminIdRejected.
  ///
  /// In fr, this message translates to:
  /// **'Pièce refusée.'**
  String get adminIdRejected;

  /// No description provided for @revenueTitle.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires'**
  String get revenueTitle;

  /// No description provided for @revenueToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get revenueToday;

  /// No description provided for @revenueWeek.
  ///
  /// In fr, this message translates to:
  /// **'7 derniers jours'**
  String get revenueWeek;

  /// No description provided for @revenueMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get revenueMonth;

  /// No description provided for @revenueTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get revenueTotal;

  /// No description provided for @revenueDeliveries.
  ///
  /// In fr, this message translates to:
  /// **'{count} livraison(s) terminée(s)'**
  String revenueDeliveries(String count);

  /// No description provided for @revenueNoAmount.
  ///
  /// In fr, this message translates to:
  /// **'{count} ancienne(s) livraison(s) sans montant (non comptées)'**
  String revenueNoAmount(String count);

  /// No description provided for @amountDa.
  ///
  /// In fr, this message translates to:
  /// **'{amount} DA'**
  String amountDa(String amount);

  /// No description provided for @completeDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Montant de la livraison'**
  String get completeDialogTitle;

  /// No description provided for @completeDialogHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le prix de la course encaissé auprès du client.'**
  String get completeDialogHint;

  /// No description provided for @amountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant (DA)'**
  String get amountLabel;

  /// No description provided for @amountInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Montant invalide'**
  String get amountInvalid;

  /// No description provided for @completeConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get completeConfirm;

  /// No description provided for @requestAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant : {amount}'**
  String requestAmount(String amount);

  /// No description provided for @adminRevenue.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires'**
  String get adminRevenue;

  /// No description provided for @adminRevenueAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous les livreurs'**
  String get adminRevenueAll;

  /// No description provided for @adminNoRevenue.
  ///
  /// In fr, this message translates to:
  /// **'Aucune livraison terminée.'**
  String get adminNoRevenue;

  /// No description provided for @welcomeHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Vos colis livrés par des livreurs de votre quartier.'**
  String get welcomeHeadline;

  /// No description provided for @welcomeForWho.
  ///
  /// In fr, this message translates to:
  /// **'Clients et livreurs utilisent la même application.'**
  String get welcomeForWho;

  /// No description provided for @onboardingIntro.
  ///
  /// In fr, this message translates to:
  /// **'Encore une étape : votre numéro et votre rôle.'**
  String get onboardingIntro;

  /// No description provided for @phonePrivacyHint.
  ///
  /// In fr, this message translates to:
  /// **'Il n\'est partagé qu\'avec le client ou le livreur d\'une livraison acceptée.'**
  String get phonePrivacyHint;

  /// No description provided for @roleDriverTrial.
  ///
  /// In fr, this message translates to:
  /// **'2 mois gratuits'**
  String get roleDriverTrial;

  /// No description provided for @accountMenu.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get accountMenu;

  /// No description provided for @tabHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get tabHome;

  /// No description provided for @publishHeroTitle.
  ///
  /// In fr, this message translates to:
  /// **'Besoin d\'un livreur ?'**
  String get publishHeroTitle;

  /// No description provided for @sendRequestShort.
  ///
  /// In fr, this message translates to:
  /// **'Demander'**
  String get sendRequestShort;

  /// No description provided for @phoneAfterAccept.
  ///
  /// In fr, this message translates to:
  /// **'Son numéro s\'affichera dès qu\'il aura accepté votre demande.'**
  String get phoneAfterAccept;

  /// No description provided for @contactAfterAccept.
  ///
  /// In fr, this message translates to:
  /// **'Le numéro du livreur s\'affichera dès qu\'il aura accepté.'**
  String get contactAfterAccept;

  /// No description provided for @noRequestsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande'**
  String get noRequestsTitle;

  /// No description provided for @currentRequests.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get currentRequests;

  /// No description provided for @pastRequests.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get pastRequests;

  /// No description provided for @toHandleRequests.
  ///
  /// In fr, this message translates to:
  /// **'À traiter'**
  String get toHandleRequests;

  /// No description provided for @addressHint.
  ///
  /// In fr, this message translates to:
  /// **'Rue, quartier ou repère'**
  String get addressHint;

  /// No description provided for @noteHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : colis fragile, 2e étage'**
  String get noteHint;

  /// No description provided for @phoneNotAllowed.
  ///
  /// In fr, this message translates to:
  /// **'Pas de numéro de téléphone ici : il est partagé une fois la livraison acceptée.'**
  String get phoneNotAllowed;

  /// No description provided for @phoneNotAllowedChat.
  ///
  /// In fr, this message translates to:
  /// **'Message non envoyé : les numéros s\'échangent une fois la livraison acceptée.'**
  String get phoneNotAllowedChat;

  /// No description provided for @chatSafetyNotice.
  ///
  /// In fr, this message translates to:
  /// **'Les numéros de téléphone s\'échangent une fois la livraison acceptée.'**
  String get chatSafetyNotice;

  /// No description provided for @noConversationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversation'**
  String get noConversationsTitle;

  /// No description provided for @notifOpenRequestTaken.
  ///
  /// In fr, this message translates to:
  /// **'{name} a pris votre demande'**
  String notifOpenRequestTaken(String name);

  /// No description provided for @openRequestTakenBy.
  ///
  /// In fr, this message translates to:
  /// **'Prise par {name}'**
  String openRequestTakenBy(String name);

  /// No description provided for @reportDriver.
  ///
  /// In fr, this message translates to:
  /// **'Signaler ce livreur'**
  String get reportDriver;

  /// No description provided for @reportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signaler {name}'**
  String reportTitle(String name);

  /// No description provided for @reportIntro.
  ///
  /// In fr, this message translates to:
  /// **'L\'équipe Wassaly examine chaque signalement. Le livreur ne voit pas qui l\'a signalé.'**
  String get reportIntro;

  /// No description provided for @reportReasonOffApp.
  ///
  /// In fr, this message translates to:
  /// **'Il m\'a proposé de passer hors de l\'application'**
  String get reportReasonOffApp;

  /// No description provided for @reportReasonNotDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livraison non effectuée'**
  String get reportReasonNotDelivered;

  /// No description provided for @reportReasonBehavior.
  ///
  /// In fr, this message translates to:
  /// **'Comportement inapproprié'**
  String get reportReasonBehavior;

  /// No description provided for @reportReasonOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get reportReasonOther;

  /// No description provided for @reportNoteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui s\'est passé (facultatif)'**
  String get reportNoteLabel;

  /// No description provided for @reportSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le signalement'**
  String get reportSend;

  /// No description provided for @reportSent.
  ///
  /// In fr, this message translates to:
  /// **'Signalement envoyé'**
  String get reportSent;

  /// No description provided for @reportNotAllowed.
  ///
  /// In fr, this message translates to:
  /// **'Signalement impossible : vous avez déjà signalé ce livreur, ou vous n\'avez pas encore échangé avec lui.'**
  String get reportNotAllowed;

  /// No description provided for @acceptWithPrice.
  ///
  /// In fr, this message translates to:
  /// **'Accepter ({price} DA)'**
  String acceptWithPrice(String price);

  /// No description provided for @acceptChargeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accepter cette livraison ?'**
  String get acceptChargeTitle;

  /// No description provided for @acceptChargeBody.
  ///
  /// In fr, this message translates to:
  /// **'{price} DA seront ajoutés à votre solde, qui passera à {newDebt} DA. À {limit} DA, vous devrez payer avant d\'accepter de nouvelles livraisons.'**
  String acceptChargeBody(String price, String newDebt, String limit);

  /// No description provided for @takeAction.
  ///
  /// In fr, this message translates to:
  /// **'Je prends cette demande'**
  String get takeAction;

  /// No description provided for @takeWithPrice.
  ///
  /// In fr, this message translates to:
  /// **'Je prends ({price} DA)'**
  String takeWithPrice(String price);

  /// No description provided for @takeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prendre cette demande ?'**
  String get takeTitle;

  /// No description provided for @takeBody.
  ///
  /// In fr, this message translates to:
  /// **'Le client sera prévenu et vous aurez accès à son numéro.'**
  String get takeBody;

  /// No description provided for @takeChargeBody.
  ///
  /// In fr, this message translates to:
  /// **'{price} DA seront ajoutés à votre solde, qui passera à {newDebt} DA (blocage à {limit} DA). Vous aurez ensuite accès au numéro du client.'**
  String takeChargeBody(String price, String newDebt, String limit);

  /// No description provided for @takeConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Je la prends'**
  String get takeConfirm;

  /// No description provided for @takeDone.
  ///
  /// In fr, this message translates to:
  /// **'Demande prise. Contactez {name} depuis l\'onglet Demandes.'**
  String takeDone(String name);

  /// No description provided for @takeHint.
  ///
  /// In fr, this message translates to:
  /// **'Le contact du client s\'affiche une fois la demande prise.'**
  String get takeHint;

  /// No description provided for @openRequestsIntro.
  ///
  /// In fr, this message translates to:
  /// **'Le premier livreur qui prend une demande obtient le contact du client.'**
  String get openRequestsIntro;

  /// No description provided for @openRequestsIntroPaid.
  ///
  /// In fr, this message translates to:
  /// **'Le premier livreur qui prend une demande obtient le contact du client. {price} DA sont ajoutés à votre solde.'**
  String openRequestsIntroPaid(String price);

  /// No description provided for @openRequestsLockedDebt.
  ///
  /// In fr, this message translates to:
  /// **'Votre solde a atteint 1 000 DA. Réglez-le pour voir et prendre les demandes.'**
  String get openRequestsLockedDebt;

  /// No description provided for @noOpenRequestsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande pour l\'instant'**
  String get noOpenRequestsTitle;

  /// No description provided for @pendingRequestsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Demandes en attente'**
  String get pendingRequestsLabel;

  /// No description provided for @unreadMessagesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Messages non lus'**
  String get unreadMessagesLabel;

  /// No description provided for @myPosition.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get myPosition;

  /// No description provided for @positionNeverShared.
  ///
  /// In fr, this message translates to:
  /// **'Jamais partagée'**
  String get positionNeverShared;

  /// No description provided for @suspendedMsg.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte est suspendu. Contactez l\'équipe Wassaly.'**
  String get suspendedMsg;

  /// No description provided for @trialEndingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre essai se termine dans {days} jour(s)'**
  String trialEndingTitle(String days);

  /// No description provided for @trialEndingMsg.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre formule pour continuer à recevoir des demandes : 1 000 DA par mois ou 50 DA par livraison.'**
  String get trialEndingMsg;

  /// No description provided for @myPlan.
  ///
  /// In fr, this message translates to:
  /// **'Ma formule'**
  String get myPlan;

  /// No description provided for @noActivePlan.
  ///
  /// In fr, this message translates to:
  /// **'Aucune formule active'**
  String get noActivePlan;

  /// No description provided for @subPerDelivery.
  ///
  /// In fr, this message translates to:
  /// **'À la livraison'**
  String get subPerDelivery;

  /// No description provided for @subBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Bloqué'**
  String get subBlocked;

  /// No description provided for @choosePlan.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une formule'**
  String get choosePlan;

  /// No description provided for @choosePlanConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Choisir cette formule'**
  String get choosePlanConfirm;

  /// No description provided for @planForLater.
  ///
  /// In fr, this message translates to:
  /// **'Formule pour la suite'**
  String get planForLater;

  /// No description provided for @planSaved.
  ///
  /// In fr, this message translates to:
  /// **'Formule enregistrée'**
  String get planSaved;

  /// No description provided for @planMonthlyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mensuelle'**
  String get planMonthlyTitle;

  /// No description provided for @planMonthlyPrice.
  ///
  /// In fr, this message translates to:
  /// **'{price} DA par mois'**
  String planMonthlyPrice(String price);

  /// No description provided for @planMonthlyDesc.
  ///
  /// In fr, this message translates to:
  /// **'Livraisons illimitées pendant 30 jours. Vous payez d\'avance.'**
  String get planMonthlyDesc;

  /// No description provided for @planPerDeliveryTitle.
  ///
  /// In fr, this message translates to:
  /// **'À la livraison'**
  String get planPerDeliveryTitle;

  /// No description provided for @planPerDeliveryPrice.
  ///
  /// In fr, this message translates to:
  /// **'{price} DA par livraison'**
  String planPerDeliveryPrice(String price);

  /// No description provided for @planPerDeliveryDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rien à avancer. Chaque livraison acceptée s\'ajoute à votre solde, à régler avant d\'atteindre {limit} DA.'**
  String planPerDeliveryDesc(String limit);

  /// No description provided for @planEffectOn.
  ///
  /// In fr, this message translates to:
  /// **'Prendra effet le {date}, à la fin de votre période en cours.'**
  String planEffectOn(String date);

  /// No description provided for @planEffectAfterPayment.
  ///
  /// In fr, this message translates to:
  /// **'Prendra effet dès que votre paiement de {amount} DA sera validé.'**
  String planEffectAfterPayment(String amount);

  /// No description provided for @planEffectNow.
  ///
  /// In fr, this message translates to:
  /// **'Prend effet tout de suite : 50 DA par livraison acceptée.'**
  String get planEffectNow;

  /// No description provided for @trialUntil.
  ///
  /// In fr, this message translates to:
  /// **'Encore {days} jour(s) gratuit(s), jusqu\'au {date}.'**
  String trialUntil(String days, String date);

  /// No description provided for @debtLabel.
  ///
  /// In fr, this message translates to:
  /// **'Votre solde à régler'**
  String get debtLabel;

  /// No description provided for @debtLimitSuffix.
  ///
  /// In fr, this message translates to:
  /// **'sur {limit} DA'**
  String debtLimitSuffix(String limit);

  /// No description provided for @debtOfLimit.
  ///
  /// In fr, this message translates to:
  /// **'Solde : {debt} DA sur {limit} DA'**
  String debtOfLimit(String debt, String limit);

  /// No description provided for @deliveriesLeft.
  ///
  /// In fr, this message translates to:
  /// **'Encore {count} livraison(s) avant le blocage.'**
  String deliveriesLeft(String count);

  /// No description provided for @debtBlockedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Solde à régler'**
  String get debtBlockedTitle;

  /// No description provided for @debtBlockedMsg.
  ///
  /// In fr, this message translates to:
  /// **'Vous devez {debt} DA. Réglez ce montant pour accepter de nouvelles livraisons.'**
  String debtBlockedMsg(String debt);

  /// No description provided for @debtWarnTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre solde atteint {debt} DA'**
  String debtWarnTitle(String debt);

  /// No description provided for @debtWarnMsg.
  ///
  /// In fr, this message translates to:
  /// **'Encore {count} livraison(s) avant le blocage. Pensez à régler votre solde.'**
  String debtWarnMsg(String count);

  /// No description provided for @payTitle.
  ///
  /// In fr, this message translates to:
  /// **'Payer'**
  String get payTitle;

  /// No description provided for @payDebt.
  ///
  /// In fr, this message translates to:
  /// **'Régler mon solde'**
  String get payDebt;

  /// No description provided for @payMonth.
  ///
  /// In fr, this message translates to:
  /// **'Payer le mois'**
  String get payMonth;

  /// No description provided for @amountToPay.
  ///
  /// In fr, this message translates to:
  /// **'Montant à payer'**
  String get amountToPay;

  /// No description provided for @monthPlusDebt.
  ///
  /// In fr, this message translates to:
  /// **'{month} DA pour le mois et {debt} DA de solde'**
  String monthPlusDebt(String month, String debt);

  /// No description provided for @iHavePaidAmount.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai payé {amount} DA'**
  String iHavePaidAmount(String amount);

  /// No description provided for @claimTitle.
  ///
  /// In fr, this message translates to:
  /// **'{kind} : {amount}'**
  String claimTitle(String kind, String amount);

  /// No description provided for @ledgerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mouvements du solde'**
  String get ledgerTitle;

  /// No description provided for @ledgerCharge.
  ///
  /// In fr, this message translates to:
  /// **'Livraison acceptée'**
  String get ledgerCharge;

  /// No description provided for @ledgerRefund.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement (annulation)'**
  String get ledgerRefund;

  /// No description provided for @ledgerPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement validé'**
  String get ledgerPayment;

  /// No description provided for @billingErrorDebtLimit.
  ///
  /// In fr, this message translates to:
  /// **'Votre solde a atteint 1 000 DA. Réglez-le dans Ma formule pour accepter de nouvelles livraisons.'**
  String get billingErrorDebtLimit;

  /// No description provided for @billingErrorNotEligible.
  ///
  /// In fr, this message translates to:
  /// **'Votre formule ne vous permet pas d\'accepter de livraison. Ouvrez Ma formule.'**
  String get billingErrorNotEligible;

  /// No description provided for @billingErrorNotPending.
  ///
  /// In fr, this message translates to:
  /// **'Cette demande n\'est plus en attente.'**
  String get billingErrorNotPending;

  /// No description provided for @billingErrorAlreadyTaken.
  ///
  /// In fr, this message translates to:
  /// **'Un autre livreur a pris cette demande avant vous.'**
  String get billingErrorAlreadyTaken;

  /// No description provided for @adminSuspects.
  ///
  /// In fr, this message translates to:
  /// **'Suspects'**
  String get adminSuspects;

  /// No description provided for @adminNoSuspectsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rien à signaler'**
  String get adminNoSuspectsTitle;

  /// No description provided for @adminNoSuspects.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livreur ne présente de comportement inhabituel.'**
  String get adminNoSuspects;

  /// No description provided for @adminPaymentApproved.
  ///
  /// In fr, this message translates to:
  /// **'Paiement validé'**
  String get adminPaymentApproved;

  /// No description provided for @suspectCancellations.
  ///
  /// In fr, this message translates to:
  /// **'{cancelled} livraisons annulées après acceptation, sur {accepted}'**
  String suspectCancellations(String cancelled, String accepted);

  /// No description provided for @suspectChats.
  ///
  /// In fr, this message translates to:
  /// **'{chats} conversations pour {accepted} livraisons acceptées'**
  String suspectChats(String chats, String accepted);

  /// No description provided for @suspectReports.
  ///
  /// In fr, this message translates to:
  /// **'Signalé par {count} clients'**
  String suspectReports(String count);

  /// No description provided for @suspectDebt.
  ///
  /// In fr, this message translates to:
  /// **'Bloqué depuis plus de 7 jours avec {debt} DA de solde'**
  String suspectDebt(String debt);

  /// No description provided for @statAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Acceptées'**
  String get statAccepted;

  /// No description provided for @statCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminées'**
  String get statCompleted;

  /// No description provided for @statCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulées'**
  String get statCancelled;

  /// No description provided for @statChats.
  ///
  /// In fr, this message translates to:
  /// **'Discussions'**
  String get statChats;

  /// No description provided for @statReports.
  ///
  /// In fr, this message translates to:
  /// **'Signalements'**
  String get statReports;

  /// No description provided for @reportsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signalements'**
  String get reportsTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
