import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  // Listes de valeurs pour les dropdowns
  final List<String> _word1Options = ['un', 'une'];
  final List<String> _word3Options = ['sur', 'dans'];
  final List<String> _word4Options = ['un', 'une'];

  @override
  void initState() {
    super.initState();
    // Ne pas démarrer le polling automatiquement,
    // seulement après l'envoi des challenges
  }

  Future<void> _startWaitingForOthers() async {
    // Polling pour vérifier le changement de statut
    while (mounted && _submitted) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted || !_submitted) break;

      final gameProvider = context.read<GameProvider>();
      await gameProvider.refreshSession();

      if (!mounted) break;
      if (gameProvider.currentSessionStatus == 'drawing') {
        print('🎮 PICTONARY 🎨 [NAV] Passage à la phase drawing !');
        Navigator.pushReplacementNamed(context, '/drawing');
        break;
      }
    }
  }

  // Challenge 1
  String? _ch1_word1;
  final _ch1_word2 = TextEditingController();
  String? _ch1_word3;
  String? _ch1_word4;
  final _ch1_word5 = TextEditingController();
  final _ch1_forbidden1 = TextEditingController();
  final _ch1_forbidden2 = TextEditingController();
  final _ch1_forbidden3 = TextEditingController();

  // Challenge 2
  String? _ch2_word1;
  final _ch2_word2 = TextEditingController();
  String? _ch2_word3;
  String? _ch2_word4;
  final _ch2_word5 = TextEditingController();
  final _ch2_forbidden1 = TextEditingController();
  final _ch2_forbidden2 = TextEditingController();
  final _ch2_forbidden3 = TextEditingController();

  // Challenge 3
  String? _ch3_word1;
  final _ch3_word2 = TextEditingController();
  String? _ch3_word3;
  String? _ch3_word4;
  final _ch3_word5 = TextEditingController();
  final _ch3_forbidden1 = TextEditingController();
  final _ch3_forbidden2 = TextEditingController();
  final _ch3_forbidden3 = TextEditingController();

  @override
  void dispose() {
    _ch1_word2.dispose();
    _ch1_word5.dispose();
    _ch1_forbidden1.dispose();
    _ch1_forbidden2.dispose();
    _ch1_forbidden3.dispose();
    _ch2_word2.dispose();
    _ch2_word5.dispose();
    _ch2_forbidden1.dispose();
    _ch2_forbidden2.dispose();
    _ch2_forbidden3.dispose();
    _ch3_word2.dispose();
    _ch3_word5.dispose();
    _ch3_forbidden1.dispose();
    _ch3_forbidden2.dispose();
    _ch3_forbidden3.dispose();
    super.dispose();
  }

  void _fillWithTestData() {
    setState(() {
      // Challenge 1: "une poule sur un mur"
      _ch1_word1 = 'une';
      _ch1_word2.text = 'poule';
      _ch1_word3 = 'sur';
      _ch1_word4 = 'un';
      _ch1_word5.text = 'mur';
      _ch1_forbidden1.text = 'volaille';
      _ch1_forbidden2.text = 'brique';
      _ch1_forbidden3.text = 'poulet';

      // Challenge 2: "un chat dans une maison"
      _ch2_word1 = 'un';
      _ch2_word2.text = 'chat';
      _ch2_word3 = 'dans';
      _ch2_word4 = 'une';
      _ch2_word5.text = 'maison';
      _ch2_forbidden1.text = 'félin';
      _ch2_forbidden2.text = 'habitation';
      _ch2_forbidden3.text = 'demeure';

      // Challenge 3: "une fleur sur un balcon"
      _ch3_word1 = 'une';
      _ch3_word2.text = 'fleur';
      _ch3_word3 = 'sur';
      _ch3_word4 = 'un';
      _ch3_word5.text = 'balcon';
      _ch3_forbidden1.text = 'plante';
      _ch3_forbidden2.text = 'terrasse';
      _ch3_forbidden3.text = 'pétale';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Données de test remplies !'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );
  }

  bool _validateForbiddenWords(List<String> words, String challengeName) {
    // Vérifier que tous les mots sont remplis
    if (words.any((w) => w.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$challengeName: Les 3 mots interdits doivent être remplis',
          ),
        ),
      );
      return false;
    }

    // Vérifier qu'ils sont tous différents
    if (words.toSet().length != words.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$challengeName: Les 3 mots interdits doivent être différents',
          ),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _submitAllChallenges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final gameProvider = context.read<GameProvider>();
    final challengeProvider = context.read<ChallengeProvider>();
    final sessionId = gameProvider.currentSession?.id;

    if (sessionId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Aucune session active')));
      }
      return;
    }

    // Préparer et valider les mots interdits
    final forbidden1 = [
      _ch1_forbidden1.text.trim(),
      _ch1_forbidden2.text.trim(),
      _ch1_forbidden3.text.trim(),
    ];

    final forbidden2 = [
      _ch2_forbidden1.text.trim(),
      _ch2_forbidden2.text.trim(),
      _ch2_forbidden3.text.trim(),
    ];

    final forbidden3 = [
      _ch3_forbidden1.text.trim(),
      _ch3_forbidden2.text.trim(),
      _ch3_forbidden3.text.trim(),
    ];

    // Valider que les mots interdits sont uniques et remplis
    if (!_validateForbiddenWords(forbidden1, 'Challenge 1') ||
        !_validateForbiddenWords(forbidden2, 'Challenge 2') ||
        !_validateForbiddenWords(forbidden3, 'Challenge 3')) {
      return;
    }

    // Envoyer les 3 challenges
    bool allSuccess = true;

    // Challenge 1
    final success1 = await challengeProvider.sendChallenge(
      sessionId: sessionId,
      firstWord: _ch1_word1 ?? '',
      secondWord: _ch1_word2.text.trim(),
      thirdWord: _ch1_word3 ?? '',
      fourthWord: _ch1_word4 ?? '',
      fifthWord: _ch1_word5.text.trim(),
      forbiddenWords: forbidden1,
    );
    allSuccess = allSuccess && success1;

    if (!success1 || !mounted) return;

    // Challenge 2
    final success2 = await challengeProvider.sendChallenge(
      sessionId: sessionId,
      firstWord: _ch2_word1 ?? '',
      secondWord: _ch2_word2.text.trim(),
      thirdWord: _ch2_word3 ?? '',
      fourthWord: _ch2_word4 ?? '',
      fifthWord: _ch2_word5.text.trim(),
      forbiddenWords: forbidden2,
    );
    allSuccess = allSuccess && success2;

    if (!success2 || !mounted) return;

    // Challenge 3
    final success3 = await challengeProvider.sendChallenge(
      sessionId: sessionId,
      firstWord: _ch3_word1 ?? '',
      secondWord: _ch3_word2.text.trim(),
      thirdWord: _ch3_word3 ?? '',
      fourthWord: _ch3_word4 ?? '',
      fifthWord: _ch3_word5.text.trim(),
      forbiddenWords: forbidden3,
    );
    allSuccess = allSuccess && success3;

    if (allSuccess && mounted) {
      setState(() {
        _submitted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Les 3 challenges ont été envoyés ! En attente des autres joueurs...',
          ),
          duration: Duration(seconds: 3),
        ),
      );

      // Démarrer le polling pour attendre les autres joueurs
      print('🎮 PICTONARY ⏳ [WAIT] En attente des autres joueurs...');
      _startWaitingForOthers();
    } else if (mounted && challengeProvider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(challengeProvider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final challengeProvider = context.watch<ChallengeProvider>();
    final gameProvider = context.watch<GameProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Phase Challenge - 3 phrases à créer')),
      body: _submitted
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green[50]!, Colors.white],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 120,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        '✅ Vos 3 challenges ont été envoyés !',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'En attente des autres joueurs...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'La phase de dessin commencera dès que tous les joueurs auront envoyé leurs challenges.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Vérification toutes les 3 secondes...',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Joueur: ${authProvider.currentPlayer?.name ?? ""}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Session: ${gameProvider.currentSession?.id ?? ""}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Bouton de test
                    OutlinedButton.icon(
                      onPressed: _fillWithTestData,
                      icon: const Icon(Icons.science),
                      label: const Text('Remplir avec des données de test'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Créez 3 phrases de 5 mots chacune. Les autres joueurs devront les deviner à partir d\'images générées.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Challenge 1
                    _buildChallengeCard(
                      '1',
                      _ch1_word1,
                      (v) => setState(() => _ch1_word1 = v),
                      _ch1_word2,
                      _ch1_word3,
                      (v) => setState(() => _ch1_word3 = v),
                      _ch1_word4,
                      (v) => setState(() => _ch1_word4 = v),
                      _ch1_word5,
                      _ch1_forbidden1,
                      _ch1_forbidden2,
                      _ch1_forbidden3,
                    ),
                    const SizedBox(height: 20),

                    // Challenge 2
                    _buildChallengeCard(
                      '2',
                      _ch2_word1,
                      (v) => setState(() => _ch2_word1 = v),
                      _ch2_word2,
                      _ch2_word3,
                      (v) => setState(() => _ch2_word3 = v),
                      _ch2_word4,
                      (v) => setState(() => _ch2_word4 = v),
                      _ch2_word5,
                      _ch2_forbidden1,
                      _ch2_forbidden2,
                      _ch2_forbidden3,
                    ),
                    const SizedBox(height: 20),

                    // Challenge 3
                    _buildChallengeCard(
                      '3',
                      _ch3_word1,
                      (v) => setState(() => _ch3_word1 = v),
                      _ch3_word2,
                      _ch3_word3,
                      (v) => setState(() => _ch3_word3 = v),
                      _ch3_word4,
                      (v) => setState(() => _ch3_word4 = v),
                      _ch3_word5,
                      _ch3_forbidden1,
                      _ch3_forbidden2,
                      _ch3_forbidden3,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: challengeProvider.isLoading
                          ? null
                          : _submitAllChallenges,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: challengeProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Envoyer les 3 challenges',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildChallengeCard(
    String number,
    String? word1,
    void Function(String?) onWord1Changed,
    TextEditingController word2Controller,
    String? word3,
    void Function(String?) onWord3Changed,
    String? word4,
    void Function(String?) onWord4Changed,
    TextEditingController word5Controller,
    TextEditingController forbidden1,
    TextEditingController forbidden2,
    TextEditingController forbidden3,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenge $number',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Phrase de 5 mots :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDropdownField('Mot 1', word1, _word1Options, onWord1Changed),
            const SizedBox(height: 10),
            _buildWordField('Mot 2', word2Controller),
            const SizedBox(height: 10),
            _buildDropdownField('Mot 3', word3, _word3Options, onWord3Changed),
            const SizedBox(height: 10),
            _buildDropdownField('Mot 4', word4, _word4Options, onWord4Changed),
            const SizedBox(height: 10),
            _buildWordField('Mot 5', word5Controller),
            const SizedBox(height: 20),
            const Text(
              'Mots interdits :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildWordField('Mot interdit 1', forbidden1),
            const SizedBox(height: 10),
            _buildWordField('Mot interdit 2', forbidden2),
            const SizedBox(height: 10),
            _buildWordField('Mot interdit 3', forbidden3),
          ],
        ),
      ),
    );
  }

  Widget _buildWordField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ce champ est requis';
        }
        if (value.trim().split(' ').length > 1) {
          return 'Un seul mot autorisé';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(
    String label,
    String? currentValue,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.blue[50],
      ),
      items: options.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une valeur';
        }
        return null;
      },
    );
  }
}
