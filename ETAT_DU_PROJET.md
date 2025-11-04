# 📋 État du Projet - Pictonary Flutter

## ✅ Configuration terminée

### Environnement de développement
- ✅ Projet Flutter créé et configuré
- ✅ Dépendances installées (provider, http, shared_preferences)
- ✅ Architecture du projet mise en place
- ✅ Configuration VS Code (launch.json)
- ✅ Documentation créée (README.md, QUICKSTART.md)

### Structure du projet
```
pictonary_app/
├── lib/
│   ├── main.dart                          ✅ Configuration Provider + Routing
│   ├── models/
│   │   ├── player.dart                    ✅ Modèle Player
│   │   ├── game_session.dart              ✅ Modèle GameSession
│   │   └── challenge.dart                 ✅ Modèle Challenge
│   ├── services/
│   │   └── api_service.dart               ✅ Service API complet (toutes les routes)
│   ├── providers/
│   │   ├── auth_provider.dart             ✅ Gestion authentification
│   │   ├── game_provider.dart             ✅ Gestion des sessions de jeu
│   │   └── challenge_provider.dart        ✅ Gestion des challenges
│   ├── screens/
│   │   ├── login_screen.dart              ✅ Écran connexion/inscription
│   │   ├── home_screen.dart               ✅ Écran d'accueil
│   │   ├── join_game_screen.dart          ✅ Écran rejoindre partie
│   │   └── lobby_screen.dart              ✅ Écran lobby (en attente)
│   ├── widgets/                           📁 Dossier pour composants réutilisables
│   └── utils/
│       └── constants.dart                 ✅ Constantes API et jeu
```

## 🎯 Fonctionnalités implémentées

### Authentification
- ✅ Inscription (créer un compte)
- ✅ Connexion
- ✅ Déconnexion
- ✅ Sauvegarde du JWT (persistant)
- ✅ Chargement automatique du JWT au démarrage

### Gestion des sessions de jeu
- ✅ Créer une session
- ✅ Rejoindre une session (avec choix d'équipe)
- ✅ Quitter une session
- ✅ Rafraîchir l'état de la session
- ✅ Démarrer une session
- ✅ Affichage des équipes (rouge et bleue)

### API Service
- ✅ Toutes les routes API implémentées :
  - Auth (create player, login)
  - Me (get me, get player by id)
  - Game Sessions (create, join, leave, get, status, start)
  - Challenges (send, get mine, draw, get to guess, answer, list)
- ✅ Gestion des erreurs
- ✅ Headers d'authentification automatiques

## 🚧 À implémenter

### Écrans manquants
- ⏳ **Challenge Screen** (phase: challenge)
  - Formulaire pour créer 3 challenges
  - 5 mots + mots interdits
  - Compteur de challenges envoyés
  - Validation des champs

- ⏳ **Drawing Screen** (phase: drawing)
  - Affichage des challenges assignés
  - Formulaire pour entrer le prompt
  - Soumission du dessin
  - Affichage de l'image générée (si retournée par l'API)

- ⏳ **Guessing Screen** (phase: guessing)
  - Affichage des images à deviner
  - Formulaire pour entrer la réponse
  - Mots interdits affichés
  - Possibilité de répondre plusieurs fois
  - Marquer comme résolu

- ⏳ **Results Screen** (phase: finished)
  - Affichage de tous les challenges
  - Scores par équipe
  - Challenges résolus vs non résolus

### Fonctionnalités additionnelles
- ⏳ Timer/Countdown pour chaque phase
- ⏳ Polling automatique pour rafraîchir l'état
- ⏳ Notifications de changement de phase
- ⏳ Amélioration UI/UX
- ⏳ Gestion d'images
- ⏳ Validation côté client
- ⏳ Messages d'erreur plus détaillés
- ⏳ Animations de transition
- ⏳ Son/Vibration

### Tests
- ⏳ Tests unitaires
- ⏳ Tests d'intégration
- ⏳ Tests de widgets

## 🔧 Configuration requise

### Backend
- ✅ API doit être lancée sur http://localhost:3000
- ✅ Toutes les routes documentées dans `doc/piction.ia.ry.json`

### URL API selon la plateforme
- **iOS Simulator**: `http://localhost:3000` ✅
- **Android Emulator**: `http://10.0.2.2:3000` (à changer dans constants.dart)
- **Appareil physique**: `http://[IP_LOCAL]:3000` (à changer dans constants.dart)

## 📝 Notes importantes

1. **Flux du jeu** (selon la doc API):
   ```
   lobby → challenge → drawing → guessing → finished
   ```

2. **Phases importantes**:
   - **Challenge**: Chaque joueur doit envoyer 3 challenges
   - **Drawing**: Les joueurs dessinent pour leurs challenges assignés
   - **Guessing**: Les joueurs devinent les challenges de l'équipe adverse
   - **Finished**: Affichage des résultats

3. **Identifiants de test** (voir `doc/identifiants.txt`):
   - julien278 / Test987456!!
   - alice / S3cret!pass

4. **Structure d'un challenge**:
   ```json
   {
     "first_word": "une",
     "second_word": "poule",
     "third_word": "sur",
     "fourth_word": "un",
     "fifth_word": "mur",
     "forbidden_words": ["volaille", "brique", "poulet"]
   }
   ```

## 🎨 Suggestions d'amélioration UI

1. **Écran Login**:
   - Ajouter logo de l'app
   - Animation de chargement plus élaborée

2. **Écran Lobby**:
   - Afficher avatar/icône pour chaque joueur
   - Indicateur visuel du joueur actuel
   - Animation quand un joueur rejoint/quitte

3. **Phases de jeu**:
   - Timer visible en haut
   - Barre de progression des challenges
   - Feedback visuel (success/error)

4. **Global**:
   - Theme personnalisé (couleurs du jeu)
   - Sons/vibrations pour les actions
   - Animations de transition
   - Mode sombre

## 🚀 Prochaines étapes recommandées

1. **Priorité 1**: Implémenter l'écran Challenge
   - Permet de tester le flux complet jusqu'à la phase drawing
   
2. **Priorité 2**: Implémenter l'écran Drawing
   - Essentiel pour le gameplay
   
3. **Priorité 3**: Implémenter l'écran Guessing
   - Complète le gameplay principal
   
4. **Priorité 4**: Implémenter l'écran Results
   - Finalise le cycle de jeu
   
5. **Priorité 5**: Ajouter le polling/refresh automatique
   - Améliore l'expérience utilisateur
   
6. **Priorité 6**: Améliorer l'UI/UX
   - Polish général

## 📚 Ressources

- **Documentation Flutter**: https://flutter.dev/docs
- **Provider Package**: https://pub.dev/packages/provider
- **HTTP Package**: https://pub.dev/packages/http
- **API Routes**: `doc/piction.ia.ry.json`
- **Guide démarrage**: `QUICKSTART.md`

## ✅ Checklist de démarrage

- [x] Flutter installé et configuré
- [x] Projet créé
- [x] Dépendances installées
- [x] Architecture mise en place
- [x] API Service créé
- [x] Providers créés
- [x] Écrans de base créés
- [ ] Backend API lancé
- [ ] Test de connexion
- [ ] Test de création de partie
- [ ] Implémentation des écrans de jeu

## 🎯 État actuel: PRÊT POUR LE DÉVELOPPEMENT

L'environnement est complètement configuré. Vous pouvez maintenant :
1. Lancer le backend API
2. Lancer l'application Flutter avec `flutter run` ou F5 dans VS Code
3. Tester la connexion et la création de partie
4. Commencer à implémenter les écrans manquants

Bon développement ! 🚀
