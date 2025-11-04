# 🔍 Guide de Debug avec les Logs - Pictonary

## Système de logs implémenté

J'ai ajouté un système de logs complet avec des **emojis et préfixes** pour faciliter le debug.

## 📝 Types de logs disponibles

### 🔐 AUTH - Authentification
```dart
AppLogger.auth('Message');
```
Pour tout ce qui concerne l'authentification (login, register, logout, tokens)

### 🌐 API - Appels API
```dart
AppLogger.api('Message');
```
Pour tous les appels HTTP (requêtes, réponses, URLs)

### 🎯 GAME - Jeu
```dart
AppLogger.game('Message');
```
Pour la gestion des sessions de jeu

### 🎨 CHALLENGE - Challenges
```dart
AppLogger.challenge('Message');
```
Pour la gestion des challenges

### 📱 NAV - Navigation
```dart
AppLogger.navigation('Message');
```
Pour le changement d'écrans et la navigation

### ✅ SUCCESS - Succès
```dart
AppLogger.success('Message');
```
Pour les opérations réussies

### ❌ ERROR - Erreurs
```dart
AppLogger.error('Message', error, stackTrace);
```
Pour les erreurs (avec détails optionnels)

### ℹ️ INFO - Information
```dart
AppLogger.info('Message');
```
Pour les informations générales

### 🔍 DEBUG - Debug
```dart
AppLogger.debug('Message');
```
Pour les informations de debug détaillées

## 🎯 Ce qui est loggé maintenant

### Au démarrage de l'app
```
🎮 PICTONARY 🚀 Démarrage de l'application
🎮 PICTONARY 🌐 [API] ApiService créé. Base URL: http://10.0.2.2:3000
🎮 PICTONARY 🔐 [AUTH] AuthProvider créé
🎮 PICTONARY 🔐 [AUTH] 🔄 Initialisation...
🎮 PICTONARY 🔐 [AUTH] Chargement du token...
🎮 PICTONARY 🌐 [API] Chargement du token depuis le stockage...
🎮 PICTONARY 🌐 [API] Token chargé: NON
```

### Lors de l'inscription
```
🎮 PICTONARY 📱 [NAV] LoginScreen affiché
🎮 PICTONARY 🔐 [AUTH] 📝 Soumission du formulaire (register)
🎮 PICTONARY 🔐 [AUTH] 📝 Tentative d'inscription: alice
🎮 PICTONARY 🔐 [AUTH] Création du joueur...
🎮 PICTONARY 🌐 [API] POST http://10.0.2.2:3000/players
🎮 PICTONARY 🌐 [API] Création du joueur: alice
🎮 PICTONARY 🌐 [API] Réponse: 201
🎮 PICTONARY ✅ [SUCCESS] Joueur créé: 12345
```

### Lors de la connexion
```
🎮 PICTONARY 🔐 [AUTH] 🔑 Tentative de connexion: alice
🎮 PICTONARY 🔐 [AUTH] Appel API login...
🎮 PICTONARY 🌐 [API] POST http://10.0.2.2:3000/login
🎮 PICTONARY 🌐 [API] Login: alice
🎮 PICTONARY 🌐 [API] Réponse: 200
🎮 PICTONARY ✅ [SUCCESS] Token reçu: eyJhbGciOiJIUzI1NiIs...
🎮 PICTONARY 🔐 [AUTH] Sauvegarde du token...
🎮 PICTONARY 🌐 [API] Sauvegarde du token...
🎮 PICTONARY ✅ [SUCCESS] Token sauvegardé
🎮 PICTONARY 🔐 [AUTH] Récupération des infos utilisateur...
🎮 PICTONARY 🌐 [API] GET http://10.0.2.2:3000/me
🎮 PICTONARY 🌐 [API] Réponse: 200
🎮 PICTONARY ✅ [SUCCESS] Infos joueur récupérées: alice
🎮 PICTONARY ✅ [SUCCESS] Connexion réussie: alice
```

### Navigation vers l'écran d'accueil
```
🎮 PICTONARY 🔐 [AUTH] Résultat: success=true, mounted=true
🎮 PICTONARY 📱 [NAV] Navigation vers /home
🎮 PICTONARY 📱 [NAV] AuthWrapper - isLoading: false, isAuthenticated: true
🎮 PICTONARY 📱 [NAV] Navigation vers HomeScreen
🎮 PICTONARY 📱 [NAV] 🏠 HomeScreen construit
🎮 PICTONARY 🔍 [DEBUG] HomeScreen - Joueur: alice, Session: null
```

### En cas d'erreur
```
🎮 PICTONARY ❌ [ERROR] Erreur login
🎮 PICTONARY ❌ [ERROR] Details: SocketException: Failed host lookup...
🎮 PICTONARY ❌ [ERROR] Erreur lors de la connexion
```

## 🔧 Comment debugger un problème

### 1. Lancer l'app en mode debug
```bash
flutter run
```

### 2. Reproduire le problème
- Par exemple: essayer de se connecter

### 3. Regarder les logs dans le terminal
Cherche les lignes avec `🎮 PICTONARY`

### 4. Identifier le problème

#### Si tu vois:
```
❌ [ERROR] SocketException: Failed host lookup
```
➡️ **Problème réseau**: L'API n'est pas accessible
- Vérifie que le backend est lancé
- Vérifie l'URL dans `lib/utils/constants.dart`
- Pour Android emulator, utilise `http://10.0.2.2:3000`

#### Si tu vois:
```
❌ [ERROR] Erreur API 401: Unauthorized
```
➡️ **Problème d'authentification**: Token invalide
- Le token a expiré
- Ou les credentials sont incorrects

#### Si tu vois:
```
❌ [ERROR] Token non trouvé dans la réponse
```
➡️ **Problème API**: La structure de réponse n'est pas celle attendue
- L'API ne retourne pas de champ `jwt`, `token` ou `access_token`

#### Si tu restes bloqué sur le chargement:
Cherche où s'arrêtent les logs. Par exemple:
```
🔐 [AUTH] 🔄 Initialisation...
🔐 [AUTH] Chargement du token...
```
➡️ Si ça s'arrête là, c'est que `SharedPreferences` bloque

## 💡 Astuces

### Filtrer les logs
Dans le terminal, tu peux rechercher:
- `ERROR` pour voir uniquement les erreurs
- `SUCCESS` pour voir les succès
- `AUTH` pour voir l'authentification
- `API` pour voir les appels HTTP

### Copier les logs
Sélectionne et copie les logs du terminal pour les analyser dans un éditeur de texte.

### Logs trop verbeux ?
Si tu trouves qu'il y a trop de logs, tu peux commenter certains `AppLogger` dans le code.

## 🎯 Prochaine étape

**Lance ton app maintenant** et observe les logs !

Tu verras exactement:
1. ✅ Où ça marche
2. ❌ Où ça bloque
3. 🔍 Les valeurs des variables à chaque étape

Puis partage-moi les logs et je t'aiderai à résoudre le problème ! 🚀
