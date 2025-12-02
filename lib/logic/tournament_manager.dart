import 'package:flutter/material.dart';
import '../domain/tournament.dart';
import '../domain/team.dart';
import '../db/teamsrepository.dart';

class TournamentManager with ChangeNotifier {
  TournamentMode _tournamentMode;
  List<Team> _selectedTeams;
  List<Map<String, dynamic>> _generatedRounds;
  Map<String, Team> _teamMap;
  int _currentRoundIndex;
  final TeamsRepository _teamsRepository;

  static const int _winningScoreThreshold = 6;

  TournamentManager(this._teamsRepository, {Tournament? initialTournament})
    : _tournamentMode = initialTournament?.mode ?? TournamentMode.knockout,
      _selectedTeams = [],
      _generatedRounds = _deepCopyRounds(initialTournament?.rounds),
      _teamMap = {},
      _currentRoundIndex = 0;

  // Helper for deep copying rounds
  static List<Map<String, dynamic>> _deepCopyRounds(List<dynamic>? rounds) {
    if (rounds == null) return [];
    final List<Map<String, dynamic>> copiedRounds = [];
    for (final dynamic rawRound in rounds) {
      if (rawRound is Map<String, dynamic>) {
        final Map<String, dynamic> copiedRound = Map<String, dynamic>.from(
          rawRound,
        );
        final List<dynamic>? rawMatches =
            copiedRound['matches'] as List<dynamic>?;
        final List<Map<String, dynamic>> copiedMatches =
            rawMatches
                ?.map(
                  (match) =>
                      Map<String, dynamic>.from(match as Map<String, dynamic>),
                )
                .toList() ??
            [];
        copiedRound['matches'] = copiedMatches;
        copiedRounds.add(copiedRound);
      }
    }
    return copiedRounds;
  }

  // Helper to create a match
  Map<String, dynamic> _createMatch(
    String team1Id,
    String team2Id,
    String roundName, {
    String? winnerId,
  }) {
    return {
      'team1Id': team1Id,
      'team2Id': team2Id,
      'score1': 0,
      'score2': 0,
      'roundName': roundName,
      'winnerId': winnerId,
    };
  }

  // Helper to create a virtual bye match
  Map<String, dynamic> _createVirtualByeMatch(
    String roundName,
    String winnerId,
  ) {
    return _createMatch(
      winnerId,
      'virtual_bye_opponent',
      roundName,
      winnerId: winnerId,
    );
  }

  // Helper to update score for a specific team in a match
  void _updateTeamScore(
    Map<String, dynamic> match,
    int teamIndex,
    bool increment,
  ) {
    final scoreKey = teamIndex == 0 ? 'score1' : 'score2';
    int currentScore = match[scoreKey] as int;
    if (increment) {
      currentScore++;
    } else if (currentScore > 0) {
      currentScore--;
    }
    match[scoreKey] = currentScore;
  }

  // Getters for accessing state
  TournamentMode get tournamentMode => _tournamentMode;
  List<Team> get selectedTeams => _selectedTeams;
  List<Map<String, dynamic>> get generatedRounds => _generatedRounds;
  Map<String, Team> get teamMap => _teamMap;
  int get currentRoundIndex => _currentRoundIndex;
  List<String> get selectedTeamIds => _selectedTeams.map((t) => t.id).toList();

  // Methods to modify state
  void setTournamentMode(TournamentMode mode) {
    _tournamentMode = mode;
    notifyListeners();
  }

  Future<void> addTeam(Team team) async {
    _selectedTeams.add(team);
    _teamMap[team.id] = team;
    notifyListeners();
  }

  void removeTeam(Team team) {
    _selectedTeams.removeWhere((t) => t.id == team.id);
    _teamMap.remove(team.id);
    notifyListeners();
  }

  Future<void> loadSelectedTeams(List<String> teamIds) async {
    _selectedTeams = await _teamsRepository.list().then(
      (allTeams) => allTeams.where((t) => teamIds.contains(t.id)).toList(),
    );
    _teamMap = {for (Team team in _selectedTeams) team.id: team};
    notifyListeners();
  }

  void finalizeRounds() {
    _generateRounds();
    notifyListeners();
  }

  void updateMatchScore(
    int roundIndex,
    int matchIndex,
    int teamIndex,
    bool increment,
  ) {
    final match = _generatedRounds[roundIndex]['matches'][matchIndex];
    final Team? team1 = _teamMap[match['team1Id']];
    final Team? team2 = _teamMap[match['team2Id']];

    final bool isByeMatch = team1?.name == 'Bye' || team2?.name == 'Bye';

    if (isByeMatch) return;

    _updateTeamScore(match, teamIndex, increment);

    if (match['score1'] >= _winningScoreThreshold &&
        match['score1'] > match['score2']) {
      match['winnerId'] = match['team1Id'];
    } else if (match['score2'] >= _winningScoreThreshold &&
        match['score2'] > match['score1']) {
      match['winnerId'] = match['team2Id'];
    } else {
      match['winnerId'] = null;
    }
    notifyListeners();
    _checkAndGenerateNextRound();
  }

  List<Map<String, dynamic>> getCleanGeneratedRounds() {
    return _deepCopyRounds(_generatedRounds);
  }

  void _generateRounds() {
    if (_selectedTeams.isEmpty) {
      _generatedRounds = [];
      _currentRoundIndex = 0;
      notifyListeners();
      return;
    }

    final List<Map<String, dynamic>> initialRoundsList = [];
    List<Team> teamsForFirstRound = List.from(_selectedTeams);

    if (_tournamentMode == TournamentMode.knockout) {
      teamsForFirstRound.shuffle();

      final List<Team> actualPlayingTeams = [];
      String? byeRoundWinnerId;

      if (teamsForFirstRound.length % 2 != 0 && teamsForFirstRound.isNotEmpty) {
        byeRoundWinnerId = teamsForFirstRound.removeLast().id;
      }
      actualPlayingTeams.addAll(teamsForFirstRound);

      final String roundName = _getRoundName(
        actualPlayingTeams.length + (byeRoundWinnerId != null ? 1 : 0),
      );
      final List<Map<String, dynamic>> matchesInRound = [];

      if (actualPlayingTeams.length >= 2) {
        for (int i = 0; i < actualPlayingTeams.length; i += 2) {
          final Team team1 = actualPlayingTeams[i];
          final Team team2 = actualPlayingTeams[i + 1];

          matchesInRound.add(_createMatch(team1.id, team2.id, roundName));
        }
      }

      if (byeRoundWinnerId != null) {
        matchesInRound.add(_createVirtualByeMatch(roundName, byeRoundWinnerId));
      }

      initialRoundsList.add({'name': roundName, 'matches': matchesInRound});
    } else {
      final String roundName = 'Round Robin';
      final List<Map<String, dynamic>> matchesInRound = [];
      for (int i = 0; i < teamsForFirstRound.length - 1; i++) {
        for (int j = i + 1; j < teamsForFirstRound.length; j++) {
          matchesInRound.add(
            _createMatch(
              teamsForFirstRound[i].id,
              teamsForFirstRound[j].id,
              roundName,
            ),
          );
        }
      }
      initialRoundsList.add({'name': roundName, 'matches': matchesInRound});
    }

    _generatedRounds = initialRoundsList;
    _currentRoundIndex = 0;
    notifyListeners();
  }

  String _getRoundName(int totalTeamsInCurrentBracket) {
    if (totalTeamsInCurrentBracket < 2) {
      return 'Tournament Over';
    }

    int effectiveBracketSize = 1;
    while (effectiveBracketSize < totalTeamsInCurrentBracket) {
      effectiveBracketSize *= 2;
    }

    if (effectiveBracketSize == 2) return 'Final';
    if (effectiveBracketSize == 4) return 'Semi-Final';
    if (effectiveBracketSize == 8) return 'Quarter-Final';
    if (effectiveBracketSize == 16) return 'Round of 16';
    if (effectiveBracketSize == 32) return 'Round of 32';
    if (effectiveBracketSize == 64) return 'Round of 64';

    return 'Round of ${effectiveBracketSize}';
  }

  void _checkAndGenerateNextRound() {
    if (_tournamentMode != TournamentMode.knockout) return;
    if (_generatedRounds.isEmpty) return;

    final currentRound = _generatedRounds[_currentRoundIndex];
    final allMatchesCompleted = (currentRound['matches'] as List<dynamic>)
        .every((match) => match['winnerId'] != null);

    if (allMatchesCompleted) {
      final List<Team> winners = [];
      for (var match in (currentRound['matches'] as List<dynamic>)) {
        final winnerTeam = _teamMap[match['winnerId']];
        if (winnerTeam != null) {
          winners.add(winnerTeam);
        }
      }

      if (winners.length < 2) {
        // Tournament has concluded (e.g., only one winner left)
        notifyListeners();
        return;
      }

      winners.shuffle();

      final List<Team> teamsForNextRound = [];
      String? byeRoundWinnerId;

      if (winners.length % 2 != 0) {
        byeRoundWinnerId = winners.removeLast().id;
      }
      teamsForNextRound.addAll(winners);

      final String nextRoundName = _getRoundName(
        teamsForNextRound.length + (byeRoundWinnerId != null ? 1 : 0),
      );
      final List<Map<String, dynamic>> nextRoundMatches = [];

      for (int i = 0; i < teamsForNextRound.length; i += 2) {
        final Team team1 = teamsForNextRound[i];
        final Team team2 = teamsForNextRound[i + 1];

        nextRoundMatches.add(_createMatch(team1.id, team2.id, nextRoundName));
      }

      if (byeRoundWinnerId != null) {
        nextRoundMatches.add(
          _createVirtualByeMatch(nextRoundName, byeRoundWinnerId),
        );
      }

      _generatedRounds.add({
        'name': nextRoundName,
        'matches': nextRoundMatches,
      });
      _currentRoundIndex++;
      notifyListeners();
    }
  }
}
