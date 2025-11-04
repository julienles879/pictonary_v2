import 'package:flutter/foundation.dart';
import '../models/challenge.dart';
import '../services/api_service.dart';

class ChallengeProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Challenge> _sentChallenges = [];
  List<Challenge> _challengesToDraw = [];
  List<Challenge> _challengesToGuess = [];
  bool _isLoading = false;
  String? _error;

  ChallengeProvider(this._apiService);

  List<Challenge> get sentChallenges => _sentChallenges;
  List<Challenge> get challengesToDraw => _challengesToDraw;
  List<Challenge> get challengesToGuess => _challengesToGuess;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Envoyer un challenge
  Future<bool> sendChallenge(String sessionId, Challenge challenge) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newChallenge = await _apiService.sendChallenge(
        sessionId,
        challenge,
      );
      _sentChallenges.add(newChallenge);
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

  /// Charger mes challenges à dessiner
  Future<void> loadMyChallenges(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _challengesToDraw = await _apiService.getMyChallenges(sessionId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dessiner pour un challenge
  Future<bool> drawChallenge(
    String sessionId,
    String challengeId,
    String prompt,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.drawChallenge(sessionId, challengeId, prompt);
      await loadMyChallenges(sessionId);
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

  /// Charger les challenges à deviner
  Future<void> loadChallengesToGuess(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _challengesToGuess = await _apiService.getMyChallengesToGuess(sessionId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Répondre à un challenge
  Future<bool> answerChallenge(
    String sessionId,
    String challengeId,
    String answer,
    bool isResolved,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.answerChallenge(
        sessionId,
        challengeId,
        answer,
        isResolved,
      );
      await loadChallengesToGuess(sessionId);
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

  void reset() {
    _sentChallenges = [];
    _challengesToDraw = [];
    _challengesToGuess = [];
    _error = null;
    notifyListeners();
  }
}
