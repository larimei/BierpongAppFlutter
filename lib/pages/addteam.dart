import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:math';
import 'package:bierpongapp/ui/customicons.dart';
import 'package:uuid/uuid.dart';
import '../db/teamsrepository.dart';
import '../db/playersrepository.dart';
import '../domain/team.dart';
import '../domain/player.dart';
import '../widgets/card.dart';

class AddTeamPage extends StatefulWidget {
  final Team? team;

  const AddTeamPage({super.key, this.team});
  @override
  State<AddTeamPage> createState() => _AddTeamPageState();
}

class _AddTeamPageState extends State<AddTeamPage> {
  final _ctrl = TextEditingController();
  final _teamsRepository = TeamsRepository();
  final _playersRepository = PlayersRepository();
  final _uuid = const Uuid();
  late Color _currentColor;
  late List<Player> _selectedPlayers;
  late Future<List<Player>> _availablePlayersFuture;
  List<String> _teamNames = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _loadTeamNames();
    _currentColor =
        widget.team?.color ?? const Color.fromARGB(255, 14, 69, 114);
    _ctrl.text = widget.team?.name ?? '';
    _selectedPlayers = [];
    if (widget.team != null) {
      _loadSelectedPlayers(widget.team!.playerIds);
    }
    _availablePlayersFuture = _playersRepository.list();
  }

  Future<void> _loadTeamNames() async {
    final String response = await rootBundle.loadString(
      'assets/team_names.json',
    );
    final List<dynamic> data = json.decode(response);
    setState(() {
      _teamNames = data.cast<String>();
      if (widget.team == null && _ctrl.text.isEmpty) {
        _ctrl.text = _teamNames[_random.nextInt(_teamNames.length)];
      }
    });
  }

  Future<void> _loadSelectedPlayers(List<String> playerIds) async {
    final allPlayers = await _playersRepository.list();
    setState(() {
      _selectedPlayers = allPlayers
          .where((p) => playerIds.contains(p.id))
          .toList();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _showEmptyNameSnackBar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Type in a team name')));
  }

  Future<void> _handleSaveTeam() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      _showEmptyNameSnackBar();
      return;
    }

    final teamToSave =
        widget.team?.copyWith(
          name: name,
          color: _currentColor,
          playerIds: _selectedPlayers.map((p) => p.id).toList(),
        ) ??
        Team(
          id: _uuid.v4(),
          name: name,
          color: _currentColor,
          playerIds: _selectedPlayers.map((p) => p.id).toList(),
        );

    await _teamsRepository.upsert(teamToSave);
    if (context.mounted) {
      Navigator.pop(context, teamToSave.name);
    }
  }

  Future<void> _handleDeleteTeam() async {
    if (widget.team == null) return;
    await _teamsRepository.delete(widget.team!.id);
    if (context.mounted) {
      Navigator.pop(context, widget.team!.name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Team deleted: ${widget.team!.name}')),
      );
    }
  }

  Future<void> _addPlayerToTeam() async {
    final allPlayers = await _availablePlayersFuture;
    final available = allPlayers
        .where((p) => !_selectedPlayers.any((sp) => sp.id == p.id))
        .toList();

    if (context.mounted) {
      final Player? selectedPlayer = await showDialog<Player>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Player'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: available.length,
              itemBuilder: (context, index) {
                final player = available[index];
                return ListTile(
                  title: Text(player.name),
                  onTap: () => Navigator.pop(context, player),
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

      if (selectedPlayer != null) {
        setState(() {
          _selectedPlayers.add(selectedPlayer);
        });
      }
    }
  }

  void _removePlayerFromTeam(Player player) {
    setState(() {
      _selectedPlayers.removeWhere((p) => p.id == player.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AvatarCardPage(
      appBarTitle: 'Team',
      avatarIconData: CustomIcons.teams,
      initialAvatarIconColor: _currentColor,
      onAvatarColorsChanged: (color) {
        setState(() => _currentColor = color);
      },
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _addPlayerToTeam,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text('Add Player'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF152559),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              minimumSize: const Size.fromHeight(46),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.team != null) ...[
            ElevatedButton.icon(
              onPressed: _handleDeleteTeam,
              icon: const Icon(Icons.delete_outlined),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                minimumSize: const Size.fromHeight(46),
              ),
            ),
            const SizedBox(height: 12),
          ],
          ElevatedButton.icon(
            onPressed: _handleSaveTeam,
            icon: const Icon(Icons.save_outlined),
            label: Text(widget.team == null ? 'Add' : 'Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF152559),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              minimumSize: const Size.fromHeight(46),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Teamname',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0E1A3A),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSaveTeam(),
            decoration: const InputDecoration(
              labelText: 'Teamname',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 20),
          _StatisticsSection(team: widget.team, theme: theme),
          const SizedBox(height: 20),
          Text(
            'Team Members:',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF0E1A3A),
            ),
          ),
          const SizedBox(height: 10),
          _selectedPlayers.isEmpty
              ? const Text('No players in this team yet.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedPlayers.length,
                  itemBuilder: (context, index) {
                    final player = _selectedPlayers[index];
                    return ListTile(
                      title: Text(player.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removePlayerFromTeam(player),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class _StatisticsSection extends StatelessWidget {
  final Team? team;
  final ThemeData theme;

  const _StatisticsSection({required this.team, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Statistics:',
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF0E1A3A),
          ),
        ),
        const SizedBox(height: 10),
        _StatChip(
          'Wins: ${team?.wins ?? 0}',
          const Color(0xFFF6D74D),
          const Color(0xFF2B2B2B),
        ),
        const SizedBox(height: 8),
        _StatChip(
          'Losses: ${team?.losses ?? 0}',
          const Color(0xFFC03945),
          Colors.white,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  const _StatChip(this.text, this.backgroundColor, this.foregroundColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: foregroundColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
