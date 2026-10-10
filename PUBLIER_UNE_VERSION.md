# Publier une nouvelle version de Wassaly

Ce tutoriel explique comment mettre en ligne une nouvelle version de l'application **sans changer le code QR**.

## Comment ca marche

Le code QR (`wassaly_qr.png`) contient ce lien :

```
https://github.com/salahkadd4-web/wassaly/releases/latest/download/wassaly.apk
```

GitHub redirige ce lien vers le fichier `wassaly.apk` de la **derniere release publiee**. Donc :

- vous publiez une nouvelle release qui contient un fichier **nomme exactement `wassaly.apk`** ;
- le meme QR telecharge alors automatiquement la nouvelle version ;
- vous n'avez rien a regenerer ni a reimprimer.

Trois regles ne doivent jamais etre cassees, sinon les telephones refusent la mise a jour ou le lien ne marche plus :

1. **Meme cle de signature** (`android/app/wassaly-release.jks` + `android/key.properties`) pour toutes les versions.
2. **Numero de build strictement plus grand** que celui de la version precedente (le chiffre apres le `+` dans `pubspec.yaml`).
3. **Nom du fichier toujours `wassaly.apk`** et release **publiee** (ni brouillon, ni « pre-release »).

---

## Methode A : a la main (recommandee la premiere fois)

### 1. Verifier le code

Dans le dossier du projet (PowerShell) :

```
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

Testez aussi l'application sur un telephone (`flutter run`) : connexion, une demande, un message.

### 2. Augmenter la version

Dans `pubspec.yaml`, ligne `version:` :

```
version: 1.0.0+1      <- version actuelle (exemple)
version: 1.1.0+2      <- nouvelle version
```

- Avant le `+` : le numero affiche aux utilisateurs (1.1.0).
- Apres le `+` : le numero de build. Il doit **toujours augmenter** (2, puis 3, puis 4...), meme pour une petite correction. Sans cela, Android refuse d'installer par-dessus l'ancienne version.

### 3. Construire l'APK signe

```
flutter build apk --release
```

Verifiez que le fichier `android\key.properties` existe : sinon l'APK serait signe avec la cle de debug et **ne pourrait pas remplacer** les versions deja installees.

Le fichier produit est : `build\app\outputs\flutter-apk\app-release.apk`

### 4. Le renommer `wassaly.apk`

```
Copy-Item build\app\outputs\flutter-apk\app-release.apk wassaly.apk
```

### 5. Publier la release sur GitHub

1. Poussez d'abord votre code (le tag de la release pointera dessus) :
   ```
   git add -A
   git commit -m "Version 1.1.0"
   git push
   ```
2. Ouvrez https://github.com/salahkadd4-web/wassaly/releases > **Draft a new release**.
3. **Choose a tag** : tapez `v1.1.0` puis **Create new tag on publish**.
4. **Release title** : `Wassaly 1.1.0`.
5. **Description** : une ou deux phrases sur les nouveautes (ex. « Notifications push, chiffre d'affaires »).
6. Glissez `wassaly.apk` dans la zone **Attach binaries**.
7. Laissez **decoche** « Set as a pre-release » et ne choisissez pas « Save draft ».
8. Cliquez **Publish release**.

### 6. Verifier

1. Ouvrez le lien du QR dans Chrome sur votre telephone : le telechargement de `wassaly.apk` doit demarrer.
2. Installez-le **par-dessus** l'ancienne version (sans desinstaller) : Android doit proposer « Mettre a jour », et les comptes/donnees restent.
3. Ouvrez l'application, connectez-vous, verifiez la nouveaute.
4. Au besoin, scannez le QR imprime avec un second telephone.

### 7. Prevenir les utilisateurs

Il n'y a **pas de mise a jour automatique** hors Play Store. Dites aux livreurs et clients de **re-scanner le QR** (ou de rouvrir le lien dans Chrome) et d'installer par-dessus. Un message WhatsApp avec le lien suffit.

---

## Methode B : automatique avec le script

Le script `tools\publish_release.ps1` fait les etapes 2 a 5 : il augmente le numero de build, lance les tests, construit l'APK, le renomme et cree la release.

Pre-requis (une seule fois) :

1. Installer GitHub CLI : https://cli.github.com/
2. Se connecter : `gh auth login`

Ensuite, a chaque version :

```
.\tools\publish_release.ps1 -Version 1.1.0 -Notes "Notifications push et chiffre d'affaires"
```

Option `-SkipTests` pour ignorer `flutter test` (deconseille).

---

## Problemes frequents

| Probleme | Cause et solution |
|---|---|
| « Application non installee » / « paquet en conflit » | Signature differente (cle perdue ou `key.properties` absent) ou build non augmente. Verifiez les regles 1 et 2. En dernier recours, desinstaller l'ancienne version (les comptes restent dans Firebase). |
| Le lien du QR donne une erreur 404 | Release encore en brouillon ou « pre-release », fichier pas nomme exactement `wassaly.apk`, ou depot **prive** (il doit etre public pour que n'importe qui puisse telecharger). |
| Le QR telecharge encore l'ancienne version | Rafraichissez la page des releases : la nouvelle release doit etre en haut avec le badge **Latest**. Le navigateur du telephone peut avoir garde l'ancien fichier en cache : reessayez dans Chrome. |
| « Continuer avec Google » echoue (code 10) dans le nouvel APK | Les empreintes SHA-1 et SHA-256 de la cle de release ne sont pas dans Firebase (voir `DISTRIBUTION.md`, section 2). |
| Google Play Protect affiche un avertissement | Normal hors Play Store : **Plus de details > Installer quand meme**. |
| Je veux annuler une version defectueuse | Android ne permet pas de revenir a un build plus petit. Corrigez le code, passez au build suivant (ex. `1.1.1+3`) et publiez une nouvelle release. En attendant, supprimez la release defectueuse sur GitHub : le lien du QR retombera sur la release precedente. |

## Liste de controle rapide

- [ ] `flutter analyze` et `flutter test` sans erreur
- [ ] `pubspec.yaml` : build (apres le `+`) augmente
- [ ] `android\key.properties` present (signature de release)
- [ ] APK renomme `wassaly.apk`
- [ ] Release publiee (pas brouillon, pas pre-release), tag `vX.Y.Z`
- [ ] Lien du QR teste, installation par-dessus l'ancienne version testee
- [ ] Utilisateurs prevenus de re-scanner

## Historique des versions

| Version | Build | Contenu |
|---|---|---|
| 1.0.0 | 1 | Premiere diffusion |
| 1.1.0 | 2 | Notifications push (livreurs), chiffre d'affaires (livreur + admin) |

(Ajoutez une ligne a chaque publication.)
