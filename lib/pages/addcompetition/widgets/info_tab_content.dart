import 'package:flutter/material.dart';
import '../../../domain/team.dart';
import '../../../domain/tournament.dart';

class InfoTabContent extends StatelessWidget {
  final TextEditingController ctrl;
  final ThemeData theme;
  final TournamentMode tournamentMode;
  final ValueChanged<TournamentMode> onTournamentModeChanged;
  final List<Team> selectedTeams;
  final Function(Team) onRemoveTeam;
  final VoidCallback onAddTeam;
  final VoidCallback onSaveTournament;
  final VoidCallback onDeleteTournament;
  final bool isEditing;

  const InfoTabContent({
    super.key,
    required this.ctrl,
    required this.theme,
    required this.tournamentMode,
    required this.onTournamentModeChanged,
    required this.selectedTeams,
    required this.onRemoveTeam,
    required this.onAddTeam,
    required this.onSaveTournament,
    required this.onDeleteTournament,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Text(
            'Tournament Name',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0E1A3A),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: ctrl,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSaveTournament(),
          decoration: const InputDecoration(
            labelText: 'Tournament Name',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Tournament Mode:',
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF0E1A3A),
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: TournamentMode.values.map((mode) {
            return RadioListTile<TournamentMode>(
              title: Text(
                mode == TournamentMode.knockout ? 'Knockout' : 'Round Robin',
              ),
              value: mode,
              groupValue: tournamentMode,
              onChanged: (TournamentMode? value) {
                if (value != null) {
                  onTournamentModeChanged(value);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text(
          'Participating Teams:',
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF0E1A3A),
          ),
        ),
        const SizedBox(height: 10),
        selectedTeams.isEmpty
            ? const Text('No teams added to this tournament yet.')
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedTeams.length,
                itemBuilder: (context, index) {
                  final team = selectedTeams[index];
                  return ListTile(
                    title: Text(team.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => onRemoveTeam(team),
                    ),
                  );
                },
              ),
        const SizedBox(height: 20),
        if (isEditing) ...[
          ElevatedButton.icon(
            onPressed: onDeleteTournament,
            icon: const Icon(Icons.delete_outlined),
            label: const Text('Delete Tournament'),
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
          onPressed: onAddTeam,
          icon: const Icon(Icons.group_add_outlined),
          label: const Text('Add Team'),
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
        ElevatedButton.icon(
          onPressed: onSaveTournament,
          icon: const Icon(Icons.save_outlined),
          label: Text(isEditing ? 'Save' : 'Add'),
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
    );
  }
}
