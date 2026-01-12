import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../utils/logger.dart';
import '../widgets/notebook_background.dart';
import '../widgets/doodle_button.dart';
import '../widgets/doodle_card.dart';
import '../theme/doodle_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.navigation('🏠 HomeScreen construit');
    final authProvider = context.watch<AuthProvider>();
    final gameProvider = context.watch<GameProvider>();

    AppLogger.debug(
      'HomeScreen - Joueur: ${authProvider.currentPlayer?.name}, Session: ${gameProvider.currentSession?.id}',
    );

    return Scaffold(
      backgroundColor: DoodleTheme.skyBlue,
      appBar: AppBar(
        title: const Text('🎮 Pictonary'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: NotebookBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // En-tête avec avatar
              DoodleCard(
                color: const Color(0xFFFFF9E6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: DoodleTheme.sunYellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: DoodleTheme.inkBlack, width: 3),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bienvenue !',
                            style: TextStyle(
                              fontSize: 16,
                              color: DoodleTheme.pencilGray,
                            ),
                          ),
                          Text(
                            authProvider.currentPlayer?.name ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: DoodleTheme.inkBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (gameProvider.currentSession == null) ...[
                // Pas de partie en cours - Afficher les options
                DoodleCard(
                  color: const Color(0xFFE8F5E9),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        size: 64,
                        color: DoodleTheme.grassGreen,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nouvelle Partie',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: DoodleTheme.inkBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Créez une partie et invitez vos amis !',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: DoodleTheme.pencilGray),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DoodleButton(
                  text: 'Créer une partie',
                  onPressed: gameProvider.isLoading
                      ? () {}
                      : () async {
                          final success = await gameProvider.createSession();
                          if (success && context.mounted) {
                            Navigator.of(context).pushNamed('/lobby');
                          }
                        },
                  color: DoodleTheme.grassGreen,
                  icon: Icons.add,
                ),
                const SizedBox(height: 16),
                DoodleButton(
                  text: 'Rejoindre une partie',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/join');
                  },
                  color: DoodleTheme.teamBlue,
                  icon: Icons.people,
                ),
              ] else ...[
                // Partie en cours
                DoodleCard(
                  color: const Color(0xFFFFF9C4),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.play_circle_filled,
                        size: 64,
                        color: DoodleTheme.sunYellow,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Partie en cours',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: DoodleTheme.inkBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: DoodleTheme.inkBlack, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.tag, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'ID: ${gameProvider.currentSession!.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8E6C9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: DoodleTheme.grassGreen, width: 2),
                        ),
                        child: Text(
                          '📍 ${gameProvider.currentSessionStatus}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: DoodleTheme.grassGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DoodleButton(
                        text: 'Continuer',
                        onPressed: () {
                          Navigator.of(context).pushNamed('/lobby');
                        },
                        color: DoodleTheme.grassGreen,
                        icon: Icons.arrow_forward,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (gameProvider.error != null)
                DoodleCard(
                  color: const Color(0xFFFFCDD2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: DoodleTheme.teamRed,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
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
                ),
              if (gameProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
