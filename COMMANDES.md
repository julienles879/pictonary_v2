# 🎮 Commandes Essentielles - Pictonary

## 🚀 Démarrage Rapide

### 1. Première installation
```bash
cd "c:\Users\j.lesimple\Documents\dev\flutter-dev\pictonary v2\pictonary_app"
flutter pub get
```

### 2. Lancer l'application
```bash
# Méthode 1: VS Code (recommandé)
# Appuyez sur F5

# Méthode 2: Ligne de commande
flutter run
```

## 📱 Commandes de développement

### Lancer sur un appareil spécifique
```bash
# Lister les appareils disponibles
flutter devices

# Lancer sur Chrome
flutter run -d chrome

# Lancer sur Windows
flutter run -d windows

# Lancer sur un appareil Android
flutter run -d <device-id>
```

### Hot Reload pendant l'exécution
- Tapez `r` dans le terminal pour recharger
- Tapez `R` pour redémarrer complètement
- Tapez `q` pour quitter

## 🔧 Maintenance

### Nettoyer et réinstaller
```bash
flutter clean
flutter pub get
```

### Mettre à jour les dépendances
```bash
flutter pub upgrade
```

### Analyser le code
```bash
flutter analyze
```

### Formater le code
```bash
flutter format lib/
```

## 🏗️ Build Production

### Android
```bash
# APK
flutter build apk --release

# App Bundle (pour Google Play)
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Windows
```bash
flutter build windows --release
```

### Web
```bash
flutter build web --release
```

## 🔍 Debug et Tests

### Voir les logs
```bash
flutter logs
```

### Tests
```bash
# Tous les tests
flutter test

# Tests avec coverage
flutter test --coverage
```

## ⚙️ Configuration API

### Modifier l'URL de l'API
Éditez: `pictonary_app/lib/utils/constants.dart`

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:3000'; // Changez ici
  // ...
}
```

### URLs selon la plateforme
- **iOS Simulator**: `http://localhost:3000`
- **Android Emulator**: `http://10.0.2.2:3000`
- **Appareil physique**: `http://192.168.X.X:3000` (IP de votre PC)

## 📊 Vérifier l'état

### Flutter Doctor
```bash
flutter doctor
flutter doctor -v  # Version détaillée
```

### Infos du projet
```bash
flutter pub deps           # Dépendances
flutter pub outdated       # Mises à jour disponibles
```

## 🛠️ Dépannage

### Problème de dépendances
```bash
flutter pub cache clean
flutter clean
flutter pub get
```

### Problème de build
```bash
flutter clean
cd android && ./gradlew clean && cd ..  # Sur Windows: gradlew.bat clean
flutter build apk
```

### Problème VS Code
```bash
# Redémarrer le Dart Analysis Server
# Commande Palette (Ctrl+Shift+P) > "Dart: Restart Analysis Server"
```

## 📦 Structure des fichiers importants

```
pictonary_app/
├── lib/
│   ├── main.dart              # Point d'entrée
│   ├── utils/constants.dart   # ⚠️ URL API ici
│   └── services/api_service.dart
├── pubspec.yaml              # ⚠️ Dépendances
├── android/                  # Config Android
├── ios/                      # Config iOS
└── web/                      # Config Web
```

## 🎯 Workflow recommandé

1. **Démarrage**
   ```bash
   flutter run
   ```

2. **Modification du code**
   - Éditez vos fichiers
   - Sauvegardez (Ctrl+S)
   - Hot reload automatique ou tapez `r`

3. **Commit**
   ```bash
   flutter analyze          # Vérifier les erreurs
   flutter format lib/      # Formater
   git add .
   git commit -m "message"
   ```

4. **Build pour tests**
   ```bash
   flutter build apk --debug
   ```

## 💡 Astuces

### Performances
- Utilisez `--release` pour tester les performances réelles
- Le mode debug est plus lent (normal)

### Debugging
- Utilisez `print()` pour debugger
- Mettez des breakpoints dans VS Code
- Utilisez l'inspecteur de widgets (Flutter DevTools)

### Hot Reload
- Fonctionne pour la plupart des changements
- Ne fonctionne pas pour:
  - Changements de `main()`
  - Changements de types globaux
  - Ajout/suppression de fichiers

## 🚨 En cas de problème

1. **Nettoyer tout**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Redémarrer l'app**
   ```bash
   flutter run
   ```

3. **Vérifier Flutter**
   ```bash
   flutter doctor
   ```

4. **Dernière solution**
   ```bash
   flutter pub cache clean
   flutter clean
   rm -rf .dart_tool
   flutter pub get
   flutter run
   ```

## 📞 Support

- Documentation: Voir `README.md` et `QUICKSTART.md`
- État du projet: Voir `ETAT_DU_PROJET.md`
- API Routes: Voir `doc/piction.ia.ry.json`
