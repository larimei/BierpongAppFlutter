import 'package:flutter/material.dart';
import 'widgets/responsive.dart';
import 'widgets/phoneframe.dart';
import 'ui/customicons.dart';
import 'pages/playerpage.dart';
import 'pages/teampage.dart';
import 'pages/competitionpage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meine App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      builder: (context, child) => PhoneFrame(
        phoneWidth: 390,
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox.shrink(),
        ),
      ),

      home: ResponsiveScaffold(
        forceMobileLayout: true,
        titles: const ['Competitions', 'Teams', 'Player'],
        pages: const [CompetitionsPage(), TeamPage(), PlayerPage()],
        destinations: const [
          NavigationDestination(
            icon: Icon(CustomIcons.competitions),
            label: 'Competitions',
          ),
          NavigationDestination(icon: Icon(CustomIcons.teams), label: 'Teams'),
          NavigationDestination(
            icon: Icon(CustomIcons.player),
            label: 'Player',
          ),
        ],
      ),
    );
  }
}
