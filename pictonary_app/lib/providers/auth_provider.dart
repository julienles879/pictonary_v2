import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  Player? _currentPlayer;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService) {
    AppLogger.auth('AuthProvider créé');
  }

  Player? get currentPlayer => _currentPlayer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentPlayer != null && _apiService.jwt != null;

  /// Initialiser (charger le token sauvegardé)
  Future<void> initialize() async {
    AppLogger.auth('🔄 Initialisation...');
    _isLoading = true;
    notifyListeners();

    try {
      AppLogger.auth('Chargement du token...');
      await _apiService.loadToken();

      if (_apiService.jwt != null) {
        AppLogger.auth('Token trouvé, récupération des infos utilisateur...');
        _currentPlayer = await _apiService.getMe();
        AppLogger.success('Utilisateur connecté: ${_currentPlayer?.name}');
      } else {
        AppLogger.auth('Aucun token sauvegardé');
      }
      _error = null;
    } catch (e) {
      AppLogger.error('Erreur lors de l\'initialisation', e);
      _error = e.toString();
      await _apiService.clearToken();
      _currentPlayer = null;
    } finally {
      _isLoading = false;
      AppLogger.auth(
        'Initialisation terminée. isAuthenticated: $isAuthenticated',
      );
      notifyListeners();
    }
  }

  /// Créer un compte
  Future<bool> register(String name, String password) async {
    AppLogger.auth('📝 Tentative d\'inscription: $name');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.auth('Création du joueur...');
      await _apiService.createPlayer(name, password);
      AppLogger.success('Joueur créé, connexion automatique...');
      // Après création, se connecter automatiquement
      return await login(name, password);
    } catch (e) {
      AppLogger.error('Erreur lors de l\'inscription', e);
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Se connecter
  Future<bool> login(String name, String password) async {
    AppLogger.auth('🔑 Tentative de connexion: $name');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.auth('Appel API login...');
      final token = await _apiService.login(name, password);
      AppLogger.success('Token reçu: ${token.substring(0, 20)}...');

      AppLogger.auth('Sauvegarde du token...');
      await _apiService.saveToken(token, null);

      AppLogger.auth('Récupération des infos utilisateur...');
      _currentPlayer = await _apiService.getMe();
      AppLogger.success('Connexion réussie: ${_currentPlayer?.name}');

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('Erreur lors de la connexion', e);
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Se déconnecter
  Future<void> logout() async {
    AppLogger.auth('👋 Déconnexion');
    await _apiService.clearToken();
    _currentPlayer = null;
    _error = null;
    notifyListeners();
    AppLogger.auth('Déconnexion terminée');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
