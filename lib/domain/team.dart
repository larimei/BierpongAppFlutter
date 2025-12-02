import 'dart:ui';

class Team {
  final String id;
  final String name;
  final List<String> playerIds;
  final int wins;
  final int losses;
  final Color color;

  Team({
    required this.id,
    required this.name,
    this.playerIds = const [],
    this.wins = 0,
    this.losses = 0,
    this.color = const Color.fromARGB(255, 14, 69, 114),
  });

  Team copyWith({
    String? id,
    String? name,
    List<String>? playerIds,
    int? wins,
    int? losses,
    Color? color,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      playerIds: playerIds ?? this.playerIds,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'playerIds': playerIds,
    'wins': wins,
    'losses': losses,
    'nameLower': name.toLowerCase(),
    'color': color.value,
  };

  factory Team.fromJson(Map<String, dynamic> j) => Team(
    id: j['id'] as String,
    name: j['name'] as String,
    playerIds: List<String>.from(j['playerIds'] ?? []),
    wins: (j['wins'] ?? 0) as int,
    losses: (j['losses'] ?? 0) as int,
    color: Color(j['color'] as int),
  );
}
