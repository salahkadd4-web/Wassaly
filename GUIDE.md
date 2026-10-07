# Wassaly - Guide d'utilisation

Application mobile (Flutter + Firebase) qui met en relation des clients et des livreurs de proximite en Algerie.
Langues : francais et arabe (avec affichage de droite a gauche). Theme clair par defaut avec bouton pour passer en mode sombre (choix memorise).

## 1. Ce que contient le projet

| Fonction | Etat |
|---|---|
| Connexion Google, choix du role (client / livreur), telephone algerien | Fait |
| Livreur : activation, position GPS, ville, essai gratuit de 2 mois | Fait |
| Client : liste des livreurs actifs triee par distance (GPS) | Fait |
| Appel, WhatsApp, messagerie interne | Fait |
| Demande de livraison (recuperation + livraison, adresse et/ou GPS, note) | Fait |
| Acceptation / refus / fin de livraison, annulation par le client | Fait |
| Itineraire Google Maps vers les adresses de la demande | Fait |
| Abonnement 1 000 DA/mois, declaration de paiement, validation par l'admin | Fait |
| Panneau administrateur (livreurs, paiements, clients, demandes, admins) | Fait |
| Demandes ouvertes : le client publie, les livreurs abonnes les consultent et le contactent | Fait |
| Bouton retour Android : confirmation avant de quitter (connexion et tableaux de bord) | Fait |
| Notifications dans l'application (bandeaux + pastilles de compteur) | Fait |
| Notifications push quand l'application est fermee | Non inclus (voir section 9) |
| iOS | Non inclus (Android uniquement) |

Le logo Wassaly (pin + colis) est l'icone de l'application sur le telephone et l'ecran de demarrage.

## 2. Prerequis

- Flutter (version stable recente, Dart 3.x) : https://docs.flutter.dev/get-started/install
- Android Studio avec le SDK Android, ou un telephone Android en mode developpeur
- JDK 17 (fourni avec Android Studio)
- Le projet Firebase `wassaly-c3f99` (deja configure dans `android/app/google-services.json`)

Verifiez l'installation avec : `flutter doctor`

## 3. Lancer l'application

```
cd wassaly
flutter pub get
flutter gen-l10n
flutter run
```

`flutter gen-l10n` regenere les traductions (les fichiers sont deja fournis, mais cette commande ne fait pas de mal).
Pour verifier le code : `flutter analyze` puis `flutter test`.

## 4. Configuration Firebase (a faire une seule fois)

1. **Authentication** : console Firebase > Authentication > Sign-in method > activer **Google**.
2. **Empreinte SHA-1** (obligatoire, sinon la connexion Google echoue avec `ApiException: 10`) :
   - Dans le dossier `android`, lancez : `./gradlew signingReport` (Windows : `gradlew signingReport`)
   - Copiez la valeur **SHA1** de la variante `debug`.
   - Console Firebase > Parametres du projet > Vos applications > application Android > **Ajouter une empreinte**.
   - Telechargez ensuite le nouveau `google-services.json` et remplacez `android/app/google-services.json`.
   - Faites la meme chose avec la SHA-1 de votre cle de release avant de publier l'APK final.
3. **Firestore** : console Firebase > Firestore Database > creer la base (mode production).
4. **Regles de securite** : ouvrez `firestore.rules` (a la racine du projet), copiez tout le contenu dans
   Firestore > onglet **Regles** > **Publier**.
   (Ou avec la CLI Firebase : `firebase deploy --only firestore:rules`.)

Aucun index Firestore n'est necessaire : les listes sont triees dans l'application.

## 5. Creer le compte administrateur

1. Ouvrez l'application et connectez-vous avec le compte Google qui sera administrateur (terminez l'inscription).
2. Console Firebase > Authentication > Utilisateurs : copiez l'**UID** de ce compte.
3. Firestore > **Demarrer une collection** > nom : `admins` > ID du document : collez l'UID >
   ajoutez un champ quelconque (par exemple `actif` = true) > Enregistrer.
4. Relancez l'application : une icone **Administration** apparait dans la barre du haut.

Les regles de securite empechent quiconque de se donner ce role depuis l'application.

**Ajouter d'autres administrateurs** : ce premier admin ouvre Administration > onglet **Admins**, saisit l'email Google
du compte (qui doit deja etre inscrit dans l'application) et appuie sur **Ajouter**. Il peut aussi retirer un admin
(sauf lui-meme). Republiez `firestore.rules` pour activer cette fonction.

## 6. Renseigner vos moyens de paiement

Les livreurs voient vos coordonnees de paiement dans l'ecran Abonnement. Modifiez le texte dans
`lib/core/constants/app_config.dart` :

```dart
static const String paymentDetails = 'BaridiMob / CCP : 00799999 0012345678 - Nom Prenom';
```

Vous pouvez aussi y changer le prix affiche (`monthlyPriceDa`), la duree de l'essai (`trialDays`) et la duree d'un abonnement (`subscriptionDays`).
Attention : les regles Firestore limitent l'essai a 62 jours maximum a l'inscription ; si vous passez `trialDays` au-dessus de 60,
adaptez aussi la valeur `62` dans `firestore.rules`.

## 6 bis. Un seul compte par numero de telephone

Chaque numero ne peut etre utilise que par un compte : a l'inscription, l'application reserve le numero dans la collection
`phones` (un document par numero). Si le numero est deja pris, l'inscription est refusee avec le message
« Ce numero est deja utilise par un autre compte ». Le numero n'est plus modifiable apres l'inscription.

**Comptes deja inscrits avant cette mise a jour** : leurs numeros ne sont pas encore reserves. Lancez une fois le script
`tools/backfill_phones.js` (voir l'en-tete du fichier) pour les reserver et lister les doublons existants.
Limite : le numero n'est pas verifie par SMS, il empeche les doublons simples mais pas l'usage du numero d'un tiers.

## 7. Utilisation

### Client
1. Connexion Google, saisie du telephone, choix du role **Client**.
2. Onglet **Livreurs** : autorisez la localisation. Les livreurs disponibles s'affichent, du plus proche au plus loin.
   Tirez vers le bas pour actualiser.
3. Sur une carte : **Appeler**, **WhatsApp** ou **Message**. Touchez la carte pour ouvrir le profil.
4. Profil du livreur > **Envoyer une demande de livraison** : renseignez le lieu de recuperation et le lieu de livraison
   (adresse ecrite et/ou bouton **Partager ma position actuelle**), ajoutez une note, envoyez.
5. Onglet **Demandes** : suivez le statut (en attente, acceptee, terminee...), annulez si besoin.

### Demandes ouvertes (client -> livreurs)
Le client ouvre l'onglet **Demandes** > **Publier une demande ouverte** (recuperation, livraison, note). Tous les livreurs dont
l'abonnement est valide la voient dans l'onglet **Clients** et peuvent appeler, ecrire sur WhatsApp ou envoyer un message.
Le client peut la **Clôturer** ; elle disparait aussi pour les livreurs apres 72 h.

### Livreur
1. Connexion Google, telephone, role **Livreur**. L'essai gratuit de 2 mois demarre automatiquement.
2. **Tableau de bord** : renseignez votre ville, puis appuyez sur **Je suis disponible** (la position GPS est enregistree).
   Utilisez **Mettre a jour ma position** quand vous changez de quartier.
3. Onglet **Demandes** : **Accepter** ou **Refuser**, puis **Marquer comme terminee**. Les boutons Appeler, WhatsApp et
   l'icone d'itineraire ouvrent le telephone, WhatsApp et Google Maps.
4. **Abonnement** : quand l'essai se termine, payez 1 000 DA, saisissez la reference du paiement et envoyez.
   Sans abonnement valide, le livreur est automatiquement retire de la liste des clients.

### Bouton retour
Sur l'ecran de connexion et sur les tableaux de bord, le bouton retour demande confirmation avant de quitter. Depuis un autre onglet, il ramene d'abord au premier.

### Administrateur
Icone **Administration** dans la barre du haut :
- **Livreurs** : statut, date de fin d'abonnement, menu pour prolonger de 30 jours, suspendre / lever la suspension, desactiver, appeler.
- **Paiements** : liste des declarations de paiement ; **Valider** ajoute 30 jours, **Refuser** rejette.
- **Clients** et **Demandes** : consultation.

## 8. Generer l'APK

APK de test (installable directement) :
```
flutter build apk --release
```
Fichier genere : `build/app/outputs/flutter-apk/app-release.apk`. Envoyez-le sur le telephone et installez-le.

Pour publier sur le Play Store, creez une cle de signature (https://docs.flutter.dev/deployment/android#sign-the-app),
configurez-la dans `android/app/build.gradle.kts` (actuellement la cle de debug est utilisee) et ajoutez sa SHA-1 dans Firebase.
Utilisez alors `flutter build appbundle --release`.

## 9. Limites connues et suite possible

- **Notifications push** : les alertes actuelles apparaissent quand l'application est ouverte (bandeau + pastilles).
  Recevoir une alerte application fermee demande Firebase Cloud Messaging et une Cloud Function pour envoyer les messages,
  ce qui impose le forfait Firebase Blaze (paiement a l'usage).
- **Paiement** : la validation est manuelle (l'admin verifie le paiement puis valide). Une integration de paiement en ligne n'est pas incluse.
- **Position du livreur** : elle est enregistree a l'activation et lors de la mise a jour manuelle (pas de suivi en temps reel).
- **Distance** : calculee en ligne droite (pas la distance routiere).
- **Test sur emulateur** : le GPS de l'emulateur est fixe ; definissez une position dans Extended controls > Location.

## 10. Depannage

| Probleme | Solution |
|---|---|
| `ApiException: 10` a la connexion Google | SHA-1 manquante dans Firebase (section 4, etape 2) |
| `permission-denied` | Regles Firestore non publiees ou ancienne version (section 4, etape 4) |
| Aucun livreur affiche | Le livreur doit etre **actif**, avec un abonnement valide, et avoir une position enregistree |
| La liste n'est pas triee par distance | Localisation refusee ou GPS coupe (un bandeau l'indique) |
| L'icone ou l'ecran de demarrage n'a pas change | Desinstallez l'ancienne version puis relancez `flutter run` |
| Erreurs de traduction `AppLocalizations` | Lancez `flutter gen-l10n` |
| Pas d'icone Administration | Verifiez le document `admins/<UID>` (section 5) |

## 11. Structure du code

```
lib/
  core/        configuration, theme, routeur, langues, utilitaires
  models/      DriverProfile, DeliveryRequest, Conversation, ...
  services/    localisation GPS
  features/    auth, client, driver, drivers, requests, chat, subscription, admin
  widgets/     composants partages
  l10n/        traductions francais / arabe (fichiers .arb)
assets/branding/   logo et identite visuelle
firestore.rules    regles de securite a publier
```
