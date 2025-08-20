import 'dart:ui';

class Player {
  final String id;
  final String name;
  final int wins;
  final int losses;
  final Color color;

  Player({
    required this.id,
    required this.name,
    this.wins = 0,
    this.losses = 0,
    this.color = const Color.fromARGB(255, 14, 69, 114),
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'wins': wins,
    'losses': losses,
    'nameLower': name.toLowerCase(),
    'color': color,
  };

  factory Player.fromJson(Map<String, dynamic> j) => Player(
    id: j['id'] as String,
    name: j['name'] as String,
    wins: (j['wins'] ?? 0) as int,
    losses: (j['losses'] ?? 0) as int,
    color: (j['color'] ?? 0) as Color,
  );
}
