class ApiConstants {
  // Base URL de l'API (pictioniary avec 2 'i' comme dans Postman)
  static const String baseUrl = 'https://pictioniary.wevox.cloud/api';

  // Auth endpoints (selon piction.ia.ry.json)
  static const String createPlayer = '/players';
  static const String login = '/login';

  // Me endpoints
  static const String me = '/me';
  static String getPlayerById(String id) => '/players/$id';

  // Game Sessions endpoints
  static const String gameSessions = '/game_sessions';
  static String getGameSession(String id) => '/game_sessions/$id';
  static String joinSession(String id) => '/game_sessions/$id/join';
  static String leaveSession(String id) => '/game_sessions/$id/leave';
  static String getSessionStatus(String id) => '/game_sessions/$id/status';
  static String startSession(String id) => '/game_sessions/$id/start';

  // Challenges endpoints
  static String sendChallenge(String sessionId) =>
      '/game_sessions/$sessionId/challenges';
  static String getMyChallenges(String sessionId) =>
      '/game_sessions/$sessionId/myChallenges';
  static String drawChallenge(String sessionId, String challengeId) =>
      '/game_sessions/$sessionId/challenges/$challengeId/draw';
  static String getMyChallengesToGuess(String sessionId) =>
      '/game_sessions/$sessionId/myChallengesToGuess';
  static String answerChallenge(String sessionId, String challengeId) =>
      '/game_sessions/$sessionId/challenges/$challengeId/answer';
  static String listChallenges(String sessionId) =>
      '/game_sessions/$sessionId/challenges';
}

class GameConstants {
  static const int maxChallengesPerPlayer = 3;
  static const List<String> availableColors = ['red', 'blue'];
  static const List<String> gameStatuses = [
    'lobby',
    'challenge',
    'drawing',
    'guessing',
    'finished',
  ];
}
