import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../db/tournamentsrepository.dart';
import '../../db/teamsrepository.dart';
import '../../domain/tournament.dart';
import '../../domain/team.dart';
import '../../widgets/card.dart';
import './widgets/info_tab_content.dart';
import './widgets/rounds_tab_content.dart';
import 'package:bierpongapp/ui/customicons.dart';

class AddCompetitionPage extends StatefulWidget {
  final Tournament? tournament;

  const AddCompetitionPage({super.key, this.tournament});

  @override
  State<AddCompetitionPage> createState() => _AddCompetitionPageState();
}

class _AddCompetitionPageState extends State<AddCompetitionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _ctrl = TextEditingController();
  final _tournamentsRepository = TournamentsRepository();
  final _teamsRepository = TeamsRepository();
  final _uuid = const Uuid();
  late Color _currentColor;
  late TournamentMode _tournamentMode;
  late List<Team> _selectedTeams;
  late Future<List<Team>> _availableTeamsFuture;
  late List<Map<String, dynamic>> _generatedRounds;
  late Map<String, Team> _teamMap;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentColor =
        widget.tournament?.color ?? const Color.fromARGB(255, 14, 69, 114);
    _ctrl.text = widget.tournament?.name ?? '';
    _tournamentMode = widget.tournament?.mode ?? TournamentMode.knockout;
    _selectedTeams = [];
    _generatedRounds = widget.tournament?.rounds ?? [];
    _teamMap = {};

    if (widget.tournament != null) {
      _loadSelectedTeams(widget.tournament!.teamIds);
    } else {
      _availableTeamsFuture = _teamsRepository.list();
    }

    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        if (_selectedTeams.isNotEmpty && _generatedRounds.isEmpty) {
          _generateRounds();
        }
      }
      setState(() {});
    });
  }

  Future<void> _loadSelectedTeams(List<String> teamIds) async {
    final allTeams = await _teamsRepository.list();
    setState(() {
      _selectedTeams = allTeams.where((t) => teamIds.contains(t.id)).toList();
      _teamMap = {for (Team team in _selectedTeams) team.id: team};
      if (_generatedRounds.isEmpty) {
        _generateRounds();
      }
    });
  }

  void _generateRounds() {
    if (_selectedTeams.isEmpty) {
      setState(() {
        _generatedRounds = [];
      });
      return;
    }

    final List<Map<String, dynamic>> rounds = [];
    final List<Team> currentTeams = List.from(_selectedTeams);

    if (_tournamentMode == TournamentMode.knockout) {
      currentTeams.shuffle();

      int numTeams = currentTeams.length;
      int powerOf2 = 1;
      while (powerOf2 < numTeams) {
        powerOf2 *= 2;
      }

      while (currentTeams.length < powerOf2) {
        currentTeams.add(
          Team(id: _uuid.v4(), name: 'Bye', color: Colors.transparent),
        );
      }

      List<Team> teamsInRound = List.from(currentTeams);

      while (teamsInRound.length > 1) {
        final String roundName = _getRoundName(teamsInRound.length);
        final List<Map<String, dynamic>> matchesInRound = [];
        List<Team> nextRoundTeams = [];

        for (int i = 0; i < teamsInRound.length; i += 2) {
          final Team team1 = teamsInRound[i];
          final Team team2 = teamsInRound[i + 1];

          matchesInRound.add({
            'team1Id': team1.id,
            'team2Id': team2.id,
            'score1': 0,
            'score2': 0,
            'roundName': roundName,
            'winnerId': null,
          });
          nextRoundTeams.add(
            Team(id: _uuid.v4(), name: 'TBD', color: Colors.transparent),
          );
        }
        rounds.add({'name': roundName, 'matches': matchesInRound});
        teamsInRound = nextRoundTeams;
      }
    } else {
      final String roundName = 'Round Robin';
      final List<Map<String, dynamic>> matchesInRound = [];
      for (int i = 0; i < currentTeams.length - 1; i++) {
        for (int j = i + 1; j < currentTeams.length; j++) {
          matchesInRound.add({
            'team1Id': currentTeams[i].id,
            'team2Id': currentTeams[j].id,
            'score1': 0,
            'score2': 0,
            'roundName': roundName,
            'winnerId': null,
          });
        }
      }
      rounds.add({'name': roundName, 'matches': matchesInRound});
    }

    setState(() {
      _generatedRounds = rounds;
    });
  }

  String _getRoundName(int numTeams) {
    if (numTeams == 2) return 'Final';
    if (numTeams == 4) return 'Semi-Final';
    if (numTeams == 8) return 'Quarter-Final';
    return 'Round ${numTeams ~/ 2}';
  }

  void _updateScore(
    int roundIndex,
    int matchIndex,
    int teamIndex,
    bool increment,
  ) {
    setState(() {
      final match = _generatedRounds[roundIndex]['matches'][matchIndex];
      if (teamIndex == 0) {
        if (increment) {
          match['score1']++;
        } else if (match['score1'] > 0) {
          match['score1']--;
        }
      } else {
        if (increment) {
          match['score2']++;
        } else if (match['score2'] > 0) {
          match['score2']--;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _showEmptyNameSnackBar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Type in a tournament name')));
  }

  Future<void> _handleSaveTournament() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      _showEmptyNameSnackBar();
      return;
    }

    final tournamentToSave =
        widget.tournament?.copyWith(
          name: name,
          color: _currentColor,
          mode: _tournamentMode,
          teamIds: _selectedTeams.map((t) => t.id).toList(),
          rounds: _generatedRounds,
        ) ??
        Tournament(
          id: _uuid.v4(),
          name: name,
          color: _currentColor,
          mode: _tournamentMode,
          teamIds: _selectedTeams.map((t) => t.id).toList(),
          rounds: _generatedRounds,
        );

    await _tournamentsRepository.upsert(tournamentToSave);
    if (context.mounted) {
      Navigator.pop(context, tournamentToSave.name);
    }
  }

  Future<void> _handleDeleteTournament() async {
    if (widget.tournament == null) return;
    await _tournamentsRepository.delete(widget.tournament!.id);
    if (context.mounted) {
      Navigator.pop(context, widget.tournament!.name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tournament deleted: ${widget.tournament!.name}'),
        ),
      );
    }
  }

  Future<void> _addTeamToTournament() async {
    final allTeams = await _availableTeamsFuture;
    final available = allTeams
        .where((t) => !_selectedTeams.any((st) => st.id == t.id))
        .toList();

    if (context.mounted) {
      final Team? selectedTeam = await showDialog<Team>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Team'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: available.length,
              itemBuilder: (context, index) {
                final team = available[index];
                return ListTile(
                  title: Text(team.name),
                  onTap: () => Navigator.pop(context, team),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (selectedTeam != null) {
        setState(() {
          _selectedTeams.add(selectedTeam);
          _teamMap[selectedTeam.id] = selectedTeam;
          _generateRounds();
        });
      }
    }
  }

  void _removeTeamFromTournament(Team team) {
    setState(() {
      _selectedTeams.removeWhere((t) => t.id == team.id);
      _teamMap.remove(team.id);
      _generateRounds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AvatarCardPage(
      appBarTitle: widget.tournament == null
          ? 'Add Tournament'
          : 'Edit Tournament',
      avatarIconData: CustomIcons.competitions,
      initialAvatarIconColor: _currentColor,
      onAvatarColorsChanged: (color) {
        setState(() => _currentColor = color);
      },
      bottom: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Info', icon: Icon(Icons.info_outline)),
              Tab(text: 'Rounds', icon: Icon(Icons.casino_outlined)),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: TabBarView(
              controller: _tabController,
              children: [
                InfoTabContent(
                  ctrl: _ctrl,
                  theme: theme,
                  tournamentMode: _tournamentMode,
                  onTournamentModeChanged: (mode) {
                    setState(() {
                      _tournamentMode = mode;
                      _generateRounds();
                    });
                  },
                  selectedTeams: _selectedTeams,
                  onRemoveTeam: _removeTeamFromTournament,
                  onAddTeam: _addTeamToTournament,
                  onSaveTournament: _handleSaveTournament,
                  onDeleteTournament: _handleDeleteTournament,
                  isEditing: widget.tournament != null,
                ),
                RoundsTabContent(
                  theme: theme,
                  selectedTeams: _selectedTeams,
                  generatedRounds: _generatedRounds,
                  teamMap: _teamMap,
                  onUpdateScore: _updateScore,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
