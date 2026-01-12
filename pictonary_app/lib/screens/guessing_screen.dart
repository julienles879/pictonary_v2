import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/notebook_background.dart';
import '../theme/doodle_theme.dart';

class GuessingScreen extends StatefulWidget {
  const GuessingScreen({super.key});

  @override
  State<GuessingScreen> createState() => _GuessingScreenState();
}

class _GuessingScreenState extends State<GuessingScreen> {
  final Map<String, List<TextEditingController>> _answerControllers = {};
  final Map<String, String?> _word1Values = {}; // Pour dropdown mot 1
  final Map<String, String?> _word3Values = {}; // Pour dropdown mot 3
  final Map<String, String?> _word4Values = {}; // Pour dropdown mot 4
  final Set<String> _submittedChallenges = {};
  bool _allAnswersSubmitted = false;

  // Listes de valeurs pour les dropdowns (même que challenge_screen)
  final List<String> _word1Options = ['un', 'une'];
  final List<String> _word3Options = ['sur', 'dans'];
  final List<String> _word4Options = ['un', 'une'];

  @override
  void initState() {
    super.initState();
    // Utiliser addPostFrameCallback pour charger après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChallenges();
    });
  }

  Future<void> _startWaitingForOthers() async {
    // Polling pour vérifier le changement de statut
    while (mounted && _allAnswersSubmitted) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted || !_allAnswersSubmitted) break;

      final gameProvider = context.read<GameProvider>();
      await gameProvider.refreshSession();

      if (!mounted) break;
      if (gameProvider.currentSessionStatus == 'finished') {
        print('🎮 PICTONARY 🏆 [NAV] Passage à la phase finished !');
        Navigator.pushReplacementNamed(context, '/finished');
        break;
      }
    }
  }

  Future<void> _loadChallenges() async {
    final gameProvider = context.read<GameProvider>();
    final challengeProvider = context.read<ChallengeProvider>();
    final sessionId = gameProvider.currentSession?.id;

    if (sessionId != null) {
      await challengeProvider.loadChallengesToGuess(sessionId);

      // Créer controllers pour mots 2 et 5 seulement (1, 3, 4 sont des dropdowns)
      if (mounted) {
        print('🖼️ [GUESSING] Challenges chargés:');
        for (var challenge in challengeProvider.challengesToGuess) {
          print('  - Challenge: ${challenge.fullPhrase}');
          print('    imageUrl: ${challenge.imageUrl}');
          print('    imageUrl isEmpty: ${challenge.imageUrl?.isEmpty ?? true}');
          if (challenge.id != null) {
            // Seulement 2 controllers: mot 2 et mot 5
            _answerControllers[challenge.id!] = [
              TextEditingController(), // mot 2
              TextEditingController(), // mot 5
            ];
            // Initialiser les valeurs des dropdowns à null
            _word1Values[challenge.id!] = null;
            _word3Values[challenge.id!] = null;
            _word4Values[challenge.id!] = null;
          }
        }
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    for (var controllers in _answerControllers.values) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _submitAnswer(String challengeId) async {
    final controllers = _answerControllers[challengeId];
    if (controllers == null) return;

    // Vérifier que tous les champs sont remplis (dropdowns + text fields)
    if (_word1Values[challengeId] == null ||
        controllers[0].text.trim().isEmpty || // mot 2
        _word3Values[challengeId] == null ||
        _word4Values[challengeId] == null ||
        controllers[1].text.trim().isEmpty) { // mot 5
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les mots')),
      );
      return;
    }

    final gameProvider = context.read<GameProvider>();
    final challengeProvider = context.read<ChallengeProvider>();
    final sessionId = gameProvider.currentSession?.id;

    if (sessionId == null) return;

    // Construire la réponse complète à partir des dropdowns et text fields
    final answer = '${_word1Values[challengeId]} ${controllers[0].text.trim()} ${_word3Values[challengeId]} ${_word4Values[challengeId]} ${controllers[1].text.trim()}';

    final success = await challengeProvider.answerChallenge(
      sessionId,
      challengeId,
      answer,
      true, // isResolved - on considère qu'on essaie de résoudre le challenge
    );

    if (success && mounted) {
      setState(() {
        _submittedChallenges.add(challengeId);

        // Vérifier si toutes les réponses sont envoyées
        final challengeProvider = context.read<ChallengeProvider>();
        _allAnswersSubmitted = challengeProvider.challengesToGuess.every(
          (c) => c.id != null && _submittedChallenges.contains(c.id!),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réponse envoyée !'),
          backgroundColor: Colors.green,
        ),
      );

      // Si toutes les réponses sont envoyées, démarrer l'attente
      if (_allAnswersSubmitted) {
        print('🎮 PICTONARY ⏳ [WAIT] Toutes les réponses envoyées, attente des autres joueurs...');
        _startWaitingForOthers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final challengeProvider = context.watch<ChallengeProvider>();
    final gameProvider = context.watch<GameProvider>();
    final authProvider = context.watch<AuthProvider>();

    final challenges = challengeProvider.challengesToGuess;
    final allSubmitted = challenges.every(
      (c) => c.id != null && _submittedChallenges.contains(c.id!),
    );

    return Scaffold(
      backgroundColor: DoodleTheme.skyBlue,
      appBar: AppBar(
        title: const Text('🔍 Phase Deviner'),
        centerTitle: true,
      ),
      body: NotebookBackground(
        child: challengeProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : challenges.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun challenge à deviner',
                      style: TextStyle(fontSize: 18, color: DoodleTheme.pencilGray),
                    ),
                  )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: Colors.blue[50],
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
                                    ? '✅ Toutes vos réponses ont été envoyées !'
                                    : '🔮 ${_submittedChallenges.length}/${challenges.length} réponses envoyées',
                                style: TextStyle(
                                  color: allSubmitted
                                      ? Colors.green[700]
                                      : Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Devinez la phrase de 5 mots représentée par chaque image',
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
                            challenge.id ?? '',
                            challenge.imageUrl ?? '',
                            challenge.forbiddenWords,
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
                                  'Toutes vos réponses ont été envoyées !',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Calcul des scores en cours...',
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
      ),
    );
  }

  Widget _buildChallengeCard(
    String challengeId,
    String imageUrl,
    List<String> forbiddenWords,
    bool isSubmitted,
  ) {
    final controllers = _answerControllers[challengeId];

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
                  isSubmitted ? Icons.check_circle : Icons.image,
                  color: isSubmitted ? Colors.green : Colors.blue,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isSubmitted ? 'Réponse envoyée' : 'À deviner',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isSubmitted ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Image générée
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 64, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Image non disponible'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Image en cours de génération...'),
                    ],
                  ),
                ),
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
            if (!isSubmitted && controllers != null) ...[
              const Text(
                'Votre réponse (5 mots) :',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _word1Values[challengeId],
                      decoration: const InputDecoration(
                        labelText: 'Mot 1',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      items: _word1Options
                          .map((word) => DropdownMenuItem(
                                value: word,
                                child: Text(word),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _word1Values[challengeId] = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controllers[0],
                      decoration: const InputDecoration(
                        labelText: 'Mot 2',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _word3Values[challengeId],
                      decoration: const InputDecoration(
                        labelText: 'Mot 3',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      items: _word3Options
                          .map((word) => DropdownMenuItem(
                                value: word,
                                child: Text(word),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _word3Values[challengeId] = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _word4Values[challengeId],
                      decoration: const InputDecoration(
                        labelText: 'Mot 4',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      items: _word4Options
                          .map((word) => DropdownMenuItem(
                                value: word,
                                child: Text(word),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _word4Values[challengeId] = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controllers[1],
                decoration: const InputDecoration(
                  labelText: 'Mot 5',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _submitAnswer(challengeId),
                icon: const Icon(Icons.send),
                label: const Text('Envoyer la réponse'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
                        'Réponse envoyée !',
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
