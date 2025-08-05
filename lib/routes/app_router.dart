import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../utils/constants.dart';

class AppRouter {
  static const String initialRoute = AppConstants.homeRoute;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppConstants.registerRoute:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      // TODO: Ajouter d'autres routes ici
      // case AppConstants.profileRoute:
      //   return MaterialPageRoute(
      //     builder: (_) => const ProfileScreen(),
      //     settings: settings,
      //   );

      default:
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Page non trouvée',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'La route "${settings.name}" n\'existe pas',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Retour'),
                      ),
                    ],
                  ),
                ),
              ),
        );
    }
  }

  // Méthodes utilitaires pour la navigation
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamed(AppConstants.loginRoute);
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.of(context).pushNamed(AppConstants.registerRoute);
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.of(context).pushNamed(AppConstants.profileRoute);
  }

  static void navigateToSettings(BuildContext context) {
    Navigator.of(context).pushNamed(AppConstants.settingsRoute);
  }

  // Navigation avec remplacement (pour éviter les piles de navigation)
  static void navigateToLoginReplacement(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
  }

  static void navigateToRegisterReplacement(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppConstants.registerRoute);
  }

  // Navigation avec suppression de toutes les routes précédentes
  static void navigateToHome(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppConstants.homeRoute, (route) => false);
  }
}
