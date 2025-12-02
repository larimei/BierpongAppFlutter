import 'package:flutter/material.dart';
import 'addcompetition/addcompetition_page.dart';
import 'package:bierpongapp/db/tournamentsrepository.dart';
import 'package:bierpongapp/domain/tournament.dart';
import 'package:bierpongapp/ui/customicons.dart';

class CompetitionsPage extends StatefulWidget {
  const CompetitionsPage({super.key});

  @override
  State<CompetitionsPage> createState() => _CompetitionsPageState();
}

class _CompetitionsPageState extends State<CompetitionsPage> {
  final _tournamentsRepository = TournamentsRepository();
  late Future<List<Tournament>> _tournamentsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchTournaments();
  }

  void _fetchTournaments() {
    setState(() {
      _tournamentsFuture = _tournamentsRepository.list();
    });
  }

  Future<void> _navigateToAddCompetition({Tournament? tournament}) async {
    final String? resultName = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCompetitionPage(tournament: tournament),
      ),
    );

    if (resultName != null && context.mounted) {
      _fetchTournaments();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tournament ${tournament == null ? 'added' : 'updated'}: $resultName',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Tournament>>(
        future: _tournamentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final tournaments = snapshot.data ?? [];
          if (tournaments.isEmpty) {
            return const Center(child: Text('No tournaments yet!'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0,
            ),
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              return CompetitionListItem(
                tournament: tournament,
                onEdit: () => _navigateToAddCompetition(tournament: tournament),
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
        onPressed: () => _navigateToAddCompetition(),
      ),
    );
  }
}

class CompetitionListItem extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onEdit;

  const CompetitionListItem({
    super.key,
    required this.tournament,
    required this.onEdit,
  });

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
              colors: [tournament.color, Colors.white],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(CustomIcons.competitions, size: 60, color: Colors.black),
              const SizedBox(height: 8),
              Text(
                tournament.name,
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
