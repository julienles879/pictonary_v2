import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../models/game_session.dart';
import '../models/challenge.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class ApiService {
  String? _jwt;
  String? _playerId;

  String? get jwt => _jwt;
  String? get playerId => _playerId;

  ApiService() {
    AppLogger.api('ApiService créé. Base URL: ${ApiConstants.baseUrl}');
  }

  // Charge le JWT depuis le stockage local
  Future<void> loadToken() async {
    AppLogger.api('Chargement du token depuis le stockage...');
    final prefs = await SharedPreferences.getInstance();
    _jwt = prefs.getString('jwt');
    _playerId = prefs.getString('playerId');
    AppLogger.api(
      'Token chargé: ${_jwt != null ? "OUI (${_jwt!.substring(0, 20)}...)" : "NON"}',
    );
    AppLogger.api('PlayerId chargé: $_playerId');
  }

  // Sauvegarde le JWT dans le stockage local
  Future<void> saveToken(String token, String? playerId) async {
    AppLogger.api('Sauvegarde du token...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
    if (playerId != null) {
      await prefs.setString('playerId', playerId);
    }
    _jwt = token;
    _playerId = playerId;
    AppLogger.success('Token sauvegardé');
  }

  // Supprime le JWT
  Future<void> clearToken() async {
    AppLogger.api('Suppression du token...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('playerId');
    _jwt = null;
    _playerId = null;
    AppLogger.success('Token supprimé');
  }

  // Headers pour les requêtes authentifiées
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_jwt != null) {
      headers['Authorization'] = 'Bearer $_jwt';
    }
    return headers;
  }

  // Gestion des erreurs
  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      AppLogger.error('Erreur API ${response.statusCode}: ${response.body}');
      throw Exception('Erreur API (${response.statusCode}): ${response.body}');
    }
  }

  // ==================== AUTH ====================

  /// Créer un joueur
  Future<Player> createPlayer(String name, String password) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.createPlayer}';
    AppLogger.api('POST $url');
    AppLogger.api('Création du joueur: $name');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'password': password}),
      );
      AppLogger.api('Réponse: ${response.statusCode}');
      _handleError(response);
      final player = Player.fromJson(jsonDecode(response.body));
      AppLogger.success('Joueur créé: ${player.id}');
      return player;
    } catch (e) {
      AppLogger.error('Erreur createPlayer', e);
      rethrow;
    }
  }

  /// Se connecter
  Future<String> login(String name, String password) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.login}';
    AppLogger.api('POST $url');
    AppLogger.api('Login: $name');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'password': password}),
      );
      AppLogger.api('Réponse: ${response.statusCode}');
      _handleError(response);
      final data = jsonDecode(response.body);
      final token = data['jwt'] ?? data['token'] ?? data['access_token'];
      if (token == null) {
        AppLogger.error('Token non trouvé dans la réponse: $data');
        throw Exception('Token non trouvé dans la réponse');
      }
      AppLogger.success('Token reçu: ${token.substring(0, 20)}...');
      return token;
    } catch (e) {
      AppLogger.error('Erreur login', e);
      rethrow;
    }
  }

  // ==================== ME ====================

  /// Obtenir les infos du joueur connecté
  Future<Player> getMe() async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.me}';
    AppLogger.api('GET $url');

    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      AppLogger.api('Réponse: ${response.statusCode}');
      _handleError(response);
      final data = jsonDecode(response.body);
      AppLogger.debug('Données reçues: $data');

      final playerId =
          data['id'] ??
          data['_id'] ??
          (data['player'] != null
              ? (data['player']['id'] ?? data['player']['_id'])
              : null);
      if (playerId != null) {
        // Convertir l'ID en String car l'API retourne un int
        _playerId = playerId.toString();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('playerId', playerId.toString());
        AppLogger.success('PlayerId sauvegardé: $playerId');
      }
      final player = Player.fromJson(data);
      AppLogger.success('Infos joueur récupérées: ${player.name}');
      return player;
    } catch (e) {
      AppLogger.error('Erreur getMe', e);
      rethrow;
    }
  }

  /// Obtenir un joueur par ID
  Future<Player> getPlayerById(String id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getPlayerById(id)}'),
      headers: _headers,
    );
    _handleError(response);
    return Player.fromJson(jsonDecode(response.body));
  }

  // ==================== GAME SESSIONS ====================

  /// Créer une session de jeu
  Future<GameSession> createGameSession() async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.gameSessions}'),
      headers: _headers,
      body: jsonEncode({}),
    );
    _handleError(response);
    return GameSession.fromJson(jsonDecode(response.body));
  }

  /// Rejoindre une session
  Future<void> joinSession(String sessionId, String color) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.joinSession(sessionId)}';
    final body = jsonEncode({'color': color});
    
    print('🌐 [API_RAW] POST $url');
    print('🌐 [API_RAW] Body: $body');
    print('🌐 [API_RAW] Headers: $_headers');
    
    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: body,
    );
    
    print('🌐 [API_RAW] joinSession Response status: ${response.statusCode}');
    print('🌐 [API_RAW] joinSession Response body: ${response.body}');
    
    _handleError(response);
  }

  /// Quitter une session
  Future<void> leaveSession(String sessionId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.leaveSession(sessionId)}',
      ),
      headers: _headers,
    );
    _handleError(response);
  }

  /// Obtenir une session
  Future<GameSession> getGameSession(String sessionId) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.getGameSession(sessionId)}';
    print('🌐 [API_RAW] GET $url');
    print('🌐 [API_RAW] Headers: $_headers');
    
    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );
    
    print('🌐 [API_RAW] Response status: ${response.statusCode}');
    print('🌐 [API_RAW] Response body BRUT: ${response.body}');
    
    _handleError(response);
    
    final jsonData = jsonDecode(response.body);
    print('� [API_RAW] JSON décodé: $jsonData');
    print('🌐 [API_RAW] Type de jsonData: ${jsonData.runtimeType}');
    print('🌐 [API_RAW] Clés disponibles: ${jsonData.keys}');
    print('🌐 [API_RAW] red_team brut: ${jsonData['red_team']}');
    print('� [API_RAW] blue_team brut: ${jsonData['blue_team']}');
    print('🌐 [API_RAW] Type red_team: ${jsonData['red_team'].runtimeType}');
    print('� [API_RAW] Type blue_team: ${jsonData['blue_team'].runtimeType}');
    
    print('🔄 [API_RAW] Appel GameSession.fromJson...');
    final session = GameSession.fromJson(jsonData);
    print('✅ [API_RAW] Session créée - redTeam: ${session.redTeam?.length ?? "null"}, blueTeam: ${session.blueTeam?.length ?? "null"}');
    
    return session;
  }

  /// Obtenir le statut d'une session
  Future<String> getSessionStatus(String sessionId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getSessionStatus(sessionId)}',
      ),
      headers: _headers,
    );
    _handleError(response);
    final data = jsonDecode(response.body);
    return data['status'];
  }

  /// Démarrer une session
  Future<void> startSession(String sessionId) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.startSession(sessionId)}',
      ),
      headers: _headers,
      body: jsonEncode({}),
    );
    _handleError(response);
  }

  // ==================== CHALLENGES ====================

  /// Envoyer un challenge
  Future<Challenge> sendChallenge(String sessionId, Challenge challenge) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.sendChallenge(sessionId)}',
      ),
      headers: _headers,
      body: jsonEncode(challenge.toCreateJson()),
    );
    _handleError(response);
    return Challenge.fromJson(jsonDecode(response.body));
  }

  /// Obtenir mes challenges à dessiner
  Future<List<Challenge>> getMyChallenges(String sessionId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getMyChallenges(sessionId)}',
      ),
      headers: _headers,
    );
    _handleError(response);
    final data = jsonDecode(response.body);
    final List items = data is List ? data : (data['items'] ?? []);
    return items.map((json) => Challenge.fromJson(json)).toList();
  }

  /// Dessiner pour un challenge
  Future<void> drawChallenge(
    String sessionId,
    String challengeId,
    String prompt,
  ) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.drawChallenge(sessionId, challengeId)}',
      ),
      headers: _headers,
      body: jsonEncode({'prompt': prompt}),
    );
    _handleError(response);
  }

  /// Obtenir les challenges à deviner
  Future<List<Challenge>> getMyChallengesToGuess(String sessionId) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.getMyChallengesToGuess(sessionId)}';
    print('🌐 [API_RAW] GET $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    );
    
    print('🌐 [API_RAW] Response status: ${response.statusCode}');
    print('🌐 [API_RAW] Response body: ${response.body}');
    
    _handleError(response);
    final data = jsonDecode(response.body);
    final List items = data is List ? data : (data['items'] ?? []);
    
    print('🌐 [API_RAW] Nombre de challenges: ${items.length}');
    for (var item in items) {
      print('🌐 [API_RAW] Challenge JSON: $item');
      print('🌐 [API_RAW] imageUrl field: ${item['imageUrl']}');
      print('🌐 [API_RAW] image_url field: ${item['image_url']}');
    }
    
    return items.map((json) => Challenge.fromJson(json)).toList();
  }

  /// Répondre à un challenge
  Future<void> answerChallenge(
    String sessionId,
    String challengeId,
    String answer,
    bool isResolved,
  ) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.answerChallenge(sessionId, challengeId)}',
      ),
      headers: _headers,
      body: jsonEncode({'answer': answer, 'is_resolved': isResolved}),
    );
    _handleError(response);
  }

  /// Lister tous les challenges (mode finished uniquement)
  Future<List<Challenge>> listChallenges(String sessionId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.listChallenges(sessionId)}',
      ),
      headers: _headers,
    );
    _handleError(response);
    final data = jsonDecode(response.body);
    final List items = data is List ? data : (data['items'] ?? []);
    return items.map((json) => Challenge.fromJson(json)).toList();
  }
}
