import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final _sessionIdController = TextEditingController();
  String _selectedColor = 'red';

  @override
  void dispose() {
    _sessionIdController.dispose();
    super.dispose();
  }

  Future<void> _joinSession() async {
    if (_sessionIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un ID de session')),
      );
      return;
    }

    final gameProvider = context.read<GameProvider>();
    final success = await gameProvider.joinSession(
      _sessionIdController.text,
      _selectedColor,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/lobby');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rejoindre une partie')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _sessionIdController,
              decoration: const InputDecoration(
                labelText: 'ID de la session',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Choisissez votre équipe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Équipe Rouge'),
                    value: 'red',
                    groupValue: _selectedColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedColor = value!;
                      });
                    },
                    activeColor: Colors.red,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Équipe Bleue'),
                    value: 'blue',
                    groupValue: _selectedColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedColor = value!;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                if (gameProvider.error != null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      gameProvider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                if (gameProvider.isLoading) {
                  return const CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: _joinSession,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Rejoindre'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
