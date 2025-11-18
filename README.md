# frontend_transactional_engine

Prototype Flutter de la plateforme transactionnelle (front-end).  
L’objectif actuel est de figer l’UX/UI et les transitions d’authentification en attendant l’API finale.

## Architecture

- `lib/core`: éléments transverses (`AppRouter`).
- `lib/features/auth`:
  - `domain`: modèles métier (`UserProfile`).
  - `data`: services mockés (`MockAuthService`).
  - `application`: contrôleurs d’état (`AuthFlowController`).
  - `presentation`: écrans d’authentification (`pages/`).
- `lib/features/dashboard`: écran d’accueil wallet (`WalletOverviewScreen`) affichant solde, QR et historique.

La gestion d’état repose sur `provider` et un `ChangeNotifier` dédié à l’authentification. Les données sont simulées par un service mock pour isoler l’UI du backend.

## Flux mockés

1. **Inscription** (`RegisterScreen`) : saisie du téléphone et envoi OTP simulé.
2. **OTP** (`OtpVerificationScreen`) : code `1234` nécessaire pour poursuivre.
3. **Profil** (`CompleteProfileScreen`) : capture des informations personnelles.
4. **Code PIN** (`SetPinScreen`) : définition d’un PIN à 6 chiffres enregistré côté mock.
5. **Connexion** (`LoginScreen`) : vérification du PIN stocké.

Chaque étape gère les cas d’erreur, affiche un loader et propose un retour utilisateur cohérent.

## Lancer le projet

```bash
flutter pub get
flutter run
```

> Dépendances clés : `provider` (gestion d’état) et `qr_flutter` (affichage du QR code carte wallet).

## Tests

```bash
flutter test
```

## Prochaines étapes suggérées

- Brancher les appels API réels dans un repository dédié.
- Ajouter un stockage sécurisé pour le PIN (`flutter_secure_storage`).
- Mettre en place une internationalisation complète (`flutter_localizations`).
- Étendre la couverture de tests (widgets + tests d’intégration).*** End Patch
