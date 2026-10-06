# Wassaly — وصّلي

Application mobile (Flutter + Firebase) de mise en relation entre clients et
livreurs de proximité en Algérie.

Cahier des charges complet : [`docs/CAHIER_DES_CHARGES.md`](docs/CAHIER_DES_CHARGES.md)

## Lancer le projet

```bash
flutter pub get
flutter gen-l10n
flutter run
```

## État d'avancement

- [x] Étape 0 : environnement, Firebase, dépendances
- [x] Étape 1 : thèmes clair/sombre, français/arabe (RTL), navigation
- [x] Étape 2 : authentification Google, téléphone, choix du rôle, règles Firestore (`firestore.rules`)
- [ ] Étape 3 : liste des livreurs, position GPS, distance
