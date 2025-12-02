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
import '../../logic/tournament_manager.dart';
import 'package:provider/provider.dart';

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
  late Color _currentColor;

  late TournamentManager _tournamentManager;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentColor =
        widget.tournament?.color ?? const Color.fromARGB(255, 14, 69, 114);
    _ctrl.text = widget.tournament?.name ?? '';

    _tournamentManager = TournamentManager(
      _teamsRepository,
      initialTournament: widget.tournament,
    );

    if (widget.tournament != null) {
      _tournamentManager.loadSelectedTeams(widget.tournament!.teamIds);
    }

    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ctrl.dispose();
    _tournamentManager.dispose();
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

    _tournamentManager.finalizeRounds();

    final tournamentToSave =
        widget.tournament?.copyWith(
          name: name,
          color: _currentColor,
          mode: _tournamentManager.tournamentMode,
          teamIds: _tournamentManager.selectedTeamIds,
          rounds: _tournamentManager.getCleanGeneratedRounds(),
        ) ??
        Tournament(
          id: const Uuid().v4(),
          name: name,
          color: _currentColor,
          mode: _tournamentManager.tournamentMode,
          teamIds: _tournamentManager.selectedTeamIds,
          rounds: _tournamentManager.getCleanGeneratedRounds(),
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
    final allTeams = await _teamsRepository.list();
    final availableTeams = allTeams
        .where(
          (t) => !_tournamentManager.selectedTeams.any((st) => st.id == t.id),
        )
        .toList();

    if (context.mounted) {
      final Team? selectedTeam = await showDialog<Team>(
        context: context,
        builder: (context) => _buildAddTeamDialog(context, availableTeams),
      );

      if (selectedTeam != null) {
        _tournamentManager.addTeam(selectedTeam);
      }
    }
  }

  Widget _buildAddTeamDialog(BuildContext context, List<Team> availableTeams) {
    return AlertDialog(
      title: const Text('Add Team'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: availableTeams.length,
          itemBuilder: (context, index) {
            final team = availableTeams[index];
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider<TournamentManager>.value(
      value: _tournamentManager,
      child: AvatarCardPage(
        appBarTitle: widget.tournament == null
            ? 'Add Tournament'
            : 'Edit Tournament',
        avatarIconData: CustomIcons.competitions,
        initialAvatarIconColor: _currentColor,
        onAvatarColorsChanged: (color) {
          setState(() => _currentColor = color);
        },
        bottom: null,
        child: Consumer<TournamentManager>(
          builder: (context, manager, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Info', icon: Icon(Icons.info_outline)),
                    Tab(text: 'Rounds', icon: Icon(Icons.casino_outlined)),
                  ],
                ),
                Builder(
                  builder: (context) {
                    final _tabBarViewHeight =
                        MediaQuery.of(context).size.height *
                        0.6; // Calculate once
                    return SizedBox(
                      height: _tabBarViewHeight,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          InfoTabContent(
                            ctrl: _ctrl,
                            theme: theme,
                            tournamentMode: manager.tournamentMode,
                            onTournamentModeChanged: manager.setTournamentMode,
                            selectedTeams: manager.selectedTeams,
                            onRemoveTeam: manager.removeTeam,
                            onAddTeam: _addTeamToTournament,
                            onSaveTournament: _handleSaveTournament,
                            onDeleteTournament: _handleDeleteTournament,
                            isEditing: widget.tournament != null,
                          ),
                          RoundsTabContent(
                            theme: theme,
                            selectedTeams: manager.selectedTeams,
                            generatedRounds: manager.generatedRounds,
                            teamMap: manager.teamMap,
                            onUpdateScore: manager.updateMatchScore,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
