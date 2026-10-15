# Wassaly - Guide d'utilisation

Application mobile (Flutter + Firebase) qui met en relation des clients et des livreurs de proximite en Algerie.
Langues : francais et arabe (avec affichage de droite a gauche). Theme clair par defaut avec bouton pour passer en mode sombre (choix memorise).

## 1. Ce que contient le projet

| Fonction | Etat |
|---|---|
| Connexion Google, choix du role (client / livreur), telephone algerien | Fait |
| Livreur : activation, position GPS, ville, essai gratuit de 2 mois | Fait |
| Client : liste des livreurs actifs triee par distance (GPS) | Fait |
| Appel, WhatsApp (apres acceptation d'une livraison), messagerie interne | Fait |
| Demande de livraison (recuperation + livraison, adresse et/ou GPS, note) | Fait |
| Acceptation / refus / fin de livraison, annulation par le client | Fait |
| Itineraire Google Maps vers les adresses de la demande | Fait |
| Formules livreur apres l'essai : 1 000 DA/mois ou 50 DA par livraison, paiement declare et valide par l'admin | Fait (voir section 6 septies) |
| Anti-fraude : numeros masques, debit cote serveur, signalements, onglet admin Suspects | Fait (voir section 6 septies) |
| Panneau administrateur (livreurs, paiements, verifications, suspects, chiffre d'affaires, clients, demandes, admins) | Fait |
| Demandes ouvertes : le client publie, le premier livreur qui la prend obtient la course | Fait |
| Bouton retour Android : confirmation avant de quitter (connexion et tableaux de bord) | Fait |
| Notifications dans l'application (bandeaux + pastilles de compteur) | Fait |
| Notifications push livreur (nouveau message, nouvelle demande) application fermee | Fait (Cloud Functions, voir section 6 quinquies) |
| Notifications push client (demande acceptee / refusee / terminee, course prise, message) | Fait (voir section 6 octies) |
| Prix de course choisi par le livreur dans une liste, notes 1 a 5 etoiles, recherche a 10 km | Fait (voir section 6 octies) |
| Chiffre d'affaires du livreur (tableau de bord) et de tous les livreurs (admin) | Fait (voir section 6 sexies) |
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

## 6 ter. Diffusion par code QR

Publier une nouvelle version : voir `PUBLIER_UNE_VERSION.md`.
Premiere diffusion : voir `DISTRIBUTION.md` (signature de l'APK, declaration de la cle a Firebase, hebergement gratuit sur GitHub Releases,
creation du QR (`tools/make_qr.py`) et consignes d'installation pour les utilisateurs).

## 6 quater. Verification de la piece d'identite des livreurs (Cloudinary)

A l'inscription, un livreur doit ajouter une photo de sa piece d'identite (galerie ou appareil photo). Son compte est
**bloque** (ecran « Compte en cours de verification ») jusqu'a la validation par un administrateur.

- Photo envoyee sur Cloudinary ; l'URL est stockee dans Firestore `driverIdentity/{uid}` (lisible par le livreur et les admins seulement).
- `drivers/{uid}.verificationStatus` : `pending` (en attente) -> `approved` (valide) ou `rejected` (refuse, avec motif).
- Admin > onglet **Verifications** : voir la piece (zoom), **Valider** ou **Refuser** (motif affiche au livreur, qui peut renvoyer une photo).
- Les livreurs inscrits **avant** cette fonction n'ont pas le champ : ils sont consideres comme valides.
- Un administrateur n'est jamais bloque par cet ecran.

### Configurer Cloudinary
1. Dans le Dashboard Cloudinary, notez le **Cloud name** (c'est la partie apres le `@` de votre `CLOUDINARY_URL`).
2. Settings > Upload > **Upload presets** > Add upload preset :
   - Signing mode : **Unsigned**
   - Folder : `wassaly/driver_ids`
   - Allowed formats : `jpg, jpeg, png, webp` ; limitez la taille max du fichier (ex. 5 Mo)
3. Copiez le nom du preset, puis dans `lib/core/constants/app_config.dart` :
   ```dart
   static const String cloudinaryCloudName = 'votre_cloud_name';
   static const String cloudinaryUploadPreset = 'votre_preset';
   ```
4. **Ne mettez jamais** `API_KEY` / `API_SECRET` (ni la `CLOUDINARY_URL` complete) dans l'application ou dans Git.
5. `flutter pub get`, puis republiez `firestore.rules`.

## 6 quinquies. Notifications push (livreurs)

Un livreur recoit une notification, meme application fermee, quand :
- un client lui envoie un **message** ;
- un client publie une **demande ouverte** (tous les livreurs abonnes et verifies) ;
- un client lui envoie une **demande de livraison** directe.

Un appui sur la notification ouvre l'onglet correspondant. Application ouverte, les bandeaux et pastilles habituels restent utilises.

**Fonctionnement** : l'application enregistre le jeton de l'appareil du livreur dans Firestore (`deviceTokens/{uid}`) ; trois Cloud Functions
(`functions/index.js`) envoient la notification a chaque nouveau message / nouvelle demande. Seuls les livreurs enregistrent un jeton.

**Mise en place (une seule fois)** :
1. Passer le projet Firebase au forfait **Blaze** (obligatoire pour les Cloud Functions ; carte bancaire demandee). Les quotas gratuits
   (2 millions d'appels par mois) couvrent largement l'usage prevu : le cout attendu est nul. Creez une **alerte de budget** dans la console.
2. Installer Node.js 22 puis la CLI : `npm install -g firebase-tools` et `firebase login`.
3. Ouvrir `functions/index.js` et regler `REGION` sur la region de votre Firestore (console Firebase > Firestore Database > Donnees > « Emplacement » ;
   `europe-west1` pour « eur3 » / Belgique, `us-central1` pour « nam5 »).
4. Deployer :
   ```
   cd functions
   npm install
   cd ..
   firebase deploy --only functions,firestore:rules,firestore:indexes
   ```
   Acceptez l'activation des API proposees. La commande publie aussi les nouvelles `firestore.rules`.
5. `flutter pub get`, reconstruire l'APK (voir `PUBLIER_UNE_VERSION.md`). Au premier lancement, le livreur doit **autoriser les notifications**.

**Test** : connectez-vous en livreur sur un telephone, fermez l'application, puis envoyez-lui un message depuis un compte client.
Si rien n'arrive : `firebase functions:log`, et verifiez que le document `deviceTokens/<uid du livreur>` existe dans Firestore.

**Limites** : sur certains telephones (Xiaomi, Huawei, Oppo...), l'economiseur de batterie bloque les notifications des applications fermees ;
le livreur doit autoriser Wassaly a s'executer en arriere-plan. Les clients ne recoivent pas de notification push (livreurs uniquement).

## 6 sexies. Chiffre d'affaires

**Livreur** : quand il appuie sur **Marquer comme terminee**, l'application lui demande le **montant de la livraison (DA)**.
Ce montant est enregistre avec la date de fin. Le tableau de bord affiche le chiffre d'affaires : **aujourd'hui**, **7 derniers jours**,
**ce mois**, **total**, et le nombre de livraisons terminees.

**Administrateur** : onglet **Chiffre d'affaires** du panneau d'administration : total de tous les livreurs et classement par livreur,
filtrable par periode (aujourd'hui, 7 jours, mois, total). Le montant apparait aussi sur chaque demande terminee.

**Regles de calcul** : seules les livraisons au statut « terminee » comptent ; le montant est celui saisi par le livreur (declaratif).
Les livraisons terminees **avant** cette mise a jour n'ont pas de montant : elles ne sont pas comptees dans le chiffre d'affaires
(le tableau de bord indique combien). Le calcul est dans `lib/core/utils/revenue.dart` (teste dans `test/revenue_test.dart`).
Republiez `firestore.rules` : elles autorisent la saisie du montant a la fin de la livraison.

## 6 septies. Formules des livreurs et anti-fraude

### Les formules
Apres l'**essai gratuit de 2 mois**, le livreur choisit dans **Ma formule** :

| Formule | Prix | Fonctionnement |
|---|---|---|
| Mensuelle | 1 000 DA / 30 jours | Paye d'avance (reference BaridiMob / CCP), l'admin valide. |
| A la livraison | 50 DA par livraison acceptee | Rien a avancer : chaque acceptation ajoute 50 DA a son **solde**. A **1 000 DA** (20 livraisons), il est bloque jusqu'au paiement valide par l'admin. Alerte des 800 DA. |

- Pendant l'essai ou un mois paye, le choix prend effet **a la fin de la periode** (une fonction planifiee bascule chaque nuit a 3 h).
- Un livreur expire qui choisit « a la livraison » peut travailler tout de suite.
- Un livreur « a la livraison » qui veut passer au mensuel paie **solde + 1 000 DA**.
- **Remboursement** : si le client annule moins de 2 h apres l'acceptation, les 50 DA sont rendus (3 fois par mois au maximum).

Valeurs modifiables : `lib/core/constants/app_config.dart` **et** `functions/billing.js` (les deux doivent rester identiques ;
c'est le serveur qui debite, l'application ne fait qu'afficher).

### Comment les livraisons sont comptees
Personne ne peut conclure une course directement dans Firestore : l'accord sur le prix passe par la Cloud Function
`agreeDelivery` (ou `agreeOffer` pour une demande ouverte), qui verifie la formule du livreur, debite 50 DA si besoin et note le mouvement
dans `driverBilling/{uid}/ledger`. Chaque livraison a un identifiant unique de debit : impossible de payer deux fois.

### Ce qui empeche de contourner l'application
- **Numeros masques** : le telephone n'est plus dans les profils publics. Client et livreur le voient seulement une fois la
  livraison acceptee (`deliveryRequests/{id}/private/contact`, ecrit par le serveur).
- **Demandes ouvertes** : plus de numero ni d'adresse exacte avant l'accord ; chaque livreur fait une offre, et seul celui retenu
  l'obtient, et la course devient une livraison suivie.
- **Chat, notes, noms** : les regles Firestore refusent tout texte contenant un numero (05/06/07, +213, chiffres arabes...).
- **Signalement** : le client peut signaler un livreur (une fois par livreur, apres un echange).
- **Onglet admin Suspects** : livreurs avec plus de 30 % d'annulations apres acceptation, plus de 3 conversations par
  livraison acceptee, 2 signalements ou plus, ou bloques pour dette depuis plus de 7 jours. Bouton Suspendre.

**Limite** : un client et un livreur qui se connaissent deja peuvent toujours s'arranger hors application.
Le systeme le rend visible (ratios, signalements), il ne peut pas l'empecher.

### Mise en service (une seule fois)
```
cd functions
npm install
npm test
cd ..
firebase deploy --only functions,firestore:rules,firestore:indexes
```
Puis, pour retirer les numeros des donnees de test deja enregistrees (voir l'en-tete du script) :
```
cd tools
node strip_public_phones.js          # simulation
node strip_public_phones.js --apply
```
La fonction planifiee `rolloverSubscriptions` utilise Cloud Scheduler (inclus dans le forfait Blaze, 3 taches gratuites).

## 6 octies. Prix, notes, references de paiement, recherche par zone

### Prix de la course (negociation)
Le prix se **negocie**, entre **100 et 300 DA, par pas de 10 DA** (boutons -10 / +10 et raccourcis 100, 150, 200, 250, 300) :
1. Le livreur **propose** un prix (ou refuse la demande).
2. Le client **accepte**, **contre-propose** ou annule ; puis le livreur repond, et ainsi de suite, chacun a son tour.
3. **A l'accord**, la course est comptee (+50 DA de solde pour un livreur « a la livraison »), et chacun voit le
   **numero** de l'autre et l'**adresse exacte**.

**Avant l'accord**, le livreur ne voit que le **quartier** de chaque etape et la **distance** de la course (si le client a
partage ses deux positions GPS). L'adresse exacte est dans un document prive (`private/route`) que les regles Firestore
ne lui ouvrent qu'apres l'accord.

**Demande ouverte** : chaque livreur interesse fait **son offre** ; le client voit toutes les offres (avec la note de
chaque livreur), negocie avec qui il veut, et le **premier accord** attribue la course (les autres offres sont closes).

A la fin, **Marquer comme terminee** enregistre le prix convenu (les regles refusent tout autre montant).
Bornes modifiables : `priceMinDa`, `priceMaxDa`, `priceStepDa` dans `app_config.dart`, **et** `PRICE_MIN_DA`,
`PRICE_MAX_DA`, `PRICE_STEP_DA` dans `functions/billing.js`, **et** la fonction `validPrice` de `firestore.rules`.

### Notes
Apres une livraison terminee, le client peut la **noter** (1 a 5 etoiles + commentaire facultatif), une seule fois.
La moyenne s'affiche sur la carte et la fiche du livreur, et sur son tableau de bord. Elle est calculee par le serveur
(`onRatingCreated`) : ni le client ni le livreur ne peuvent la modifier. Une moyenne inferieure a 3 sur au moins 3 avis
fait apparaitre le livreur dans l'onglet **Suspects**.

### Reference de paiement unique
Chaque reference declaree est reservee dans `paymentRefs/{reference}` (majuscules, sans espaces ni tirets).
Une reference deja declaree, par n'importe quel livreur, est refusee. Si un livreur s'est trompe et que vous refusez sa
declaration, la reference reste bloquee : supprimez-la a la main dans la console Firestore (`paymentRefs`) si besoin.

### Recherche des livreurs dans un rayon de 10 km
Le client ne charge plus que les livreurs **en ligne a moins de 10 km** (`searchRadiusKm` dans `app_config.dart`),
grace au geohash enregistre avec la position du livreur. Il faut l'**index Firestore** du fichier
`firestore.indexes.json` (deploye avec la commande ci-dessous ; sa creation prend quelques minutes).
Un livreur deja en ligne avant cette version doit se remettre en ligne (ou actualiser sa position) pour apparaitre.
Sans localisation, le client voit un bandeau et peut toujours publier une course.

### Notifications des clients
Le telephone du client s'enregistre aussi pour les notifications. Il est prevenu quand sa demande est acceptee (avec le
prix), refusee ou terminee (invitation a noter), quand un livreur prend sa course, et quand il recoit un message.
Le livreur est prevenu quand un client annule.

### Mise en service
```
cd functions
npm test
cd ..
firebase deploy --only functions,firestore:rules,firestore:indexes
```

## 7. Utilisation

### Client
1. Connexion Google, saisie du telephone, choix du role **Client**.
2. Onglet **Accueil** : **Publier une course** (tous les livreurs proches la voient), ou choisir un livreur dans la liste,
   triee du plus proche au plus loin (autorisez la localisation ; tirez vers le bas pour actualiser).
3. Sur une carte : **Demander** ou **Message**. Touchez la carte pour ouvrir le profil.
4. **Demander** : renseignez le lieu de recuperation et le lieu de livraison (adresse et/ou **Partager ma position actuelle**),
   ajoutez une note, envoyez.
5. Onglet **Demandes** : suivez le statut. Une fois la demande acceptee, **Appeler** et **WhatsApp** apparaissent.
   Annulez si besoin, ou **Signalez** le livreur.

### Demandes ouvertes (client -> livreurs)
Le client appuie sur **Publier une course** (quartier et adresse exacte de chaque etape, note). Les livreurs qui peuvent
travailler la voient dans l'onglet **Clients** (quartiers et distance seulement) et font chacun **une offre**. Le client
negocie et conclut avec le livreur de son choix : la course devient une livraison acceptee, avec les numeros et l'adresse
exacte. Le client peut la **Cloturer** tant qu'aucun accord n'est conclu ; elle disparait aussi pour les livreurs apres 72 h.

### Livreur
1. Connexion Google, telephone, role **Livreur**. L'essai gratuit de 2 mois demarre automatiquement.
2. **Accueil** : renseignez votre ville, puis **Me mettre en ligne** (la position GPS est enregistree).
   Actualisez **Ma position** quand vous changez de quartier.
3. Onglet **Demandes** : **Accepter** (avec le prix si vous etes « a la livraison ») ou **Refuser**, puis **Marquer comme terminee**
   (saisir le montant). Apres acceptation : Appeler, WhatsApp, Message et l'itineraire Google Maps.
4. **Ma formule** : choisir mensuelle ou a la livraison, suivre son solde, declarer un paiement (reference BaridiMob / CCP).
   Sans formule valide (ou bloque a 1 000 DA), le livreur est retire de la liste des clients.

### Bouton retour
Sur l'ecran de connexion et sur les tableaux de bord, le bouton retour demande confirmation avant de quitter. Depuis un autre onglet, il ramene d'abord au premier.

### Administrateur
Menu du compte (photo en haut a droite) > **Administration** :
- **Livreurs** : statut, formule, solde, date de fin, menu pour prolonger de 30 jours, suspendre / lever la suspension, desactiver, appeler.
- **Paiements** : declarations (mois ou solde, avec le montant). **Valider** rembourse d'abord le solde, puis ajoute 30 jours
  pour un paiement mensuel. Verifiez la reference dans votre BaridiMob / CCP avant de valider.
- **Verifications** : pieces d'identite en attente (voir, valider, refuser).
- **Suspects** : livreurs au comportement anormal (voir section 6 septies).
- **Chiffre d'affaires** : total et classement des livreurs par periode.
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

- **Notifications push** : reservees aux livreurs et necessitent le forfait Firebase Blaze (voir section 6 quinquies).
- **Paiement** : la validation est manuelle (l'admin verifie le paiement puis valide). Une integration de paiement en ligne n'est pas incluse.
- **Hors application** : un client et un livreur qui se connaissent peuvent s'arranger sans l'application apres une premiere livraison.
- **Position du livreur** : elle est enregistree a l'activation et lors de la mise a jour manuelle (pas de suivi en temps reel).
- **Distance** : calculee en ligne droite (pas la distance routiere).
- **Test sur emulateur** : le GPS de l'emulateur est fixe ; definissez une position dans Extended controls > Location.

## 10. Depannage

| Probleme | Solution |
|---|---|
| `ApiException: 10` a la connexion Google | SHA-1 manquante dans Firebase (section 4, etape 2) |
| `permission-denied` | Regles Firestore non publiees ou ancienne version (section 4, etape 4) |
| « Accepter » ne fait rien / erreur | Cloud Functions non deployees ou region differente (`REGION` dans `functions/index.js` = `functionsRegion` dans `app_config.dart`) |
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
  features/    auth, client, driver, drivers, requests, chat, subscription, billing, reports, admin
  widgets/     composants partages
  l10n/        traductions francais / arabe (fichiers .arb)
assets/branding/   logo et identite visuelle
firestore.rules    regles de securite a publier
functions/         Cloud Functions : notifications push, facturation (billing.js = regles de prix, testees)
functions/         Cloud Functions (notifications push)
PUBLIER_UNE_VERSION.md   tutoriel de publication d'une nouvelle version
```
