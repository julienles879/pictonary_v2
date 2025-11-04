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
    
    print('🔍 [GameSession.fromJson] json complet: $json');
    print('🔍 [GameSession.fromJson] redTeamData brut: $redTeamData (type: ${redTeamData.runtimeType})');
    print('🔍 [GameSession.fromJson] blueTeamData brut: $blueTeamData (type: ${blueTeamData.runtimeType})');
    
    List<Player>? parsedRedTeam;
    List<Player>? parsedBlueTeam;
    
    if (redTeamData != null && redTeamData is List) {
      print('🔍 [GameSession.fromJson] redTeamData est une liste de ${redTeamData.length} éléments');
      if (redTeamData.isEmpty) {
        parsedRedTeam = [];
      } else {
        parsedRedTeam = redTeamData.map((playerId) {
          print('🔍 [GameSession.fromJson] Traitement joueur rouge: $playerId (type: ${playerId.runtimeType})');
          return Player(id: playerId.toString(), name: 'Player $playerId');
        }).toList();
      }
    }
    
    if (blueTeamData != null && blueTeamData is List) {
      print('🔍 [GameSession.fromJson] blueTeamData est une liste de ${blueTeamData.length} éléments');
      if (blueTeamData.isEmpty) {
        parsedBlueTeam = [];
      } else {
        parsedBlueTeam = blueTeamData.map((playerId) {
          print('🔍 [GameSession.fromJson] Traitement joueur bleu: $playerId (type: ${playerId.runtimeType})');
          return Player(id: playerId.toString(), name: 'Player $playerId');
        }).toList();
      }
    }
    
    print('🔍 [GameSession.fromJson] parsedRedTeam: ${parsedRedTeam?.length ?? "null"} joueurs');
    print('🔍 [GameSession.fromJson] parsedBlueTeam: ${parsedBlueTeam?.length ?? "null"} joueurs');
    
    return GameSession(
      id: rawId != null ? rawId.toString() : null,
      status: json['status'] ?? 'lobby',
      redTeam: parsedRedTeam,
      blueTeam: parsedBlueTeam,
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
