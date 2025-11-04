class Player {
  final String? id;
  final String name;
  final String? password;

  Player({this.id, required this.name, this.password});

  factory Player.fromJson(Map<String, dynamic> json) {
    // L'API retourne un id de type int, on le convertit en String
    final rawId = json['id'] ?? json['_id'];
    return Player(
      id: rawId != null ? rawId.toString() : null,
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (password != null) 'password': password,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {'name': name, 'password': password};
  }
}
