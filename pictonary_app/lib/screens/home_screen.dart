import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../utils/logger.dart';

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
      appBar: AppBar(
        title: const Text('Pictonary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenue ${authProvider.currentPlayer?.name ?? ''}!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            if (gameProvider.currentSession == null) ...[
              ElevatedButton.icon(
                onPressed: gameProvider.isLoading
                    ? null
                    : () async {
                        final success = await gameProvider.createSession();
                        if (success && context.mounted) {
                          Navigator.of(context).pushNamed('/lobby');
                        }
                      },
                icon: const Icon(Icons.add),
                label: const Text('Créer une partie'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/join');
                },
                icon: const Icon(Icons.people),
                label: const Text('Rejoindre une partie'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Partie en cours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('ID: ${gameProvider.currentSession!.id}'),
                      Text('Statut: ${gameProvider.currentSessionStatus}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/lobby');
                        },
                        child: const Text('Continuer'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (gameProvider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  gameProvider.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
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
    );
  }
}
