import 'package:flutter/material.dart';
import 'package:bierpongapp/customicons.dart';
import '../widgets/card.dart';

class AddPlayerPage extends StatefulWidget {
  const AddPlayerPage({super.key});
  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Type in a player name')));
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AvatarCardPage(
      appBarTitle: 'Player',
      avatarIconData: CustomIcons.player,
      bottom: SizedBox(
        height: 46,
        child: ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF152559),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
        ),
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
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Playername',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Statistics:',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF0E1A3A),
            ),
          ),
          const SizedBox(height: 10),
          _statChip(
            'Nothing won',
            const Color(0xFFF6D74D),
            const Color(0xFF2B2B2B),
          ),
          const SizedBox(height: 8),
          _statChip('Nothing lost', const Color(0xFFC03945), Colors.white),
        ],
      ),
    );
  }

  Widget _statChip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
