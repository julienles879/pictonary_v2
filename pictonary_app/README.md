# Pictonary - Application Flutter

Une application de jeu Pictionary développée en Flutter.

## 📋 Prérequis

- Flutter SDK (version 3.0 ou supérieure)
- Dart SDK
- Un émulateur Android/iOS ou un appareil physique
- L'API backend en cours d'exécution sur `http://localhost:3000`

## 🚀 Installation

1. Cloner le dépôt
2. Se placer dans le dossier du projet :
   ```bash
   cd pictonary_app
   ```

3. Installer les dépendances :
   ```bash
   flutter pub get
   ```

4. Configuration de l'API :
   - Par défaut, l'API est configurée pour `http://localhost:3000`
   - Pour modifier l'URL de l'API, éditez le fichier `lib/utils/constants.dart` et changez la valeur de `baseUrl`

## ▶️ Lancement de l'application

### Mode développement
```bash
flutter run
```

### Build pour Android
```bash
flutter build apk
```

### Build pour iOS
```bash
flutter build ios
```

### Build pour Web
```bash
flutter build web
```

## 🏗️ Architecture du projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/                   # Modèles de données
│   ├── player.dart
│   ├── game_session.dart
│   └── challenge.dart
├── services/                 # Services (API)
│   └── api_service.dart
├── providers/                # Gestion d'état (Provider)
│   ├── auth_provider.dart
│   ├── game_provider.dart
│   └── challenge_provider.dart
├── screens/                  # Écrans de l'application
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── join_game_screen.dart
│   └── lobby_screen.dart
├── widgets/                  # Widgets réutilisables
└── utils/                    # Utilitaires et constantes
    └── constants.dart
```

## 🎮 Flux du jeu

1. **Authentification**
   - Créer un compte ou se connecter
   - Le token JWT est automatiquement sauvegardé

2. **Lobby**
   - Créer une nouvelle partie
   - Ou rejoindre une partie existante avec un ID
   - Choisir son équipe (rouge ou bleue)

3. **Phase de Challenge** (status: `challenge`)
   - Chaque joueur envoie 3 challenges
   - Un challenge = 5 mots + mots interdits

4. **Phase de Dessin** (status: `drawing`)
   - Les joueurs dessinent pour leurs challenges assignés
   - Génération d'image via prompt

5. **Phase de Devinette** (status: `guessing`)
   - Les joueurs devinent les challenges de l'équipe adverse
   - Soumission de réponses

6. **Résultats** (status: `finished`)
   - Affichage des scores et résultats

## 📦 Dépendances principales

- `provider: ^6.1.5` - Gestion d'état
- `http: ^1.5.0` - Requêtes API
- `shared_preferences: ^2.5.3` - Stockage local (token JWT)

## 🔧 Configuration

### Modifier l'URL de l'API

Éditez `lib/utils/constants.dart` :

```dart
class ApiConstants {
  static const String baseUrl = 'http://votre-api.com';
  // ...
}
```

### Identifiants de test

Voir le fichier `doc/identifiants.txt` pour les comptes de test.

## 🐛 Débogage

### Problèmes courants

1. **L'API n'est pas accessible**
   - Vérifiez que le backend est lancé
   - Pour Android Emulator, utilisez `http://10.0.2.2:3000` au lieu de `localhost`
   - Pour un appareil physique, utilisez l'IP de votre machine

2. **Erreur de connexion**
   - Vérifiez les logs avec `flutter logs`
   - Assurez-vous que le JWT n'est pas expiré

## 📱 Tests

```bash
flutter test
```

## 🚢 Déploiement

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📝 Notes

- L'application utilise Material 3
- Le mode debug affiche des informations supplémentaires
- Les tokens JWT sont stockés de manière persistante

## 🤝 Contribution

Ce projet est un projet scolaire. Pour toute question, contactez l'équipe de développement.
