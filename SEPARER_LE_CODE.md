# Séparer le code de l'APK (dépôt privé + dépôt public de téléchargement)

## Le but

Aujourd'hui, `github.com/salahkadd4-web/wassaly` est **public** et contient tout le code. N'importe qui peut le copier.
Le code QR pointe vers ce dépôt :

```
https://github.com/salahkadd4-web/wassaly/releases/latest/download/wassaly.apk
```

Après ce tutoriel :

| Dépôt | Visibilité | Contenu |
|---|---|---|
| `salahkadd4-web/wassaly-code` (nouveau) | **Privé** | Tout le code, avec son historique. C'est là que vous travaillez. |
| `salahkadd4-web/wassaly` (existant) | Public | Un simple README + les releases (`wassaly.apk`). **Même nom** : le QR continue de marcher. |

> Pourquoi ne pas juste supprimer les fichiers du dépôt public ? Parce que l'historique Git les garde, et chaque release propose
> un bouton « Source code (zip) » qui télécharge le code de son tag. Il faut donc remplacer l'historique **et** les tags.

Durée : 20 minutes environ. Le lien du QR ne marchera pas pendant quelques minutes entre les étapes 4 et 5.
C'est sans conséquence tant que l'application n'est pas diffusée ; sinon, faites-le le soir.

---

## Étape 0 — Préparer

1. Commitez tout votre travail en cours :
   ```
   cd C:\Users\salah\Desktop\startup\Wassaly\Wassaly
   git status
   git add -A
   git commit -m "Avant separation du depot"
   ```
2. Gardez sous la main le dernier `wassaly.apk` (celui de la release la plus récente). Si vous ne l'avez plus,
   téléchargez-le depuis la page des releases, ou recompilez-le (voir `PUBLIER_UNE_VERSION.md`).

## Étape 1 — Créer le dépôt privé

1. Ouvrez https://github.com/new
2. **Repository name** : `wassaly-code`
3. Cochez **Private**.
4. Ne cochez rien d'autre (pas de README, pas de .gitignore, pas de licence) : le dépôt doit être vide.
5. **Create repository**.

## Étape 2 — Envoyer tout le code vers le dépôt privé

Dans PowerShell, dans le dossier du projet :

```
cd C:\Users\salah\Desktop\startup\Wassaly\Wassaly
git remote rename origin public
git remote add origin git@github.com:salahkadd4-web/wassaly-code.git
git push -u origin main
git push origin --tags
```

- `public` désigne désormais l'ancien dépôt (téléchargement), `origin` le nouveau dépôt privé.
- Si vous utilisez HTTPS plutôt que SSH : `https://github.com/salahkadd4-web/wassaly-code.git`.

**Vérifiez** sur https://github.com/salahkadd4-web/wassaly-code que tous les fichiers et l'historique sont là
avant de continuer : l'étape 3 efface le code du dépôt public.

> Les fichiers secrets (`android/key.properties`, `android/app/wassaly-release.jks`, `tools/serviceAccountKey.json`)
> ne sont pas dans Git (`.gitignore`) : gardez-en vos copies de sauvegarde comme avant.

## Étape 3 — Remplacer le contenu du dépôt public par un simple README

On prépare ce README dans un **dossier séparé**, pour ne pas toucher au projet :

```
cd C:\Users\salah\Desktop\startup
mkdir wassaly-telechargement
cd wassaly-telechargement
git init -b main
```

Créez dans ce dossier un fichier `README.md`, par exemple :

```
# Wassaly

Application de livraison de proximité (Android).

Télécharger la dernière version :
https://github.com/salahkadd4-web/wassaly/releases/latest/download/wassaly.apk

Ouvrez le lien dans Chrome, puis installez le fichier téléchargé.
```

Puis remplacez l'historique du dépôt public par ce seul fichier :

```
git add README.md
git commit -m "Wassaly : telechargement de l'application"
git remote add public git@github.com:salahkadd4-web/wassaly.git
git push public main --force
```

`--force` est voulu ici : l'ancien historique (avec le code) est remplacé. Il reste en sécurité dans `wassaly-code`.

## Étape 4 — Supprimer les anciennes releases et leurs tags

Chaque ancien tag pointe encore vers le code. On les supprime, avec leurs releases.

1. Ouvrez https://github.com/salahkadd4-web/wassaly/releases
2. Pour **chaque** release (`v1.0.0`, `v1.1.0`, `v1.2.0`, `V1.2.1`) : ouvrez-la, icône **poubelle** (Delete) > confirmez.
3. Supprimez ensuite les tags (la suppression d'une release ne supprime pas son tag). Depuis le dossier
   `wassaly-telechargement` :
   ```
   git push public --delete v1.0.0 v1.1.0 v1.2.0 V1.2.1
   ```
   (Ou sur GitHub : onglet **Tags** > chaque tag > **Delete tag**.)

## Étape 5 — Republier l'APK (le QR remarche)

1. https://github.com/salahkadd4-web/wassaly/releases > **Draft a new release**.
2. **Choose a tag** : tapez la version (ex. `v1.2.1`) > **Create new tag on publish**.
   **Target** : `main` (c'est le commit du README : la release ne contient plus de code).
3. Titre : `Wassaly 1.2.1`. Glissez `wassaly.apk`. Laissez « pre-release » décoché.
4. **Publish release**.

## Étape 6 — Vérifier

1. https://github.com/salahkadd4-web/wassaly ne montre que le README.
2. Sur la release, **Source code (zip)** ne contient que le README.
3. Le lien du QR télécharge bien `wassaly.apk` (testez dans Chrome sur le téléphone).
4. **Insights > Forks** du dépôt public : s'il existe des copies (forks), elles gardent l'ancien code ; vous ne pouvez
   pas les supprimer vous-même (demande possible au support GitHub).
5. Pendant quelques semaines, GitHub peut encore servir un ancien commit si quelqu'un connaît son identifiant exact.
   Aucune clé secrète n'y figure ; pour être tranquille, restreignez la clé API Firebase : console Google Cloud >
   API et services > Identifiants > clé « Android key » > **Applications Android** : package `com.wassaly.wassaly`
   + empreinte SHA-1 de votre clé de release.

## Ensuite, au quotidien

- Vous travaillez et poussez comme avant : `git push` envoie vers **`origin` = le dépôt privé**.
- Pour publier une version : créez la release sur le dépôt **public** `salahkadd4-web/wassaly`, cible `main`, avec
  `wassaly.apk` (méthode A de `PUBLIER_UNE_VERSION.md`). Le script `tools\publish_release.ps1` fait déjà cela
  (`--repo salahkadd4-web/wassaly --target main`) tout en poussant le code sur le dépôt privé.
- Ne poussez **jamais** le code vers `public` : `git push public ...` n'est utile que pour le README.
  Pour éviter l'erreur, vous pouvez supprimer ce remote du projet : `git remote remove public`.
