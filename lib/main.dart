import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/users_provider.dart';
import 'widgets/auth_dropdown.dart';
import 'widgets/loading_widget.dart';
import 'routes/app_router.dart';
import 'utils/constants.dart';
import 'config/app_config.dart';

void main() {
  // Initialiser la configuration selon l'environnement
  AppConfig.initialize(Environment.development);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          useMaterial3: true,
        ),
        initialRoute: AppRouter.initialRoute,
        onGenerateRoute: AppRouter.generateRoute,
        home: const MyHomePage(title: 'VISIO'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [const AuthDropdown()],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.state == AuthState.initial ||
              authProvider.isLoading) {
            return const FullScreenLoading(message: 'Initialisation...');
          }

          if (authProvider.isAuthenticated) {
            return _buildAuthenticatedContent(authProvider);
          } else {
            return _buildUnauthenticatedContent();
          }
        },
      ),
    );
  }

  Widget _buildAuthenticatedContent(AuthProvider authProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          Text(
            'Bienvenue, ${authProvider.user?.fullName ?? 'Utilisateur'} !',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            authProvider.user?.email ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Vous êtes maintenant connecté à Visio',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Bienvenue sur Visio',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Connectez-vous pour accéder à toutes les fonctionnalités',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Le dropdown gère la navigation
            },
            icon: const Icon(Icons.login),
            label: const Text('Se connecter'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
