import 'package:flutter/material.dart';
import 'package:bierpongapp/ui/customicons.dart';
import 'package:uuid/uuid.dart';
import '../db/playersrepository.dart';
import '../domain/player.dart';
import '../widgets/card.dart';

class AddPlayerPage extends StatefulWidget {
  final Player? player;

  const AddPlayerPage({super.key, this.player});
  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  final _ctrl = TextEditingController();
  final _playersRepository = PlayersRepository();
  final _uuid = const Uuid();
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor =
        widget.player?.color ?? const Color.fromARGB(255, 14, 69, 114);
    _ctrl.text = widget.player?.name ?? '';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _showEmptyNameSnackBar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Type in a player name')));
  }

  Future<void> _handleSavePlayer() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      _showEmptyNameSnackBar();
      return;
    }

    final playerToSave =
        widget.player?.copyWith(name: name, color: _currentColor) ??
        Player(id: _uuid.v4(), name: name, color: _currentColor);

    await _playersRepository.upsert(playerToSave);
    Navigator.pop(context, playerToSave.name);
  }

  Future<void> _handleDeletePlayer() async {
    if (widget.player == null) return;
    await _playersRepository.delete(widget.player!.id);
    if (context.mounted) {
      Navigator.pop(context, widget.player!.name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Player deleted: ${widget.player!.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AvatarCardPage(
      appBarTitle: 'Player',
      avatarIconData: CustomIcons.player,
      initialAvatarIconColor: _currentColor,
      onAvatarColorsChanged: (color) {
        setState(() => _currentColor = color);
      },
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.player != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton.icon(
                onPressed: _handleDeletePlayer,
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
            ),
          ElevatedButton.icon(
            onPressed: _handleSavePlayer,
            icon: const Icon(Icons.save_outlined),
            label: Text(widget.player == null ? 'Add' : 'Save'),
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
          Text(
            'Playername',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0E1A3A),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSavePlayer(),
            decoration: const InputDecoration(
              labelText: 'Playername',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 20),
          _StatisticsSection(player: widget.player, theme: theme),
        ],
      ),
    );
  }
}

class _StatisticsSection extends StatelessWidget {
  final Player? player;
  final ThemeData theme;

  const _StatisticsSection({required this.player, required this.theme});

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
          'Wins: ${player?.wins ?? 0}',
          const Color(0xFFF6D74D),
          const Color(0xFF2B2B2B),
        ),
        const SizedBox(height: 8),
        _StatChip(
          'Losses: ${player?.losses ?? 0}',
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
        style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
