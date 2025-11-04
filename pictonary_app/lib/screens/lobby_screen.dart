import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshSession();
    // Rafraîchir automatiquement toutes les 3 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _refreshSession();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshSession() async {
    await context.read<GameProvider>().refreshSession();
  }

  void _copySessionId(String sessionId) {
    Clipboard.setData(ClipboardData(text: sessionId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID copié dans le presse-papier')),
    );
  }

  bool _isPlayerInTeam(session, String? playerId) {
    if (playerId == null) return false;

    final inRedTeam = session.redTeam?.any((p) => p.id == playerId) ?? false;
    final inBlueTeam = session.blueTeam?.any((p) => p.id == playerId) ?? false;

    return inRedTeam || inBlueTeam;
  }

  Future<void> _joinTeam(String color) async {
    final gameProvider = context.read<GameProvider>();
    final authProvider = context.read<AuthProvider>();
    
    print('🎮 PICTONARY 👤 [LOBBY] Joueur ${authProvider.currentPlayer?.name} (ID: ${authProvider.currentPlayer?.id}) veut rejoindre l\'équipe $color');
    
    final success = await gameProvider.joinSession(
      gameProvider.currentSession!.id!,
      color,
    );

    if (success) {
      print('🎮 PICTONARY ✅ [LOBBY] Succès! Affichage du SnackBar et rafraîchissement...');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vous avez rejoint l\'équipe ${color == "red" ? "rouge" : "bleue"}',
          ),
        ),
      );
      // Attendre un peu que le serveur enregistre, puis rafraîchir
      await Future.delayed(const Duration(milliseconds: 500));
      await _refreshSession();
    } else if (gameProvider.error != null) {
      print('🎮 PICTONARY ❌ [LOBBY] Échec du join: ${gameProvider.error}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(gameProvider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final authProvider = context.watch<AuthProvider>();
    final session = gameProvider.currentSession;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lobby')),
        body: const Center(child: Text('Aucune session active')),
      );
    }

    // Debug : afficher les équipes dans la console
    print(
      '🔴 Équipe Rouge: ${session.redTeam?.map((p) => p.name).join(", ") ?? "vide"}',
    );
    print(
      '🔵 Équipe Bleue: ${session.blueTeam?.map((p) => p.name).join(", ") ?? "vide"}',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSession,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await gameProvider.leaveSession();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSession,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Session: ${session.id}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copySessionId(session.id!),
                          tooltip: 'Copier l\'ID',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Statut: ${gameProvider.currentSessionStatus ?? session.status}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Sélecteur d'équipe si le joueur n'en a pas encore
            if (!_isPlayerInTeam(session, authProvider.currentPlayer?.id))
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Choisissez votre équipe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: gameProvider.isLoading
                                  ? null
                                  : () => _joinTeam('red'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 50),
                              ),
                              icon: const Icon(Icons.group),
                              label: const Text('Équipe Rouge'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: gameProvider.isLoading
                                  ? null
                                  : () => _joinTeam('blue'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 50),
                              ),
                              icon: const Icon(Icons.group),
                              label: const Text('Équipe Bleue'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🔴 Équipe Rouge',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (session.redTeam == null ||
                              session.redTeam!.isEmpty)
                            const Text('Aucun joueur')
                          else
                            ...session.redTeam!.map(
                              (player) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      player.name,
                                      style: TextStyle(
                                        fontWeight:
                                            player.id ==
                                                authProvider.currentPlayer?.id
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🔵 Équipe Bleue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (session.blueTeam == null ||
                              session.blueTeam!.isEmpty)
                            const Text('Aucun joueur')
                          else
                            ...session.blueTeam!.map(
                              (player) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      player.name,
                                      style: TextStyle(
                                        fontWeight:
                                            player.id ==
                                                authProvider.currentPlayer?.id
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (gameProvider.currentSessionStatus == 'lobby') ...[
              ElevatedButton(
                onPressed: gameProvider.isLoading
                    ? null
                    : () async {
                        final success = await gameProvider.startSession();
                        if (success && context.mounted) {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed('/challenge');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Démarrer la partie'),
              ),
            ] else if (gameProvider.currentSessionStatus == 'challenge') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/challenge');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Envoyer des challenges'),
              ),
            ] else if (gameProvider.currentSessionStatus == 'drawing') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/drawing');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Dessiner'),
              ),
            ] else if (gameProvider.currentSessionStatus == 'guessing') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/guessing');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Deviner'),
              ),
            ] else if (gameProvider.currentSessionStatus == 'finished') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/results');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Voir les résultats'),
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
          ],
        ),
      ),
    );
  }
}
