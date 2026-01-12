import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/notebook_background.dart';
import '../widgets/doodle_button.dart';
import '../widgets/doodle_card.dart';
import '../theme/doodle_theme.dart';

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
    final gameProvider = context.read<GameProvider>();
    await gameProvider.refreshSession();
    
    // Vérifier si le statut a changé pour "challenge"
    if (mounted && gameProvider.currentSession?.status == 'challenge') {
      _refreshTimer?.cancel();
      Navigator.of(context).pushReplacementNamed('/challenge');
    }
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
        backgroundColor: DoodleTheme.skyBlue,
        appBar: AppBar(
          title: const Text('🎮 Lobby'),
          centerTitle: true,
        ),
        body: NotebookBackground(
          child: Center(
            child: DoodleCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.error_outline, size: 64, color: DoodleTheme.teamRed),
                  SizedBox(height: 16),
                  Text(
                    'Aucune session active',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
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
      backgroundColor: DoodleTheme.skyBlue,
      appBar: AppBar(
        title: const Text('🎮 Lobby'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSession,
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await gameProvider.leaveSession();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            tooltip: 'Quitter',
          ),
        ],
      ),
      body: NotebookBackground(
        child: RefreshIndicator(
          onRefresh: _refreshSession,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),
              // Info session avec ID copiable
              DoodleCard(
                color: const Color(0xFFFFF9C4),
                child: Column(
                  children: [
                    const Icon(
                      Icons.videogame_asset,
                      size: 48,
                      color: DoodleTheme.sunYellow,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: DoodleTheme.inkBlack,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              '📌 ${session.id}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: DoodleTheme.grassGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: DoodleTheme.inkBlack,
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white, size: 20),
                            onPressed: () => _copySessionId(session.id!),
                            tooltip: 'Copier l\'ID',
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8E6C9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: DoodleTheme.grassGreen,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '📍 ${gameProvider.currentSessionStatus ?? session.status}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: DoodleTheme.grassGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Sélecteur d'équipe si le joueur n'en a pas encore
              if (!_isPlayerInTeam(session, authProvider.currentPlayer?.id))
                DoodleCard(
                  color: DoodleTheme.cloudWhite,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.groups,
                        size: 48,
                        color: DoodleTheme.pencilGray,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Choisissez votre équipe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DoodleTheme.inkBlack,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DoodleButton(
                              text: 'Équipe\nRouge',
                              onPressed: gameProvider.isLoading
                                  ? () {}
                                  : () => _joinTeam('red'),
                              color: DoodleTheme.teamRed,
                              icon: Icons.group,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DoodleButton(
                              text: 'Équipe\nBleue',
                              onPressed: gameProvider.isLoading
                                  ? () {}
                                  : () => _joinTeam('blue'),
                              color: DoodleTheme.teamBlue,
                              icon: Icons.group,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Affichage des équipes
              const Text(
                '👥 Équipes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: DoodleTheme.inkBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DoodleCard(
                      color: const Color(0xFFFFCDD2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.group, color: DoodleTheme.teamRed, size: 24),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Équipe Rouge',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: DoodleTheme.teamRed,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (session.redTeam == null || session.redTeam!.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: DoodleTheme.pencilGray,
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'En attente de joueurs...',
                                style: TextStyle(
                                  color: DoodleTheme.pencilGray,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          else
                            ...session.redTeam!.map(
                              (player) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: player.id == authProvider.currentPlayer?.id
                                      ? const Color(0xFFFFF9C4)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: player.id == authProvider.currentPlayer?.id
                                        ? DoodleTheme.sunYellow
                                        : DoodleTheme.inkBlack,
                                    width: player.id == authProvider.currentPlayer?.id ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      player.id == authProvider.currentPlayer?.id
                                          ? Icons.star
                                          : Icons.person,
                                      size: 20,
                                      color: player.id == authProvider.currentPlayer?.id
                                          ? DoodleTheme.sunYellow
                                          : DoodleTheme.teamRed,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        player.name,
                                        style: TextStyle(
                                          fontWeight: player.id == authProvider.currentPlayer?.id
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: DoodleCard(
                      color: const Color(0xFFBBDEFB),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.group, color: DoodleTheme.teamBlue, size: 24),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Équipe Bleue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: DoodleTheme.teamBlue,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (session.blueTeam == null || session.blueTeam!.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: DoodleTheme.pencilGray,
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'En attente de joueurs...',
                                style: TextStyle(
                                  color: DoodleTheme.pencilGray,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          else
                            ...session.blueTeam!.map(
                              (player) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: player.id == authProvider.currentPlayer?.id
                                      ? const Color(0xFFFFF9C4)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: player.id == authProvider.currentPlayer?.id
                                        ? DoodleTheme.sunYellow
                                        : DoodleTheme.inkBlack,
                                    width: player.id == authProvider.currentPlayer?.id ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      player.id == authProvider.currentPlayer?.id
                                          ? Icons.star
                                          : Icons.person,
                                      size: 20,
                                      color: player.id == authProvider.currentPlayer?.id
                                          ? DoodleTheme.sunYellow
                                          : DoodleTheme.teamBlue,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        player.name,
                                        style: TextStyle(
                                          fontWeight: player.id == authProvider.currentPlayer?.id
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
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
                ],
              ),
              const SizedBox(height: 24),
              // Actions selon le statut
              if (gameProvider.currentSessionStatus == 'lobby') ...[
                DoodleButton(
                  text: '🚀 Démarrer la partie',
                  onPressed: gameProvider.isLoading
                      ? () {}
                      : () async {
                          final success = await gameProvider.startSession();
                          if (success && context.mounted) {
                            Navigator.of(context).pushReplacementNamed('/challenge');
                          }
                        },
                  color: DoodleTheme.grassGreen,
                  icon: Icons.play_arrow,
                ),
              ] else if (gameProvider.currentSessionStatus == 'challenge') ...[
                DoodleButton(
                  text: '📝 Envoyer des challenges',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/challenge');
                  },
                  color: DoodleTheme.sunYellow,
                  icon: Icons.edit,
                ),
              ] else if (gameProvider.currentSessionStatus == 'drawing') ...[
                DoodleButton(
                  text: '🎨 Dessiner',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/drawing');
                  },
                  color: DoodleTheme.teamRed,
                  icon: Icons.brush,
                ),
              ] else if (gameProvider.currentSessionStatus == 'guessing') ...[
                DoodleButton(
                  text: '🔍 Deviner',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/guessing');
                  },
                  color: DoodleTheme.teamBlue,
                  icon: Icons.search,
                ),
              ] else if (gameProvider.currentSessionStatus == 'finished') ...[
                DoodleButton(
                  text: '🏆 Voir les résultats',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/results');
                  },
                  color: DoodleTheme.sunYellow,
                  icon: Icons.emoji_events,
                ),
              ],
              if (gameProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: DoodleCard(
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
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
