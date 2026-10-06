# Wassaly --- وصّلي

> **Application mobile de mise en relation entre clients et livreurs de
> proximité en Algérie.**

Wassaly est une application Flutter pensée pour démarrer avec un **MVP
très léger et peu coûteux**, dont l'objectif est de permettre à un
client de trouver rapidement un livreur disponible à proximité, de le
contacter et, à partir de la V0.1, de lui transmettre une demande de
livraison avec un **lieu de récupération** et un **lieu de livraison**.

L'objectif initial n'est pas de construire immédiatement une plateforme
logistique complexe. Il est de lancer une première version
fonctionnelle, de la tester avec de vrais utilisateurs, puis de
réinvestir les premiers revenus dans l'évolution de l'application.

------------------------------------------------------------------------

## 1. Vision du projet

### Objectif initial

Le premier objectif de Wassaly est :

> **0 DA → MVP → utilisateurs → abonnements → revenus → amélioration**

Le succès de la première version sera mesuré par son utilisation réelle
:

-   5 à 10 livreurs pilotes ;
-   20 à 50 premiers clients ;
-   premières livraisons réalisées avec l'application ;
-   premiers livreurs prêts à payer **1 000 DA/mois** après leur période
    gratuite.

La validation terrain est plus importante qu'une application
parfaitement complète.

------------------------------------------------------------------------

# 2. Proposition de valeur

### Pour le client

Wassaly permet de :

-   trouver des livreurs disponibles à proximité ;
-   voir les livreurs triés par distance ;
-   consulter leur profil ;
-   les appeler ;
-   les contacter via WhatsApp ;
-   leur envoyer un message dans Wassaly ;
-   transmettre un lieu de récupération ;
-   transmettre un lieu de livraison ;
-   partager directement une position GPS ;
-   permettre au livreur d'ouvrir l'itinéraire dans Google Maps.

### Pour le livreur

Wassaly permet de :

-   être visible auprès des clients à proximité ;
-   activer/désactiver sa disponibilité ;
-   recevoir des demandes ;
-   communiquer avec les clients ;
-   accéder rapidement aux lieux de récupération et de livraison ;
-   utiliser Google Maps pour la navigation ;
-   bénéficier de **2 mois gratuits** ;
-   puis souscrire à un abonnement de **1 000 DA/mois**.

------------------------------------------------------------------------

# 3. Identité de marque

## Nom

**Wassaly --- وصّلي**

Le nom doit être utilisé de manière cohérente dans l'application, les
supports marketing et les communications.

## Logo

Le logo associe :

-   un **pin de localisation bleu** ;
-   un élément **orange évoquant la vitesse / le déplacement** ;
-   un **colis** au centre ;
-   le nom arabe **وصّلي** ;
-   le nom latin **Wassaly**.

Le logo représente directement les trois idées principales du produit :

**localisation + colis + livraison.**

### Fichiers recommandés

``` text
assets/
└── branding/
    ├── logo/
    │   ├── wassaly_logo.png
    │   ├── wassaly_logo_dark.png
    │   └── wassaly_icon.png
    └── colors/
        └── README.md
```

------------------------------------------------------------------------

# 4. Charte graphique

## 4.1 Couleurs principales

  Rôle                    Couleur          Hex
  ----------------------- ---------------- -----------
  Bleu principal          Bleu Wassaly     `#0D47A1`
  Orange principal        Orange Wassaly   `#FF7A00`
  État actif              Vert             `#22C55E`
  État inactif / erreur   Rouge            `#EF4444`

### Bleu `#0D47A1`

Utilisation :

-   boutons principaux ;
-   éléments de navigation ;
-   titres importants ;
-   liens ;
-   éléments du logo ;
-   états sélectionnés.

### Orange `#FF7A00`

Utilisation :

-   accent visuel ;
-   appels à l'action secondaires ;
-   icônes de localisation/livraison ;
-   éléments liés au mouvement ;
-   détails du logo.

Le bleu représente la confiance et la stabilité.

L'orange apporte l'énergie, la rapidité et la livraison.

------------------------------------------------------------------------

# 5. Mode clair --- Light Mode

Le mode clair est destiné à être le mode confortable par défaut lorsque
le système de l'utilisateur est configuré en clair.

## Palette

  Élément            Hex
  ------------------ -----------
  Fond principal     `#F8FAFC`
  Surface / carte    `#FFFFFF`
  Texte principal    `#0F172A`
  Texte secondaire   `#64748B`
  Bleu principal     `#0D47A1`
  Orange principal   `#FF7A00`
  Actif              `#22C55E`
  Inactif / erreur   `#EF4444`
  Bordure            `#E2E8F0`

### Exemple

``` text
┌─────────────────────────────────┐
│  Wassaly                         │
│                                 │
│  Bonjour 👋                     │
│  Livreurs disponibles           │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 🛵 Ahmed                  │  │
│  │ 🟢 Disponible             │  │
│  │ 📍 0,7 km                 │  │
│  │                           │  │
│  │ [ Appeler ] [ Message ]   │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

Le mode clair doit rester :

-   lumineux ;
-   simple ;
-   lisible ;
-   peu chargé ;
-   orienté vers l'action.

------------------------------------------------------------------------

# 6. Mode sombre --- Dark Mode

Le mode sombre doit être **adaptatif**.

L'application ne doit pas avoir une deuxième identité graphique
indépendante. Le logo, le bleu et l'orange restent les mêmes ; seuls les
fonds, surfaces et textes changent.

## Palette

  Élément            Hex
  ------------------ -----------
  Fond principal     `#0F172A`
  Surface / carte    `#1E293B`
  Texte principal    `#F8FAFC`
  Texte secondaire   `#CBD5E1`
  Bleu principal     `#0D47A1`
  Orange principal   `#FF7A00`
  Actif              `#22C55E`
  Inactif / erreur   `#EF4444`
  Bordure            `#334155`

### Principes

Le mode sombre doit :

-   réduire la luminosité des surfaces ;
-   conserver un contraste élevé ;
-   conserver le bleu/orange de la marque ;
-   conserver la même hiérarchie visuelle ;
-   ne pas simplement inverser toutes les couleurs.

------------------------------------------------------------------------

# 7. Adaptation automatique du thème

Flutter doit utiliser le thème du système :

``` dart
themeMode: ThemeMode.system
```

Avec deux thèmes :

``` text
ThemeData lightTheme
ThemeData darkTheme
```

Le comportement attendu :

``` text
Téléphone en mode clair
        ↓
Wassaly Light

Téléphone en mode sombre
        ↓
Wassaly Dark
```

L'application pourra éventuellement proposer plus tard :

``` text
☀️ Clair
🌙 Sombre
⚙️ Système
```

Mais pour le MVP, **Système** est suffisant.

------------------------------------------------------------------------

# 8. Langues

Wassaly V0 supporte deux langues :

-   🇫🇷 **Français**
-   🇩🇿 **Arabe**

L'interface doit être pensée dès le départ pour supporter le changement
de langue.

## Structure

``` text
lib/
└── l10n/
    ├── fr.json
    └── ar.json
```

## Français

``` json
{
  "login": "Connexion",
  "register": "Inscription",
  "active": "Actif",
  "inactive": "Inactif",
  "drivers_nearby": "Livreurs à proximité"
}
```

## Arabe

``` json
{
  "login": "تسجيل الدخول",
  "register": "التسجيل",
  "active": "متاح",
  "inactive": "غير متاح",
  "drivers_nearby": "الناقلون القريبون"
}
```

### Important

L'arabe doit être correctement géré en **RTL (Right-To-Left)**.

Il faut donc tester :

-   alignement ;
-   boutons ;
-   icônes ;
-   formulaires ;
-   navigation ;
-   cartes de livraison ;
-   messages ;
-   textes longs.

------------------------------------------------------------------------

# 9. Technologie

## Application mobile

**Flutter**

Pourquoi :

-   une base de code Android/iOS ;
-   développement rapide ;
-   adapté au MVP ;
-   bonne gestion du responsive ;
-   support natif de la localisation, appels et deep links.

## Backend

**Firebase**

Utilisations prévues :

-   authentification ;
-   base de données ;
-   notifications ;
-   stockage éventuel ;
-   services backend nécessaires au MVP.

------------------------------------------------------------------------

# 10. Architecture Flutter

Architecture volontairement simple.

``` text
wassaly/
│
├── android/
├── ios/
├── assets/
│   ├── branding/
│   │   └── logo/
│   └── images/
│
├── lib/
│   ├── main.dart
│   │
│   ├── core/
│   │   ├── theme/
│   │   ├── constants/
│   │   ├── utils/
│   │   └── routes/
│   │
│   ├── models/
│   │   ├── user.dart
│   │   ├── driver.dart
│   │   ├── location.dart
│   │   ├── delivery_request.dart
│   │   └── message.dart
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── location_service.dart
│   │   ├── notification_service.dart
│   │   ├── maps_service.dart
│   │   └── communication_service.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   ├── client/
│   │   ├── driver/
│   │   ├── delivery/
│   │   └── admin/
│   │
│   ├── widgets/
│   │
│   └── l10n/
│       ├── fr.json
│       └── ar.json
│
└── pubspec.yaml
```

L'architecture doit rester simple. Il ne faut pas introduire
prématurément une architecture excessivement complexe.

------------------------------------------------------------------------

# 11. Authentification

## Écran de bienvenue

``` text
          WASSALY
           وصّلي

       [ Français ]
       [ العربية ]

 [ Continuer avec Google ]

        Se connecter
```

## Inscription

Après Google :

``` text
Bienvenue 👋

Numéro de téléphone

[ 0550 XX XX XX ]

[ Continuer ]
```

### V0

Le numéro de téléphone est enregistré **sans OTP**.

L'OTP sera ajouté dans une version ultérieure lorsque le produit
générera suffisamment de revenus pour justifier cette infrastructure.

------------------------------------------------------------------------

# 12. Choix du rôle

Après l'inscription :

``` text
Quel est votre rôle ?

┌──────────────────┐
│   👤 Client      │
└──────────────────┘

┌──────────────────┐
│   🛵 Livreur     │
└──────────────────┘
```

Deux rôles sont nécessaires :

``` text
client
driver
```

Le rôle est enregistré dans le profil utilisateur.

------------------------------------------------------------------------

# 13. Base de données

## Users

``` text
users
│
└── userId
    ├── name
    ├── email
    ├── phone
    ├── role
    ├── photo
    └── createdAt
```

## Drivers

``` text
drivers
│
└── userId
    ├── active
    ├── latitude
    ├── longitude
    ├── city
    ├── trialStart
    ├── subscriptionStatus
    └── subscriptionEnd
```

## Conversations

``` text
conversations
│
└── conversationId
    ├── clientId
    ├── driverId
    └── updatedAt
```

## Messages

``` text
messages
│
└── messageId
    ├── conversationId
    ├── senderId
    ├── text
    ├── createdAt
    └── read
```

------------------------------------------------------------------------

# 14. Nouvelle fonctionnalité V0.1 --- Demande de livraison

La V0.1 ajoute une fonctionnalité importante sans transformer Wassaly en
plateforme logistique complète.

## Principe

Le client peut envoyer une demande contenant :

``` text
📍 Lieu de récupération
🏠 Lieu de livraison
📝 Note facultative
```

Exemple :

``` text
📦 Demande de livraison

📍 Récupération
Hai Akid Lotfi, Oran

🏠 Livraison
Es Senia, Oran

📝 Note
Colis fragile

[ Envoyer au livreur ]
```

------------------------------------------------------------------------

# 15. Deux positions GPS

Il faut prévoir dès maintenant **deux lieux distincts**.

## Pickup

``` text
pickupLocation
```

Lieu où le livreur récupère la commande.

## Delivery

``` text
deliveryLocation
```

Lieu où le livreur dépose la commande.

Chaque position doit pouvoir contenir :

``` text
latitude
longitude
address
```

------------------------------------------------------------------------

# 16. Saisie d'une position

L'utilisateur doit pouvoir choisir entre :

### Option 1 --- Adresse

``` text
📍 Lieu de récupération

[ Écrire l'adresse ]
```

### Option 2 --- Position GPS

``` text
📍 Lieu de récupération

[ Partager ma position ]
```

Même logique pour le lieu de livraison.

Le GPS est préférable lorsque l'adresse est imprécise.

------------------------------------------------------------------------

# 17. Modèle DeliveryRequest

``` text
deliveryRequests
│
└── requestId
    ├── clientId
    ├── driverId
    │
    ├── pickupLocation
    │   ├── latitude
    │   ├── longitude
    │   └── address
    │
    ├── deliveryLocation
    │   ├── latitude
    │   ├── longitude
    │   └── address
    │
    ├── note
    ├── status
    ├── createdAt
    └── updatedAt
```

## Statuts

``` text
pending
accepted
rejected
completed
cancelled
```

------------------------------------------------------------------------

# 18. Google Maps

## Principe

Wassaly ne doit pas intégrer une carte Google Maps dans le MVP.

L'application stocke simplement les coordonnées GPS et ouvre Google Maps
lorsque le livreur demande un itinéraire.

Exemple :

``` text
https://www.google.com/maps/dir/?api=1&destination=LATITUDE,LONGITUDE
```

Le système devient :

``` text
Wassaly
   ↓
Coordonnées GPS
   ↓
Bouton "Ouvrir Google Maps"
   ↓
Google Maps
   ↓
Navigation
```

### Avantages

-   pas de Google Maps SDK dans V0 ;
-   pas de carte embarquée ;
-   pas de système de navigation à développer ;
-   développement plus rapide ;
-   coûts et complexité réduits.

------------------------------------------------------------------------

# 19. Écran côté livreur

Exemple :

``` text
👤 Client : Ahmed

📦 Nouvelle demande

📍 Récupération
Akid Lotfi, Oran

[ 🗺️ Ouvrir Google Maps ]

🏠 Livraison
Es Senia, Oran

[ 🗺️ Ouvrir Google Maps ]

[ 📞 Appeler ]
[ 💬 Message ]

[ 🟢 Accepter ]
[ ❌ Refuser ]
```

Après acceptation :

``` text
📦 Livraison acceptée

📍 Récupération
[ 🗺️ Itinéraire ]

🏠 Livraison
[ 🗺️ Itinéraire ]

[ Marquer comme terminée ]
```

------------------------------------------------------------------------

# 20. Ce qui n'est PAS prévu dans V0/V0.1

Pour conserver un MVP léger :

-   pas de Google Maps intégré ;
-   pas de navigation intégrée ;
-   pas de tracking GPS temps réel ;
-   pas d'ETA automatique ;
-   pas de calcul du meilleur itinéraire ;
-   pas de paiement intégré ;
-   pas d'OTP ;
-   pas de Play Store au lancement ;
-   pas de système e-commerce complet ;
-   pas de système complexe de notation ;
-   pas de preuve de livraison avancée ;
-   pas de signature électronique ;
-   pas de VoIP ;
-   pas d'IA.

------------------------------------------------------------------------

# 21. Dashboard Client

Le client arrive directement sur son tableau principal.

``` text
Bonjour 👋

Livreurs disponibles
à proximité

────────────────────

🛵 Ahmed
🟢 Disponible
📍 0,7 km

[ Appeler ] [ Message ]
[ WhatsApp ]

────────────────────

🛵 Mohamed
🟢 Disponible
📍 1,3 km

[ Appeler ] [ Message ]
[ WhatsApp ]
```

Le système récupère :

1.  position du client ;
2.  livreurs actifs ;
3.  distance ;
4.  tri par distance.

------------------------------------------------------------------------

# 22. Localisation et distance

Wassaly utilise :

``` text
latitude
longitude
```

Exemple :

``` text
Client
36.7372, 3.0863

Livreur
36.7410, 3.0890
```

L'application calcule une distance approximative :

``` text
Livreur A → 0,8 km
Livreur B → 1,4 km
Livreur C → 2,2 km
```

La liste est ensuite triée par distance.

### Important

Cette distance sert principalement à **classer les livreurs**.

La navigation réelle est laissée à Google Maps.

------------------------------------------------------------------------

# 23. Dashboard Livreur

L'écran doit être extrêmement simple.

``` text
Bonjour Ahmed 👋

Votre disponibilité

        🟢 ACTIF

     [ DÉSACTIVER ]

──────────────────

📍 Oran

📩 Messages       4

📦 Demandes       2

Abonnement
2 mois gratuits

Expire le :
XX/XX/2027
```

Lorsque le livreur désactive son statut :

``` text
⚪ INACTIF

[ ACTIVER ]
```

Un livreur inactif n'est plus proposé aux clients.

------------------------------------------------------------------------

# 24. Communication

Wassaly V0 propose plusieurs moyens de communication.

## Appel

``` text
📞 Appeler
```

Flutter ouvre le système téléphonique.

## WhatsApp

``` text
🟢 WhatsApp
```

L'application ouvre WhatsApp avec le numéro du contact.

## Messagerie Wassaly

Chat simple :

``` text
Ahmed

Bonjour, vous êtes disponible ?

              Oui, je suis disponible.
```

V0 n'a pas besoin de :

-   fichiers ;
-   photos ;
-   vidéos ;
-   positions envoyées dans le chat ;
-   messages vocaux.

------------------------------------------------------------------------

# 25. Notifications

Les notifications sont utilisées pour les événements importants.

Exemples :

``` text
🔔 Nouveau message

Salah vous a envoyé un message.
```

Et avec V0.1 :

``` text
🔔 Nouvelle demande

Ahmed vous a envoyé une demande de livraison.
```

``` text
🔔 Demande acceptée

Votre demande a été acceptée par Ahmed.
```

``` text
🔔 Livraison terminée

La livraison a été marquée comme terminée.
```

Les appels restent gérés par le système téléphonique.

------------------------------------------------------------------------

# 26. Abonnement livreur

## Période gratuite

Chaque nouveau livreur reçoit :

**2 mois gratuits**

À l'inscription :

``` text
trialStart = date actuelle
```

Puis :

``` text
trialEnd = trialStart + 2 mois
```

Pendant la période :

``` text
subscriptionStatus = trial
```

Après expiration :

``` text
subscriptionStatus = expired
active = false
```

Le livreur reçoit :

> Votre période gratuite est terminée. Abonnez-vous pour continuer à
> recevoir des clients.

------------------------------------------------------------------------

# 27. Prix

Après la période gratuite :

**1 000 DA / mois**

Le paiement intégré n'est pas développé au départ.

Processus initial :

``` text
Livreur
   ↓
2 mois gratuits
   ↓
Expiration
   ↓
Renouveler mon abonnement
   ↓
Instructions de paiement
   ↓
Paiement
   ↓
Preuve envoyée
   ↓
Admin valide
   ↓
+30 jours
```

------------------------------------------------------------------------

# 28. Administration

Le panneau administrateur doit rester petit.

## Utilisateurs

``` text
Clients
Livreurs
```

## Livreurs

``` text
Ahmed
🟢 Actif
Trial

Mohamed
⚪ Inactif
Abonnement expiré
```

## Abonnements

``` text
Ahmed
Trial
Expire : XX/XX/XXXX

Mohamed
Payé
Expire : XX/XX/XXXX
```

## Actions

``` text
[ Désactiver ]
[ Activer ]
[ Prolonger 30 jours ]
[ Suspendre ]
```

Pas besoin d'un énorme back-office pour le MVP.

------------------------------------------------------------------------

# 29. Distribution

Au lancement, Android peut être distribué sans Play Store.

Build :

``` bash
flutter build apk --release
```

Résultat :

``` text
app-release.apk
```

Une page de téléchargement pourra être utilisée :

``` text
wassaly.com/app
```

Avec :

``` text
Télécharger Wassaly
        ↓
       APK
        ↓
   Installation
```

Un QR Code pourra également être utilisé sur :

-   affiches ;
-   flyers ;
-   magasins ;
-   motos ;
-   Facebook ;
-   Instagram ;
-   WhatsApp.

### Attention

Android peut afficher un avertissement lors de l'installation d'une
application provenant d'une source externe à Google Play. Le processus
d'installation doit donc être expliqué aux premiers utilisateurs.

------------------------------------------------------------------------

# 30. Plan de réalisation

## Sprint 1 --- Fondations

### Objectif

Créer la base technique et l'identité visuelle.

### Tâches

-   créer le projet Flutter ;
-   intégrer le logo Wassaly ;
-   créer le thème clair ;
-   créer le thème sombre ;
-   configurer `ThemeMode.system` ;
-   définir les couleurs ;
-   définir la typographie ;
-   configurer le responsive ;
-   préparer français/arabe ;
-   préparer RTL ;
-   mettre en place la navigation.

### Résultat attendu

Une application Flutter navigable avec l'identité Wassaly complète.

------------------------------------------------------------------------

# 31. Sprint 2 --- Authentification

### Tâches

-   connexion Google ;
-   inscription ;
-   numéro de téléphone sans OTP ;
-   choix Client/Livreur ;
-   connexion Firebase ;
-   création du profil utilisateur ;
-   persistance de session.

### Résultat attendu

Un utilisateur peut créer son compte et accéder à son espace.

------------------------------------------------------------------------

# 32. Sprint 3 --- Client

### Tâches

-   écran principal ;
-   demande de permission GPS ;
-   récupération de la position ;
-   recherche des livreurs ;
-   calcul de distance ;
-   tri par distance ;
-   affichage du profil livreur ;
-   appel ;
-   WhatsApp ;
-   messagerie.

### Résultat attendu

Un client peut trouver et contacter un livreur proche.

------------------------------------------------------------------------

# 33. Sprint 4 --- Livreur

### Tâches

-   dashboard ;
-   statut Actif/Inactif ;
-   localisation ;
-   profil ;
-   abonnement ;
-   trial de 2 mois ;
-   affichage des demandes ;
-   acceptation/refus.

### Résultat attendu

Un livreur peut être visible, recevoir et gérer une demande.

------------------------------------------------------------------------

# 34. Sprint 5 --- Demande de livraison V0.1

### Tâches

-   modèle `DeliveryRequest` ;
-   pickup ;
-   delivery ;
-   adresse ;
-   latitude/longitude ;
-   partage de position ;
-   note facultative ;
-   statuts de demande ;
-   notification de demande ;
-   demande acceptée/refusée ;
-   livraison terminée.

### Résultat attendu

Le client peut transmettre une vraie demande de livraison structurée.

------------------------------------------------------------------------

# 35. Sprint 6 --- Google Maps & communication

### Tâches

-   générer les URLs Google Maps ;
-   bouton itinéraire Pickup ;
-   bouton itinéraire Delivery ;
-   appel ;
-   WhatsApp ;
-   chat ;
-   notifications.

### Résultat attendu

Le livreur peut passer de Wassaly à Google Maps pour effectuer sa
livraison.

------------------------------------------------------------------------

# 36. Sprint 7 --- Administration

### Tâches

-   liste utilisateurs ;
-   liste livreurs ;
-   activation/désactivation ;
-   gestion des abonnements ;
-   prolongation manuelle ;
-   suspension ;
-   consultation des demandes.

### Résultat attendu

L'administrateur peut gérer le MVP sans intervention dans Firebase à
chaque opération.

------------------------------------------------------------------------

# 37. Sprint 8 --- APK

### Tâches

-   build release ;
-   tests Android ;
-   test sur plusieurs téléphones ;
-   optimisation des performances ;
-   hébergement APK ;
-   QR Code ;
-   page de téléchargement.

### Résultat attendu

Une version installable de Wassaly.

------------------------------------------------------------------------

# 38. Sprint 9 --- Test terrain

Commencer petit :

``` text
5 livreurs
   ↓
10 livreurs
   ↓
20 livreurs
   ↓
Premiers abonnements
```

Côté clients :

``` text
20–50 utilisateurs
```

## Scénario réel

``` text
Client
  ↓
ouvre Wassaly
  ↓
autorise la localisation
  ↓
voit les livreurs
  ↓
choisit un livreur
  ↓
indique Pickup
  ↓
indique Delivery
  ↓
envoie la demande
  ↓
livreur accepte
  ↓
livreur ouvre Google Maps
  ↓
récupération
  ↓
livraison
  ↓
livraison terminée
```

------------------------------------------------------------------------

# 39. Tests à réaliser

Avant le lancement, vérifier :

### Authentification

-   connexion Google ;
-   création de compte ;
-   changement de rôle ;
-   persistance de session.

### Localisation

-   permission GPS ;
-   position correcte ;
-   position refusée ;
-   calcul de distance ;
-   livreurs actifs uniquement.

### Livraison

-   création de demande ;
-   pickup ;
-   delivery ;
-   adresse ;
-   GPS ;
-   acceptation ;
-   refus ;
-   annulation ;
-   livraison terminée.

### Communication

-   appel ;
-   WhatsApp ;
-   chat ;
-   notifications.

### Thèmes

-   Light ;
-   Dark ;
-   changement automatique du système ;
-   contraste ;
-   logo sur fond clair ;
-   logo sur fond sombre.

### Langues

-   français ;
-   arabe ;
-   RTL ;
-   textes longs ;
-   boutons ;
-   formulaires.

------------------------------------------------------------------------

# 40. Critères de réussite du MVP

Le MVP peut être considéré comme validé si :

-   les utilisateurs comprennent l'application sans explication
    importante ;
-   les clients trouvent rapidement un livreur ;
-   les livreurs restent actifs ;
-   les positions sont suffisamment précises ;
-   les demandes sont correctement reçues ;
-   Google Maps permet au livreur d'atteindre les lieux ;
-   les notifications fonctionnent ;
-   les utilisateurs reviennent utiliser Wassaly ;
-   des livreurs acceptent de payer 1 000 DA/mois.

------------------------------------------------------------------------

# 41. Évolutions après validation

Une fois les premiers revenus obtenus, les fonctionnalités suivantes
peuvent être développées.

## Wassaly V1.1+

-   paiement automatique ;
-   OTP ;
-   Google Play ;
-   meilleure sécurité ;
-   système de notation ;
-   historique des livraisons ;
-   suivi de livraison ;
-   tracking GPS ;
-   demandes de livraison avancées ;
-   preuve de livraison ;
-   système de commission ;
-   API pour commerçants ;
-   tableau de bord avancé.

------------------------------------------------------------------------

# 42. Évolution vers une vraie plateforme logistique

À terme :

``` text
Client
   │
   ▼
Demande
   │
   ▼
Wassaly
   │
   ├── Recherche livreur
   │
   ├── Attribution
   │
   ├── Pickup
   │
   ├── Livraison
   │
   ├── Tracking
   │
   └── Confirmation
        │
        ▼
     Historique
```

Mais cette architecture complète ne doit pas être développée avant
d'avoir validé le besoin réel.

------------------------------------------------------------------------

# 43. Ordre exact recommandé

``` text
1. Branding
   ↓
2. Flutter
   ↓
3. Light / Dark
   ↓
4. Français / Arabe
   ↓
5. Firebase
   ↓
6. Authentification
   ↓
7. Profil Client / Livreur
   ↓
8. Localisation
   ↓
9. Liste des livreurs
   ↓
10. Appel / WhatsApp / Chat
   ↓
11. Statut Actif/Inactif
   ↓
12. Abonnement / Trial
   ↓
13. DeliveryRequest
   ↓
14. Pickup + Delivery
   ↓
15. Google Maps
   ↓
16. Notifications
   ↓
17. Admin
   ↓
18. APK
   ↓
19. Test terrain
   ↓
20. Premiers abonnements
```

------------------------------------------------------------------------

# 44. Règle principale du projet

Wassaly doit rester **simple au début**.

Ne pas chercher à construire immédiatement :

> une application de livraison comparable aux grandes plateformes.

Construire d'abord :

> **une application qui permet réellement à un client de trouver un
> livreur, lui transmettre une demande avec deux positions et permettre
> au livreur de réaliser la livraison.**

La complexité doit être ajoutée uniquement lorsqu'elle répond à un
problème réel rencontré par les utilisateurs.

------------------------------------------------------------------------

# 45. Résumé

### Wassaly V0

``` text
👤 Client
   ↓
📍 Livreurs proches
   ↓
📞 Appel / WhatsApp / Chat
```

### Wassaly V0.1

``` text
👤 Client
   ↓
🛵 Choisit un livreur
   ↓
📍 Pickup
   ↓
🏠 Delivery
   ↓
📦 Demande
   ↓
🛵 Livreur accepte
   ↓
🗺️ Google Maps
   ↓
✅ Livraison terminée
```

### Wassaly V1+

``` text
📦 Demande
   ↓
🛵 Attribution
   ↓
📍 Pickup
   ↓
🚚 Tracking
   ↓
🏠 Delivery
   ↓
✅ Preuve
   ↓
⭐ Notation
   ↓
💳 Paiement
```

------------------------------------------------------------------------

## Principe financier

> **0 DA → MVP → utilisateurs → abonnements → revenus → amélioration**

Le premier objectif n'est donc pas de créer une application parfaite.

Le premier objectif est de créer une application **suffisamment
fonctionnelle pour que de vrais clients l'utilisent, que 10 à 20
livreurs l'adoptent et que certains acceptent de payer 1 000 DA/mois.**
