# Diffuser Wassaly par code QR (sans hebergement payant)

Principe : l'APK est depose gratuitement sur **GitHub Releases**. Un lien **qui ne change jamais**
pointe toujours vers la derniere version, et le code QR contient ce lien. Un utilisateur qui scanne
le QR telecharge l'APK, l'installe, et c'est tout.

> Android uniquement. Un iPhone ne peut pas installer un APK (il faudrait l'App Store / TestFlight).

---

## 1. Creer la cle de signature (une seule fois)

Cette cle prouve que les mises a jour viennent de vous. **Si vous la perdez, vous ne pourrez plus
mettre a jour l'app installee**, sauf en la desinstallant. Faites-en 2 copies (cle USB + mail a vous-meme)
et notez les mots de passe.

Dans un terminal (PowerShell), allez dans `android\app` puis :

```
keytool -genkey -v -keystore wassaly-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wassaly
```

(Si `keytool` n'est pas reconnu : `flutter doctor -v` indique le dossier Java ; `keytool.exe` est dans son sous-dossier `bin`.)

Creez ensuite le fichier **`android\key.properties`** :

```
storePassword=VOTRE_MOT_DE_PASSE
keyPassword=VOTRE_MOT_DE_PASSE
keyAlias=wassaly
storeFile=wassaly-release.jks
```

Ces deux fichiers sont deja exclus de git (`.gitignore`). Ne les envoyez a personne.

## 2. Declarer la cle a Firebase (indispensable, sinon la connexion Google echoue)

Votre app est maintenant signee avec une nouvelle cle. Google ne la connait pas encore.

1. Affichez les empreintes :
   ```
   keytool -list -v -keystore android\app\wassaly-release.jks -alias wassaly
   ```
2. Copiez le **SHA-1** et le **SHA-256**.
3. Console Firebase > Parametres du projet > votre app Android > **Ajouter une empreinte** (ajoutez les deux).
4. Telechargez le nouveau **`google-services.json`** et remplacez `android\app\google-services.json`.

Sans cette etape, le bouton « Continuer avec Google » donne une erreur (code 10 / DEVELOPER_ERROR) dans l'APK diffuse.

## 3. Construire l'APK

```
flutter build apk --release
```

Le fichier est dans `build\app\outputs\flutter-apk\app-release.apk`. **Renommez-le `wassaly.apk`**
(toujours le meme nom, c'est ce qui garde le lien stable).

Avant de le diffuser : installez-le sur un telephone, testez la connexion Google, une inscription,
une demande. Pensez a avoir publie `firestore.rules` et cree le premier admin.

## 4. Heberger gratuitement : GitHub Releases

1. Creez un compte sur github.com.
2. Creez un depot **public** nomme par exemple `wassaly-app` (avec un simple README). Gardez votre vrai code dans un autre depot **prive** ou sur votre PC : le depot public ne contient que l'APK.
3. Dans ce depot : **Releases > Draft a new release** > tag `v1.0.0` > glissez `wassaly.apk` > **Publish release**.
4. Votre lien permanent est :
   ```
   
   https://github.com/VOTRE-NOM/wassaly-app/releases/latest/download/wassaly.apk
   ```
   Il pointe toujours vers la derniere release : a chaque mise a jour, publiez une nouvelle release avec un fichier de meme nom, **le QR ne change pas**.

## 5. Creer le code QR

```
pip install "qrcode[pil]"
python tools/make_qr.py   https://github.com/salahkadd4-web/wassaly-app/releases/latest/download/wassaly.apk
```

Resultat : `wassaly_qr.png`. Vous pouvez aussi utiliser un generateur en ligne, mais choisissez un QR
**statique** (pas « dynamique » : ceux-la deviennent payants apres un essai et le QR cesse de marcher).

Conseils d'impression : 4 cm de cote minimum, fond blanc, bien contraste, testez avec plusieurs telephones.

## 6. Ce que vos utilisateurs doivent faire

1. Scanner le QR avec l'appareil photo, ouvrir le lien **dans Chrome** (pas dans le navigateur interne de Facebook/Instagram/WhatsApp).
2. Telecharger `wassaly.apk`, l'ouvrir.
3. Si Android demande : **Autoriser depuis cette source** (Parametres > Installer des applis inconnues pour Chrome).
4. Si Google Play Protect affiche un avertissement : **Plus de details > Installer quand meme**. (Normal pour une app hors Play Store.)

Texte a mettre sous le QR :
- FR : « Scannez, telechargez, installez. Si Android demande une autorisation, acceptez l'installation depuis cette source. »
- AR : « امسح الرمز، حمّل التطبيق ثم ثبّته. إذا طلب منك أندرويد الإذن، اسمح بالتثبيت من هذا المصدر. »

## 7. Mettre a jour l'application

> Tutoriel detaille (avec script automatique) : **`PUBLIER_UNE_VERSION.md`**. Le lien reel du QR est
> `https://github.com/salahkadd4-web/wassaly/releases/latest/download/wassaly.apk`.

1. Dans `pubspec.yaml`, augmentez la version, y compris le chiffre apres `+` (ex. `1.0.1+2`). Sans cela Android refuse la mise a jour.
2. `flutter build apk --release`, renommez en `wassaly.apk`.
3. Nouvelle release GitHub (tag `v1.0.1`) avec ce fichier.
4. Les utilisateurs doivent **re-scanner** : il n'y a pas de mise a jour automatique hors Play Store.

## 8. Limites a connaitre

- **Pas d'iPhone** (Apple exige l'App Store / TestFlight, payant).
- **Avertissements Play Protect** possibles, et certains telephones bloquent l'installation hors Play Store.
- **Le lien est public** : n'importe qui peut telecharger l'app. Votre base reste protegee par les regles Firestore : verifiez qu'elles sont bien publiees.
- **Quotas Firebase gratuits (Spark)** : largement suffisants pour ~65 utilisateurs ; surveillez la console quand vous grandissez.
- Gardez le meme `applicationId` (`com.wassaly.wassaly`) pour pouvoir passer ensuite au Play Store.

## 9. Plus tard : Google Play Store

- Compte developpeur Google Play : frais uniques d'environ 25 USD ; verifiez que l'Algerie est bien un pays accepte pour l'inscription.
- Google exige un fichier **AAB** : `flutter build appbundle --release`.
- Les nouveaux comptes personnels doivent souvent passer par une phase de test fermee avec un nombre minimum de testeurs avant la production : verifiez les regles en vigueur au moment de publier.
- Vous pourrez alors utiliser la signature Play App Signing et garder cette cle comme cle d'envoi.
