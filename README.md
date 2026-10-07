# Wassaly

Application mobile Flutter + Firebase : mise en relation entre clients et livreurs de proximite (Algerie).

- Guide complet d'installation et d'utilisation : [GUIDE.md](GUIDE.md)
- Cahier des charges : [docs/CAHIER_DES_CHARGES.md](docs/CAHIER_DES_CHARGES.md)

## Demarrage rapide

```
flutter pub get
flutter gen-l10n
flutter run
```

Publiez ensuite `firestore.rules` dans la console Firebase (voir le guide, section 4).

## Etat d'avancement

Toutes les etapes du cahier des charges sont implementees : authentification Google, profils client/livreur,
liste des livreurs par distance GPS, appel / WhatsApp / messagerie, demandes de livraison, abonnement avec essai de 2 mois,
panneau administrateur, francais / arabe, themes clair / sombre.

Reste a faire : notifications push application fermee (Cloud Functions), publication Play Store.
