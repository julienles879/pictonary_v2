import 'package:flutter/foundation.dart';
import '../models/game_session.dart';
import '../services/api_service.dart';

class GameProvider with ChangeNotifier {
  final ApiService _apiService;
  GameSession? _currentSession;
  String? _currentSessionStatus;
  bool _isLoading = false;
  String? _error;

  GameProvider(this._apiService);

  GameSession? get currentSession => _currentSession;
  String? get currentSessionStatus => _currentSessionStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Permet d'accéder à l'API Service depuis l'extérieur
  ApiService getApiService() => _apiService;

  /// Créer une nouvelle session
  Future<bool> createSession() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentSession = await _apiService.createGameSession();
      _currentSessionStatus = _currentSession?.status;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Rejoindre une session
  Future<bool> joinSession(String sessionId, String color) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.joinSession(sessionId, color);
      _currentSession = await _apiService.getGameSession(sessionId);
      _currentSessionStatus = _currentSession?.status;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Quitter la session
  Future<void> leaveSession() async {
    if (_currentSession?.id == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.leaveSession(_currentSession!.id!);
      _currentSession = null;
      _currentSessionStatus = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraîchir la session
  Future<void> refreshSession() async {
    if (_currentSession?.id == null) return;

    try {
      _currentSession = await _apiService.getGameSession(_currentSession!.id!);
      print('🎮 Session rafraîchie: redTeam=${_currentSession!.redTeamIds?.length ?? 0}, blueTeam=${_currentSession!.blueTeamIds?.length ?? 0}');
      _currentSessionStatus = await _apiService.getSessionStatus(
        _currentSession!.id!,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Démarrer la session
  Future<bool> startSession() async {
    if (_currentSession?.id == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.startSession(_currentSession!.id!);
      await refreshSession();
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSession() {
    _currentSession = null;
    _currentSessionStatus = null;
    _error = null;
    notifyListeners();
  }
}
