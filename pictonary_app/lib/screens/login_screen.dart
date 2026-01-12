import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/logger.dart';
import '../widgets/notebook_background.dart';
import '../widgets/doodle_button.dart';
import '../widgets/doodle_card.dart';
import '../theme/doodle_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    AppLogger.navigation('LoginScreen affiché');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    AppLogger.auth(
      '📝 Soumission du formulaire (${_isLogin ? "login" : "register"})',
    );

    if (!_formKey.currentState!.validate()) {
      AppLogger.auth('❌ Validation formulaire échouée');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    bool success;

    if (_isLogin) {
      success = await authProvider.login(
        _nameController.text,
        _passwordController.text,
      );
    } else {
      success = await authProvider.register(
        _nameController.text,
        _passwordController.text,
      );
    }

    AppLogger.auth('Résultat: success=$success, mounted=$mounted');

    if (success && mounted) {
      AppLogger.navigation('Navigation vers /home');
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      AppLogger.error('Échec de la connexion/inscription');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoodleTheme.skyBlue,
      appBar: AppBar(
        title: Text(_isLogin ? '🎮 Connexion' : '✨ Inscription'),
        centerTitle: true,
      ),
      body: NotebookBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo avec style dessiné
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: DoodleTheme.sunYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: DoodleTheme.inkBlack, width: 3),
                ),
                child: const Icon(
                  Icons.brush,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pictonary',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: DoodleTheme.inkBlack,
                      shadows: [
                        Shadow(
                          offset: const Offset(3, 3),
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 32),
              // Card avec formulaire
              DoodleCard(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '👤 Nom d\'utilisateur',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: '🔒 Mot de passe',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          if (!_isLogin && value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Messages d'erreur
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.error != null) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: DoodleTheme.teamRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DoodleTheme.teamRed, width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: DoodleTheme.teamRed),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authProvider.error!,
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
              // Boutons
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.isLoading) {
                    return const CircularProgressIndicator();
                  }
                  return Column(
                    children: [
                      DoodleButton(
                        text: _isLogin ? 'Se connecter' : 'S\'inscrire',
                        onPressed: _submit,
                        color: DoodleTheme.grassGreen,
                        icon: _isLogin ? Icons.login : Icons.person_add,
                      ),
                      const SizedBox(height: 16),
                      DoodleButton(
                        text: _isLogin
                            ? 'Pas de compte ? S\'inscrire'
                            : 'Déjà un compte ? Se connecter',
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        color: DoodleTheme.cloudWhite,
                        isPrimary: false,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
