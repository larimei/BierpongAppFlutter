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

  factory Tournament.fromJson(Map<String, dynamic> j) {
    final List<dynamic>? rawRounds = j['rounds'] as List<dynamic>?;
    final List<Map<String, dynamic>> processedRounds = [];

    if (rawRounds != null) {
      for (final dynamic rawRound in rawRounds) {
        final Map<String, dynamic> roundMap = {};
        if (rawRound is Map) {
          roundMap.addAll(Map<String, dynamic>.from(rawRound));
        } else {
          continue;
        }

        final List<dynamic>? rawMatches = roundMap['matches'] as List<dynamic>?;
        final List<Map<String, dynamic>> processedMatches = [];

        if (rawMatches != null) {
          for (final dynamic rawMatch in rawMatches) {
            if (rawMatch is Map) {
              processedMatches.add(Map<String, dynamic>.from(rawMatch));
            }
          }
        }
        roundMap['matches'] = processedMatches;
        processedRounds.add(roundMap);
      }
    }

    return Tournament(
      id: j['id'] as String,
      name: j['name'] as String,
      mode: TournamentMode.values.firstWhere(
        (e) => e.toString().split('.').last == j['mode'] as String,
        orElse: () => TournamentMode.knockout,
      ),
      teamIds: List<String>.from(j['teamIds'] ?? []),
      color: Color(j['color'] as int),
      rounds: processedRounds,
    );
  }
}
