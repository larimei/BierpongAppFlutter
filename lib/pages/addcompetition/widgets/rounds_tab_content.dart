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
      return const Center(child: Text('Generating rounds...'));
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
          child: ExpansionTile(
            title: Text(
              round['name'],
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0E1A3A),
              ),
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: matches.length,
                itemBuilder: (context, matchIndex) {
                  return _MatchListItem(
                    match: matches[matchIndex],
                    teamMap: teamMap,
                    theme: theme,
                    roundIndex: roundIndex,
                    matchIndex: matchIndex,
                    onUpdateScore: onUpdateScore,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MatchListItem extends StatelessWidget {
  final Map<String, dynamic> match;
  final Map<String, Team> teamMap;
  final ThemeData theme;
  final int roundIndex;
  final int matchIndex;
  final void Function(int, int, int, bool) onUpdateScore;

  const _MatchListItem({
    required this.match,
    required this.teamMap,
    required this.theme,
    required this.roundIndex,
    required this.matchIndex,
    required this.onUpdateScore,
  });

  @override
  Widget build(BuildContext context) {
    final Team? team1 = teamMap[match['team1Id']];
    final Team? team2 = teamMap[match['team2Id']];

    final bool isBothTBD = team1?.name == 'TBD' && team2?.name == 'TBD';
    final bool isVirtualByeMatch = match['team2Id'] == 'virtual_bye_opponent';

    if (isBothTBD) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  team1?.name ?? 'TBD',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isVirtualByeMatch) ...[
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
                  style: theme.textTheme.headlineSmall,
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
          if (!isVirtualByeMatch) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    team2?.name ?? 'TBD',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                  style: theme.textTheme.headlineSmall,
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
            ),
          ] else ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '(Auto-advance)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          if (!isBothTBD && !isVirtualByeMatch) const Divider(),
          if (match['winnerId'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Winner: ${teamMap[match['winnerId']]?.name ?? 'Unknown'}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
