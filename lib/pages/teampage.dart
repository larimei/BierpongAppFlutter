import 'package:flutter/material.dart';
import 'addteam.dart';
import 'package:bierpongapp/db/teamsrepository.dart';
import 'package:bierpongapp/domain/team.dart';
import 'package:bierpongapp/ui/customicons.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final _teamsRepository = TeamsRepository();
  late Future<List<Team>> _teamsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchTeams();
  }

  void _fetchTeams() {
    setState(() {
      _teamsFuture = _teamsRepository.list();
    });
  }

  Future<void> _navigateToAddTeam({Team? team}) async {
    final String? resultName = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => AddTeamPage(team: team)),
    );

    if (resultName != null && context.mounted) {
      _fetchTeams();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Team ${team == null ? 'added' : 'updated'}: $resultName',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Team>>(
        future: _teamsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final teams = snapshot.data ?? [];
          if (teams.isEmpty) {
            return const Center(child: Text('No teams yet!'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0,
            ),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return TeamListItem(
                team: team,
                onEdit: () => _navigateToAddTeam(team: team),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _navigateToAddTeam(),
      ),
    );
  }
}

class TeamListItem extends StatelessWidget {
  final Team team;
  final VoidCallback onEdit;

  const TeamListItem({super.key, required this.team, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [team.color, Colors.white],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(CustomIcons.teams, size: 60, color: Colors.black),
              const SizedBox(height: 8),
              Text(
                team.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
