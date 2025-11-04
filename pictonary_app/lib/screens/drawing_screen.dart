import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final Map<String, TextEditingController> _promptControllers = {};
  final Set<String> _submittedChallenges = {};
  bool _allPromptsSubmitted = false;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _startWaitingForOthers() async {
    // Polling pour vérifier le changement de statut
    while (mounted && _allPromptsSubmitted) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted || !_allPromptsSubmitted) break;
      
      final gameProvider = context.read<GameProvider>();
      await gameProvider.refreshSession();
      
      if (!mounted) break;
      if (gameProvider.currentSessionStatus == 'guessing') {
        print('🎮 PICTONARY 🔮 [NAV] Passage à la phase guessing !');
        // TODO: Navigator.pushReplacementNamed(context, '/guessing');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phase guessing détectée ! (page à créer)'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
      }
    }
  }

  Future<void> _loadChallenges() async {
    final gameProvider = context.read<GameProvider>();
    final challengeProvider = context.read<ChallengeProvider>();
    final sessionId = gameProvider.currentSession?.id;

    if (sessionId != null) {
      await challengeProvider.loadMyChallenges(sessionId);
      
      // Créer un controller pour chaque challenge
      for (var challenge in challengeProvider.challengesToDraw) {
        if (challenge.id != null) {
          _promptControllers[challenge.id!] = TextEditingController();
        }
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (var controller in _promptControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitPrompt(String challengeId, String phrase) async {
    final controller = _promptControllers[challengeId];
    if (controller == null || controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un prompt')),
      );
      return;
    }

    final gameProvider = context.read<GameProvider>();
    final challengeProvider = context.read<ChallengeProvider>();
    final sessionId = gameProvider.currentSession?.id;

    if (sessionId == null) return;

    final success = await challengeProvider.drawChallenge(
      sessionId,
      challengeId,
      controller.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _submittedChallenges.add(challengeId);
        
        // Vérifier si tous les prompts sont envoyés
        final challengeProvider = context.read<ChallengeProvider>();
        _allPromptsSubmitted = challengeProvider.challengesToDraw.every(
          (c) => c.id != null && _submittedChallenges.contains(c.id!),
        );
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt envoyé ! Image en cours de génération...'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Si tous les prompts sont envoyés, démarrer l'attente
      if (_allPromptsSubmitted) {
        print('🎮 PICTONARY ⏳ [WAIT] Tous les prompts envoyés, attente des autres joueurs...');
        _startWaitingForOthers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final challengeProvider = context.watch<ChallengeProvider>();
    final gameProvider = context.watch<GameProvider>();
    final authProvider = context.watch<AuthProvider>();

    final challenges = challengeProvider.challengesToDraw;
    final allSubmitted = challenges.every(
      (c) => c.id != null && _submittedChallenges.contains(c.id!),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase Dessin'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: challengeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : challenges.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun challenge à dessiner',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Joueur: ${authProvider.currentPlayer?.name ?? ""}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Session: ${gameProvider.currentSession?.id ?? ""}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                allSubmitted
                                    ? '✅ Tous vos prompts ont été envoyés !'
                                    : '🎨 ${_submittedChallenges.length}/${challenges.length} prompts envoyés',
                                style: TextStyle(
                                  color: allSubmitted
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Créez un prompt pour générer une image représentant chaque phrase',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ...challenges.map((challenge) {
                        final isSubmitted = challenge.id != null &&
                            _submittedChallenges.contains(challenge.id!);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildChallengeCard(
                            challenge.fullPhrase,
                            challenge.forbiddenWords,
                            challenge.id ?? '',
                            isSubmitted,
                          ),
                        );
                      }),
                      if (allSubmitted) ...[
                        const SizedBox(height: 16),
                        Card(
                          color: Colors.green,
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Tous vos prompts ont été envoyés !',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Images en cours de génération...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                const CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'En attente des autres joueurs...\nVérification toutes les 3 secondes',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildChallengeCard(
    String phrase,
    List<String> forbiddenWords,
    String challengeId,
    bool isSubmitted,
  ) {
    final controller = _promptControllers[challengeId];

    return Card(
      elevation: 4,
      color: isSubmitted ? Colors.green[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSubmitted ? Icons.check_circle : Icons.create,
                  color: isSubmitted ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phrase à illustrer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phrase,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                ...forbiddenWords.map((word) => Chip(
                      label: Text(word),
                      backgroundColor: Colors.red[100],
                      labelStyle: const TextStyle(color: Colors.red),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            if (!isSubmitted && controller != null) ...[
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Prompt pour l\'IA',
                  hintText: 'Ex: Un dessin cartoon coloré de...',
                  border: OutlineInputBorder(),
                  helperText:
                      'Décrivez l\'image que vous voulez générer (sans utiliser les mots interdits)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _submitPrompt(challengeId, phrase),
                icon: const Icon(Icons.send),
                label: const Text('Envoyer le prompt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Prompt envoyé ! Image en cours de génération...',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
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
