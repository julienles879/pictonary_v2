import 'player.dart';

class GameSession {
  final String? id;
  final String status;
  final List<Player>? redTeam;
  final List<Player>? blueTeam;
  final DateTime? createdAt;

  GameSession({
    this.id,
    required this.status,
    this.redTeam,
    this.blueTeam,
    this.createdAt,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    // L'API retourne un id de type int, on le convertit en String
    final rawId = json['id'] ?? json['_id'] ?? json['gameSessionId'];
    
    // L'API retourne 'red_team' et 'blue_team' (snake_case), pas camelCase
    final redTeamData = json['red_team'] ?? json['redTeam'];
    final blueTeamData = json['blue_team'] ?? json['blueTeam'];
    
    return GameSession(
      id: rawId != null ? rawId.toString() : null,
      status: json['status'] ?? 'lobby',
      redTeam: redTeamData != null
          ? (redTeamData as List).map((playerId) {
              // L'API retourne une liste d'IDs, pas d'objets Player
              return Player(id: playerId.toString(), name: 'Player $playerId');
            }).toList()
          : null,
      blueTeam: blueTeamData != null
          ? (blueTeamData as List).map((playerId) {
              // L'API retourne une liste d'IDs, pas d'objets Player
              return Player(id: playerId.toString(), name: 'Player $playerId');
            }).toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'status': status,
      if (redTeam != null) 'redTeam': redTeam!.map((p) => p.toJson()).toList(),
      if (blueTeam != null)
        'blueTeam': blueTeam!.map((p) => p.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
