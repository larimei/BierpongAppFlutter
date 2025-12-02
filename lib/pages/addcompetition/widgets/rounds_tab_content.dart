import 'package:flutter/material.dart';
import '../../../domain/team.dart';

class RoundsTabContent extends StatelessWidget {
  final ThemeData theme;
  final List<Team> selectedTeams;
  final List<Map<String, dynamic>> generatedRounds;
  final Map<String, Team> teamMap;
  final void Function(int, int, int, bool) onUpdateScore;

  const RoundsTabContent({
    super.key,
    required this.theme,
    required this.selectedTeams,
    required this.generatedRounds,
    required this.teamMap,
    required this.onUpdateScore,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedTeams.isEmpty) {
      return const Center(
        child: Text('Please add teams to the tournament first.'),
      );
    }

    if (generatedRounds.isEmpty) {
      return const Center(
        child: Text('Generating rounds...'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: generatedRounds.length,
      itemBuilder: (context, roundIndex) {
        final round = generatedRounds[roundIndex];
        final List<dynamic> matches = round['matches'];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  round['name'],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0E1A3A),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: matches.length,
                  itemBuilder: (context, matchIndex) {
                    final match = matches[matchIndex];
                    final Team? team1 = teamMap[match['team1Id']];
                    final Team? team2 = teamMap[match['team2Id']];

                    final bool isByeMatch =
                        team1?.name == 'Bye' || team2?.name == 'Bye';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  team1?.name ?? 'TBD',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                              if (!isByeMatch) ...[
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => onUpdateScore(
                                    roundIndex,
                                    matchIndex,
                                    0,
                                    false,
                                  ),
                                ),
                                Text(
                                  '${match['score1']}',
                                  style: theme.textTheme.bodyLarge,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => onUpdateScore(
                                    roundIndex,
                                    matchIndex,
                                    0,
                                    true,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  team2?.name ?? 'TBD',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                              if (!isByeMatch) ...[
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => onUpdateScore(
                                    roundIndex,
                                    matchIndex,
                                    1,
                                    false,
                                  ),
                                ),
                                Text(
                                  '${match['score2']}',
                                  style: theme.textTheme.bodyLarge,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => onUpdateScore(
                                    roundIndex,
                                    matchIndex,
                                    1,
                                    true,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
