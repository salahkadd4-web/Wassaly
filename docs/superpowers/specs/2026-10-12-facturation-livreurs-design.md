# Facturation des livreurs et anti-fraude — Design

Date : 2026-10-12 · Implemente sur `main` (non commite)

> **Mise a jour du 2026-10-15** : l'acceptation directe (`acceptDelivery`) et le « Je prends » (`takeOpenRequest`)
> ont ete remplaces par une **negociation du prix** (100 a 300 DA par pas de 10, chacun a son tour) conclue par
> `agreeDelivery` / `agreeOffer`, avec offres multiples sur les demandes ouvertes et adresse exacte privee jusqu'a
> l'accord. Le debit de 50 DA a lieu a l'accord. Voir GUIDE.md, section 6 octies.
>
> **Mise a jour du 2026-10-16** : sans carte bancaire (offre Blaze impossible), le projet tourne sur l'offre gratuite
> Spark, SANS Cloud Functions. Accords, debits et notes sont ecrits par l'application dans une ecriture groupee et
> verifies par `firestore.rules` ; remboursements par l'admin ; compteurs anti-fraude recalcules par l'admin ;
> pas de notification push. Les sections de ce document qui decrivent des Cloud Functions de facturation sont
> remplacees par GUIDE.md, section 6 septies.

## 1. Objectif

Après 2 mois d'essai gratuit, le livreur choisit entre :

- **Mensuel** : 1 000 DA / 30 jours (existe déjà, paiement manuel validé par l'admin) ;
- **À la livraison** : 50 DA par livraison acceptée, payés après coup (dette plafonnée à 1 000 DA).

Il faut **compter de façon fiable** les livraisons et **limiter la fraude**. Le dépôt GitHub est public
(code source lisible) : toute règle d'argent est appliquée côté serveur (Cloud Functions + règles
Firestore), jamais seulement dans l'application.

### Décisions validées

| Sujet | Décision |
|---|---|
| Moment du débit | À l'**acceptation** (demande directe) ou au **« Je prends »** (demande ouverte) |
| Demandes ouvertes | « Je prends » **exclusif**, pour tous les livreurs ; la demande devient une livraison suivie |
| Règlement | **Dette**, blocage à **1 000 DA** (20 livraisons) jusqu'au paiement validé par l'admin |
| Plafond mensuel | **Aucun** : toujours 50 DA par livraison |
| Changement de formule | Libre, effectif **à la fin de la période en cours** |
| Numéros | Cachés **des deux côtés** jusqu'à l'acceptation (vraie protection, données déplacées) |
| Anti-fraude | Remboursements limités, tableau « Suspects », signalement client, numéros bloqués dans le chat |

Hors périmètre : paiement en ligne (CIB/Edahabia), notes/avis, plafond mensuel.

## 2. Constantes

Dupliquées dans `lib/core/constants/app_config.dart` et `functions/billing.js` :

| Nom | Valeur |
|---|---|
| `trialDays` | 60 (existe) |
| `subscriptionDays` | 30 (existe) |
| `monthlyPriceDa` | 1000 (existe) |
| `perDeliveryPriceDa` | 50 |
| `debtLimitDa` | 1000 |
| `debtWarnDa` | 800 |
| `refundWindowHours` | 2 |
| `maxRefundsPerMonth` | 3 |

## 3. Modèle de données

### `drivers/{uid}` (public, lisible par tout utilisateur connecté)

- `subscriptionStatus` : `trial | paid | per_delivery | expired | suspended` (ajout de `per_delivery`).
- `subscriptionEnd` : fin de l'essai ou du mois payé (ignoré en `per_delivery`).
- `plan` *(nouveau, optionnel)* : `monthly | per_delivery` = formule qui s'applique **après** la période en cours.
- `billingBlocked` *(nouveau, bool, écrit par le serveur/admin)* : dette ≥ 1 000 DA.
- `phone` : **supprimé** (le numéro reste dans `users/{uid}`, privé).

### `driverBilling/{uid}` (nouveau, privé : livreur + admin ; écrit par Functions et admin)

```
debt: int (DA)
refundMonth: "YYYY-MM", refundsThisMonth: int
stats: { accepted, completed, cancelledAfterAccept, conversations, reports } (int)
blockedSince: Timestamp | null
updatedAt
```

Sous-collection `ledger/{id}` : `{ type: charge|refund|payment, amount, requestId?, claimId?, createdAt }`.
Id déterministe `charge_{requestId}` / `refund_{requestId}` → **jamais de double débit/remboursement**.

### `deliveryRequests/{id}`

- `clientPhone` **supprimé** du document (plus écrit par le client).
- Nouveaux champs écrits par le serveur : `acceptedAt`, `charged` (0 ou 50), `source` (`direct|open`), `openRequestId?`.
- Sous-document `deliveryRequests/{id}/private/contact` : `{ clientPhone, driverPhone }`, écrit par la
  Function à l'acceptation, lisible par les deux participants **seulement si** la demande est
  `accepted` ou `completed`.

### `openRequests/{id}`

- `clientPhone` **supprimé**.
- Nouveau statut `taken` + champs `takenBy`, `takenByName`, `deliveryRequestId` (écrits par le serveur).

### `subscriptionRequests/{id}` (existe)

- Nouveaux champs : `kind` (`monthly | debt`), `amount` (DA, entier). Anciennes demandes sans `kind` = `monthly`.
- Montant proposé par l'app : `debt` → dette actuelle ; `monthly` → 1 000 + dette actuelle.

### `reports/{clientId}_{driverId}` (nouveau)

`{ clientId, driverId, reason: off_app|not_delivered|behavior|other, note (≤300), requestId?, createdAt }`.
Un seul signalement par couple client/livreur (id déterministe, création seule) → pas de spam.

## 4. Éligibilité d'un livreur (même définition partout)

Un livreur **peut travailler** (visible des clients, voit les demandes ouvertes, peut accepter) si
vérifié, non suspendu, et :

1. `status ∈ {trial, paid}` et `subscriptionEnd > maintenant` ; **ou**
2. `status = per_delivery` et `billingBlocked != true` ; **ou**
3. `status ∈ {trial, paid}`, `subscriptionEnd ≤ maintenant`, `plan = per_delivery` et `billingBlocked != true`
   (bascule « paresseuse » avant le passage du job quotidien).

**Mode facturé à la livraison** = cas 2 ou 3. En cas 1 (essai ou mois payé en cours) : pas de débit.

Implémentée dans : `DriverProfile` (Dart), `isSubscribedDriver()` (règles), `billing.js` (Functions),
`subscribedDriverIds()` (notifications push).

## 5. Cloud Functions (région `europe-west1`)

### Callable (appelées par l'app, utilisateur authentifié)

**`acceptDelivery({ requestId })`** — transaction :
1. demande existe, `driverId == auth.uid`, `status == pending` sinon `failed-precondition: not-pending` ;
2. livreur éligible sinon `not-eligible` ;
3. si mode à la livraison : si `debt ≥ 1000` → `debt-limit` ; sinon `debt += 50`, ledger `charge_{id}`,
   `billingBlocked = debt ≥ 1000` (+ `blockedSince`), bascule `status = per_delivery` si cas 3 ;
4. demande → `accepted`, `acceptedAt`, `charged`, `updatedAt` ;
5. écrit `private/contact` (téléphones lus dans `users/`) ; `stats.accepted += 1`.

**`takeOpenRequest({ openRequestId })`** — transaction : demande ouverte `open` sinon `already-taken` ;
mêmes contrôles et débit que ci-dessus ; crée une `deliveryRequests` `accepted` (`source: open`) ;
passe l'ouverte en `taken` (+ `takenBy`, `takenByName`, `deliveryRequestId`). Retourne `{ deliveryRequestId }`.

**`choosePlan({ plan })`** :
- suspendu → `not-eligible` ;
- essai / mois payé en cours → enregistre `plan` (effet à la fin) ;
- expiré (ou période finie) → `per_delivery` : `status = per_delivery` immédiatement ; `monthly` : `plan = monthly` (il doit payer) ;
- `per_delivery` → `monthly` : `plan = monthly`, reste facturé à la livraison jusqu'à validation du paiement « dette + 1 000 DA ».

### Triggers

- **`onDeliveryRequestUpdated`** :
  - `accepted → cancelled` : `stats.cancelledAfterAccept += 1` ; **remboursement** si `charged > 0`,
    annulation ≤ 2 h après `acceptedAt` et < 3 remboursements ce mois (compteur remis à zéro si
    `refundMonth` change) : `debt -= charged` (min 0), ledger `refund_{id}`, recalcul de `billingBlocked`.
  - `accepted → completed` : `stats.completed += 1`.
- **`onConversationCreated`** : `stats.conversations += 1` pour le livreur.
- **`onReportCreated`** : `stats.reports += 1` pour le livreur.
- **`onNewOpenRequest`** (existe) : la liste des destinataires utilise la nouvelle éligibilité.

### Planifiée

**`rolloverSubscriptions`** (tous les jours, 03:00 Africa/Algiers) : livreurs `trial|paid` dont
`subscriptionEnd ≤ maintenant` → `per_delivery` si `plan == per_delivery` (avec `billingBlocked` selon la
dette), sinon `expired`.

### Logique pure testée

`functions/billing.js` (sans Firebase) : `isEligible`, `isPerDeliveryMode`, `applyCharge`,
`refundDecision`, `rolloverStatus`, `monthKey`. Tests : `functions/billing.test.js` avec `node --test`.

## 6. Règles Firestore (changements)

- `isSubscribedDriver()` : nouvelle éligibilité (§4).
- `drivers` : création sans `phone`/`plan`/`billingBlocked` (liste de clés fermée) ; le livreur ne
  peut modifier que `active, latitude, longitude, lastLocationUpdate, city, name, photo`, et
  `active = true` seulement s'il est éligible. Admin : tout.
- `driverBilling/{uid}` (+ `ledger`) : lecture propriétaire/admin, écriture admin seulement.
- `deliveryRequests` : création sans `clientPhone` ; le livreur ne peut plus passer `pending → accepted`
  (seulement via `acceptDelivery`) ; il garde `pending → rejected` et `accepted → completed` ; le client
  garde l'annulation. `private/{doc}` : lecture participants si statut `accepted|completed`, écriture interdite.
- `openRequests` : création sans `clientPhone`.
- `conversations/*/messages` : refus si le texte contient un numéro algérien
  (`0`/`+213`/`00213` + `5-7` + 8 chiffres, séparateurs ` .-` et chiffres arabes `٠-٩` acceptés).
- `subscriptionRequests` : création avec `kind ∈ {monthly, debt}` et `amount` entier 1..100 000.
- `reports/{id}` : création par le client si `id == clientId_driverId`, motif valide, note ≤ 300, et
  conversation `clientId_driverId` existante ou `requestId` d'une demande entre eux ; lecture admin.

## 7. Application Flutter

### Commun
- Dépendance `cloud_functions` ; service `BillingFunctions` (région `europe-west1`) qui traduit les
  codes d'erreur (`debt-limit`, `not-eligible`, `not-pending`, `already-taken`) en messages localisés.
- `lib/core/utils/phone_guard.dart` : `containsPhoneNumber(text)` (même motif que les règles).
- Modèles : `DriverProfile` (sans `phone`, + `plan`, `billingBlocked`, nouvelle éligibilité),
  `DriverBilling` (+ stats), `LedgerEntry`, `SubscriptionClaim` (+ `kind`, `amount`), `OpenRequest`
  (+ `taken`), `DeliveryRequest` (sans `clientPhone`, + `acceptedAt`, `charged`), `RequestContact`.
- Provider `requestContactProvider(requestId)` (lit `private/contact`).
- Traductions FR + AR pour tous les nouveaux textes.

### Livreur
- **Abonnement** (écran refait) : statut et jours restants, formule actuelle et formule choisie pour la
  suite (sélecteur Mensuel 1 000 DA / 50 DA par livraison → `choosePlan`), jauge de dette X / 1 000 DA,
  boutons « Régler ma dette » et « Payer le mois » (référence BaridiMob → `subscriptionRequests`),
  historique des demandes de paiement et du ledger.
- **Bandeau** sur le tableau de bord : dette ≥ 800 DA (alerte) / bloqué (lien vers Abonnement) /
  essai bientôt fini sans formule choisie.
- **Accepter** une demande directe : confirmation « +50 DA à votre solde » en mode à la livraison, puis
  `acceptDelivery`. Le numéro et le chat du client n'apparaissent qu'après acceptation.
- **Demande ouverte** : plus de contact ; bouton « Je prends cette demande » (+ mention 50 DA si facturé)
  → `takeOpenRequest` → ouvre l'onglet des demandes.
- **Chat** : envoi refusé avec un message clair si le texte contient un numéro.

### Client
- Liste/fiche livreur : plus de téléphone ni WhatsApp ; « Envoyer une demande » et « Message » restent.
- Carte de demande acceptée/terminée : contacts du livreur (`private/contact`).
- Demande ouverte prise : « Prise par {nom} ».
- Bouton **« Signaler ce livreur »** (fiche livreur et carte de demande) : motif + note.

### Admin
- Liste des livreurs : formule, dette, bloqué.
- Paiements : type (mensuel / dette) et montant ; la validation applique le montant dans une
  transaction (dette d'abord ; si `monthly` : +30 jours, `status = paid`, `billingBlocked = false`) + ledger `payment`.
- Onglet **Suspects** : livreurs signalés par `suspicionReasons(billing)` (pure, testée) :
  - annulations après acceptation > 30 % (≥ 5 acceptées) ;
  - conversations / acceptées > 3 (≥ 5 conversations) ;
  - signalements ≥ 2 ;
  - bloqué pour dette depuis > 7 jours.
  Avec motifs, dette, signalements, bouton Suspendre.

## 8. Données existantes

L'APK n'a jamais été diffusé : seules des données de test existent. Script `tools/strip_public_phones.js`
(Admin SDK, comme `backfill_phones.js`) qui retire `phone` des `drivers` et `clientPhone` des
`deliveryRequests` / `openRequests`.

## 9. Tests

- `node --test` sur `functions/billing.test.js` (débit, blocage à 1 000, remboursement fenêtre/quota/mois, bascule).
- Tests Dart : éligibilité `DriverProfile`, `containsPhoneNumber`, `suspicionReasons`, montant des demandes de paiement.
- `flutter analyze`, `flutter test`.
- Checklist manuelle (2 téléphones ou émulateur + téléphone) dans `PUBLIER_UNE_VERSION.md`.

## 10. Déploiement et diffusion

1. `firebase deploy --only functions,firestore:rules` (Functions avant l'APK : l'ancienne app ne peut plus accepter).
2. `node tools/strip_public_phones.js`.
3. Build `1.2.0+3`, release GitHub `v1.2.0` avec `wassaly.apk` : le QR existant pointe automatiquement dessus.
4. Mise à jour de `PUBLIER_UNE_VERSION.md` (cas « jamais téléchargé » : écraser l'APK de la release est aussi possible).

## 11. Limites connues

- Un livreur et un client fidèles peuvent toujours s'arranger hors application après une première
  livraison : on le rend visible (ratios, signalements), on ne peut pas l'empêcher.
- Le filtre de numéros du chat se contourne (numéro écrit en lettres) : les signalements prennent le relais.
- Un livreur peut accepter en mode essai/mensuel sans débit : seul le mode à la livraison est débité.
