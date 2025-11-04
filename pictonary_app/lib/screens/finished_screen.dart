import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/game_provider.dart';
import '../models/challenge.dart';

class FinishedScreen extends StatefulWidget {
  const FinishedScreen({super.key});

  @override
  State<FinishedScreen> createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResults();
    });
  }

  Future<void> _loadResults() async {
    final gameProvider = context.read<GameProvider>();
    final challengeProvider = context.read<ChallengeProvider>();
    final sessionId = gameProvider.currentSession?.id;

    if (sessionId != null) {
      await challengeProvider.loadAllChallenges(sessionId);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _startNewGame() async {
    final gameProvider = context.read<GameProvider>();
    
    // Créer une nouvelle session
    final success = await gameProvider.createSession();
    
    if (success && mounted) {
      // Naviguer vers le lobby
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/lobby',
        (route) => false, // Supprimer toutes les routes précédentes
      );
    }
  }

  void _goHome() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.clearSession();
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final challengeProvider = context.watch<ChallengeProvider>();
    final gameProvider = context.watch<GameProvider>();
    
    final session = gameProvider.currentSession;
    final challenges = challengeProvider.allChallenges;

    // Calculer les scores : si un challenge est résolu, c'est l'équipe du challenged_id qui gagne 1 point
    int redTeamScore = 0;
    int blueTeamScore = 0;
    
    final redTeam = session?.redTeam ?? [];
    final blueTeam = session?.blueTeam ?? [];
    
    for (var challenge in challenges) {
      if (challenge.isResolved == true && challenge.challengedId != null) {
        // Vérifier à quelle équipe appartient le challenged (celui qui devait deviner)
        final challengedPlayerId = challenge.challengedId!;
        if (redTeam.any((p) => p.id == challengedPlayerId)) {
          redTeamScore++;
        } else if (blueTeam.any((p) => p.id == challengedPlayerId)) {
          blueTeamScore++;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Pas de bouton retour
      ),
      body: challengeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête avec confettis
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple[400]!, Colors.purple[700]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 64,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Partie terminée !',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Session ${session?.id ?? ""}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Scores des équipes
                  Row(
                    children: [
                      Expanded(
                        child: _buildTeamScoreCard(
                          'Équipe Rouge',
                          redTeamScore,
                          Colors.red,
                          redTeamScore > blueTeamScore,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTeamScoreCard(
                          'Équipe Bleue',
                          blueTeamScore,
                          Colors.blue,
                          blueTeamScore > redTeamScore,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Liste des challenges
                  const Text(
                    'Tous les challenges',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (challenges.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'Aucun challenge disponible',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ...challenges.map((challenge) => 
                      _buildChallengeCard(challenge)
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Boutons d'action
                  ElevatedButton.icon(
                    onPressed: _startNewGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Nouvelle Partie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _goHome,
                    icon: const Icon(Icons.home),
                    label: const Text('Retour à l\'accueil'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildTeamScoreCard(String teamName, int score, Color color, bool isWinner) {
    return Card(
      elevation: isWinner ? 8 : 4,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color,
          width: isWinner ? 3 : 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (isWinner)
              const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 32,
              ),
            Text(
              teamName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              score.toString(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'point${score > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final hasImage = challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty;
    final isResolved = challenge.isResolved ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statut
            Row(
              children: [
                Icon(
                  isResolved ? Icons.check_circle : Icons.cancel,
                  color: isResolved ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.fullPhrase,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isResolved ? 'Résolu !' : 'Non résolu',
                        style: TextStyle(
                          fontSize: 14,
                          color: isResolved ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Image si disponible
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  challenge.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            
            // Mots interdits
            Wrap(
              spacing: 8,
              children: [
                const Text(
                  'Mots interdits:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                ...challenge.forbiddenWords.map((word) => Chip(
                      label: Text(word),
                      backgroundColor: Colors.red[100],
                      labelStyle: const TextStyle(color: Colors.red),
                    )),
              ],
            ),
            
            // Réponse donnée (si disponible)
            if (challenge.answer != null && challenge.answer!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isResolved ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isResolved ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: isResolved ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Réponse:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            challenge.answer!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
