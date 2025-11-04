import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/challenge_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/join_game_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/challenge_screen.dart';
import 'screens/drawing_screen.dart';
import 'utils/logger.dart';

Future<void> main() async {
  // IMPORTANT : Initialiser les bindings Flutter avant toute opération async
  WidgetsFlutterBinding.ensureInitialized();
  
  AppLogger.info('🚀 Démarrage de l\'application Pictonary');
  
  // Charger le fichier .env
  AppLogger.info('📄 Chargement du fichier .env...');
  await dotenv.load(fileName: '.env');
  AppLogger.success('✅ Configuration chargée: ${dotenv.env['API_BASE_URL']}');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    // Charger le token au démarrage
    apiService.loadToken();

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(apiService)..initialize(),
        ),
        ChangeNotifierProvider<GameProvider>(
          create: (_) => GameProvider(apiService),
        ),
        ChangeNotifierProvider<ChallengeProvider>(
          create: (_) => ChallengeProvider(apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Pictonary',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/join': (context) => const JoinGameScreen(),
          '/lobby': (context) => const LobbyScreen(),
          '/challenge': (context) => const ChallengeScreen(),
          '/drawing': (context) => const DrawingScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        AppLogger.navigation(
          'AuthWrapper - isLoading: ${authProvider.isLoading}, '
          'isAuthenticated: ${authProvider.isAuthenticated}',
        );

        // Afficher un écran de chargement pendant l'initialisation
        if (authProvider.isLoading) {
          AppLogger.navigation('Affichage écran de chargement');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Rediriger vers l'écran approprié en fonction de l'état d'authentification
        if (authProvider.isAuthenticated) {
          AppLogger.navigation('Navigation vers HomeScreen');
          return const HomeScreen();
        } else {
          AppLogger.navigation('Navigation vers LoginScreen');
          return const LoginScreen();
        }
      },
    );
  }
}
