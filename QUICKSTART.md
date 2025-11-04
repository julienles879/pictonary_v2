# 🚀 Guide de Démarrage Rapide - Pictonary

## Configuration initiale

### 1. Vérifier Flutter
```bash
flutter doctor
```

### 2. Installer les dépendances
```bash
cd pictonary_app
flutter pub get
```

### 3. Configurer l'URL de l'API

**Option 1: Modifier directement le code**
Éditez `lib/utils/constants.dart` et modifiez la valeur de `baseUrl`.

**Option 2: Pour Android Emulator**
Si vous utilisez l'émulateur Android, changez l'URL en :
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

**Option 3: Pour appareil physique**
Remplacez par l'adresse IP de votre machine :
```dart
static const String baseUrl = 'http://192.168.X.X:3000';
```

### 4. Lancer l'application

**a) Avec VS Code:**
- Appuyez sur `F5` ou cliquez sur "Run > Start Debugging"
- Ou utilisez la commande "Flutter: Launch Emulator" puis lancez l'app

**b) En ligne de commande:**
```bash
# Lister les appareils disponibles
flutter devices

# Lancer sur un appareil spécifique
flutter run -d <device_id>

# Lancer sur Chrome (web)
flutter run -d chrome

# Lancer en mode release
flutter run --release
```

## Premiers pas

### Créer un compte
1. Lancez l'application
2. Cliquez sur "S'inscrire"
3. Entrez un nom d'utilisateur et un mot de passe
4. Cliquez sur "S'inscrire"

### Ou utiliser un compte de test
Voir `doc/identifiants.txt` pour les identifiants de test.

### Créer une partie
1. Sur l'écran d'accueil, cliquez sur "Créer une partie"
2. Partagez l'ID de session avec d'autres joueurs
3. Attendez que les joueurs rejoignent
4. Cliquez sur "Démarrer la partie"

### Rejoindre une partie
1. Sur l'écran d'accueil, cliquez sur "Rejoindre une partie"
2. Entrez l'ID de la session
3. Choisissez votre équipe (Rouge ou Bleue)
4. Cliquez sur "Rejoindre"

## Commandes utiles

```bash
# Analyser le code
flutter analyze

# Formater le code
flutter format lib/

# Nettoyer le projet
flutter clean

# Mettre à jour les dépendances
flutter pub upgrade

# Générer un APK (Android)
flutter build apk

# Générer pour iOS
flutter build ios

# Générer pour Web
flutter build web

# Voir les logs en temps réel
flutter logs
```

## Résolution de problèmes

### L'API ne répond pas
- Vérifiez que le backend est lancé sur le port 3000
- Vérifiez l'URL dans `lib/utils/constants.dart`
- Pour l'émulateur Android, utilisez `http://10.0.2.2:3000`

### L'application ne compile pas
```bash
flutter clean
flutter pub get
flutter run
```

### Erreur de certificat SSL (en développement)
L'API utilise probablement HTTP, pas HTTPS. Pas de problème en développement.

### Hot Reload ne fonctionne pas
- Utilisez `r` dans le terminal pour forcer un hot reload
- Utilisez `R` pour un hot restart complet

## Structure du projet

```
pictonary_app/
├── lib/
│   ├── main.dart              # Point d'entrée
│   ├── models/                # Modèles de données
│   ├── services/              # API Service
│   ├── providers/             # State Management (Provider)
│   ├── screens/               # Écrans UI
│   ├── widgets/               # Composants réutilisables
│   └── utils/                 # Constantes et utilitaires
├── android/                   # Projet Android natif
├── ios/                       # Projet iOS natif
├── web/                       # Projet Web
└── pubspec.yaml              # Dépendances du projet
```

## Développement

### Hot Reload
Appuyez sur `r` dans le terminal pendant l'exécution pour recharger l'application sans perdre l'état.

### Hot Restart
Appuyez sur `R` pour redémarrer complètement l'application.

### Debug
- Utilisez des breakpoints dans VS Code
- Utilisez `print()` pour afficher des logs
- Utilisez `debugPrint()` pour les messages de debug

## Prochaines étapes

Une fois l'environnement en place, vous devrez implémenter :
- [ ] Écran de création de challenge (phase challenge)
- [ ] Écran de dessin (phase drawing)
- [ ] Écran de devinette (phase guessing)
- [ ] Écran de résultats (phase finished)
- [ ] Gestion du temps/timer
- [ ] Polling/WebSocket pour les mises à jour en temps réel
- [ ] Améliorations UI/UX

## Support

Pour toute question, consultez :
- Documentation Flutter : https://flutter.dev/docs
- Documentation Provider : https://pub.dev/packages/provider
- API Routes : `doc/piction.ia.ry.json`
