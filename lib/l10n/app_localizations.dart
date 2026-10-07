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
  /// **'Actif'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get statusInactive;

  /// No description provided for @activeHint.
  ///
  /// In fr, this message translates to:
  /// **'Les clients proches de vous peuvent vous voir et vous contacter.'**
  String get activeHint;

  /// No description provided for @inactiveHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes masqué. Activez-vous pour recevoir des demandes.'**
  String get inactiveHint;

  /// No description provided for @activate.
  ///
  /// In fr, this message translates to:
  /// **'Je suis disponible'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In fr, this message translates to:
  /// **'Me rendre indisponible'**
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
  /// **'Votre abonnement est expiré ou suspendu. Renouvelez-le pour être visible.'**
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
  /// **'Abonnement actif'**
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
  /// **'Votre abonnement n\'est plus valide : vous n\'apparaissez plus aux clients.'**
  String get subscriptionExpiredMsg;

  /// No description provided for @manageSubscription.
  ///
  /// In fr, this message translates to:
  /// **'Gérer mon abonnement'**
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
  /// **'1. Effectuez le paiement avec les coordonnées ci-dessous.\n2. Saisissez la référence du paiement et envoyez.\n3. L\'administrateur valide et ajoute 30 jours à votre abonnement.'**
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
  /// **'Historique des demandes'**
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
  /// **'Clients qui cherchent un livreur'**
  String get openRequestsTitle;

  /// No description provided for @noOpenRequests.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client ne cherche de livreur pour le moment.'**
  String get noOpenRequests;

  /// No description provided for @openRequestsLocked.
  ///
  /// In fr, this message translates to:
  /// **'Un abonnement valide est nécessaire pour voir les clients qui cherchent un livreur.'**
  String get openRequestsLocked;

  /// No description provided for @notifNewOpenRequest.
  ///
  /// In fr, this message translates to:
  /// **'Un client cherche un livreur.'**
  String get notifNewOpenRequest;

  /// No description provided for @publishOpenRequest.
  ///
  /// In fr, this message translates to:
  /// **'Publier une demande ouverte'**
  String get publishOpenRequest;

  /// No description provided for @publishOpenRequestHint.
  ///
  /// In fr, this message translates to:
  /// **'Les livreurs abonnés la verront et pourront vous contacter.'**
  String get publishOpenRequestHint;

  /// No description provided for @newOpenRequest.
  ///
  /// In fr, this message translates to:
  /// **'Demande ouverte'**
  String get newOpenRequest;

  /// No description provided for @openRequestIntro.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre livraison : les livreurs abonnés pourront vous appeler ou vous écrire.'**
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
