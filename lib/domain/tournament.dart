import 'dart:ui';

enum TournamentMode { knockout, roundRobin }

class Tournament {
  final String id;
  final String name;
  final TournamentMode mode;
  final List<String> teamIds;
  final Color color;

  final List<Map<String, dynamic>> rounds;

  Tournament({
    required this.id,
    required this.name,
    this.mode = TournamentMode.knockout,
    this.teamIds = const [],
    this.color = const Color.fromARGB(255, 14, 69, 114),
    this.rounds = const [],
  });

  Tournament copyWith({
    String? id,
    String? name,
    TournamentMode? mode,
    List<String>? teamIds,
    Color? color,
    List<Map<String, dynamic>>? rounds,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      teamIds: teamIds ?? this.teamIds,
      color: color ?? this.color,
      rounds: rounds ?? this.rounds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mode': mode.toString().split('.').last,
    'teamIds': teamIds,
    'color': color.value,
    'rounds': rounds,
  };

  factory Tournament.fromJson(Map<String, dynamic> j) => Tournament(
    id: j['id'] as String,
    name: j['name'] as String,
    mode: TournamentMode.values.firstWhere(
      (e) => e.toString().split('.').last == j['mode'] as String,
      orElse: () => TournamentMode.knockout,
    ),
    teamIds: List<String>.from(j['teamIds'] ?? []),
    color: Color(j['color'] as int),
    rounds: List<Map<String, dynamic>>.from(j['rounds'] ?? []),
  );
}
