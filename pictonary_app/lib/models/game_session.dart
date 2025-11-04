class GameSession {
  final String? id;
  final String status;
  final List<String>? redTeamIds;  // Liste d'IDs des joueurs
  final List<String>? blueTeamIds; // Liste d'IDs des joueurs
  final DateTime? createdAt;

  GameSession({
    this.id,
    required this.status,
    this.redTeamIds,
    this.blueTeamIds,
    this.createdAt,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    // L'API retourne un id de type int, on le convertit en String
    final rawId = json['id'] ?? json['_id'] ?? json['gameSessionId'];
    
    // L'API peut retourner redTeam/blueTeam ou red_team/blue_team
    // Les équipes sont des listes d'IDs (int), pas des objets Player
    final redTeamData = json['redTeam'] ?? json['red_team'];
    final blueTeamData = json['blueTeam'] ?? json['blue_team'];
    
    return GameSession(
      id: rawId != null ? rawId.toString() : null,
      status: json['status'] ?? 'lobby',
      redTeamIds: redTeamData != null
          ? (redTeamData as List).map((id) => id.toString()).toList()
          : null,
      blueTeamIds: blueTeamData != null
          ? (blueTeamData as List).map((id) => id.toString()).toList()
          : null,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse(json['createdAt'] ?? json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'status': status,
      if (redTeamIds != null) 'red_team': redTeamIds,
      if (blueTeamIds != null) 'blue_team': blueTeamIds,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
