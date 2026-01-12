import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/notebook_background.dart';
import '../widgets/doodle_button.dart';
import '../widgets/doodle_card.dart';
import '../theme/doodle_theme.dart';

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
      backgroundColor: DoodleTheme.skyBlue,
      appBar: AppBar(
        title: const Text('🎯 Rejoindre une partie'),
        centerTitle: true,
      ),
      body: NotebookBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Titre avec icône
              const Icon(
                Icons.group_add,
                size: 80,
                color: DoodleTheme.teamBlue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Rejoindre une partie',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: DoodleTheme.inkBlack,
                ),
              ),
              const SizedBox(height: 32),
              // Champ ID de session
              DoodleCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tag, color: DoodleTheme.sunYellow, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'ID de la session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: DoodleTheme.inkBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _sessionIdController,
                      decoration: InputDecoration(
                        hintText: 'Entrez le code de la partie...',
                        prefixIcon: const Icon(Icons.pin),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: DoodleTheme.inkBlack,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: DoodleTheme.inkBlack,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: DoodleTheme.teamBlue,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Sélection d'équipe
              const Text(
                '🎨 Choisissez votre équipe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DoodleTheme.inkBlack,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = 'red';
                        });
                      },
                      child: DoodleCard(
                        color: _selectedColor == 'red'
                            ? const Color(0xFFFFCDD2)
                            : DoodleTheme.cloudWhite,
                        child: Column(
                          children: [
                            Icon(
                              _selectedColor == 'red'
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 48,
                              color: DoodleTheme.teamRed,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Équipe\nRouge',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: DoodleTheme.teamRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = 'blue';
                        });
                      },
                      child: DoodleCard(
                        color: _selectedColor == 'blue'
                            ? const Color(0xFFBBDEFB)
                            : DoodleTheme.cloudWhite,
                        child: Column(
                          children: [
                            Icon(
                              _selectedColor == 'blue'
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 48,
                              color: DoodleTheme.teamBlue,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Équipe\nBleue',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: DoodleTheme.teamBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Erreur
              Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  if (gameProvider.error != null) {
                    return DoodleCard(
                      color: const Color(0xFFFFCDD2),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: DoodleTheme.teamRed,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              gameProvider.error!,
                              style: const TextStyle(
                                color: DoodleTheme.teamRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
              // Bouton Rejoindre
              Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  if (gameProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return DoodleButton(
                    text: 'Rejoindre la partie',
                    onPressed: _joinSession,
                    color: DoodleTheme.grassGreen,
                    icon: Icons.login,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
