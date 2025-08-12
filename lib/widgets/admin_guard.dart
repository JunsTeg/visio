import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;
  final String? fallbackRoute;

  const AdminGuard({Key? key, required this.child, this.fallbackRoute})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Vérifier si l'utilisateur est connecté
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Vérifier si l'utilisateur a le rôle admin
        final user = authProvider.user;
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasAdminRole =
            user.roles?.any((role) => role.name.toLowerCase() == 'admin') ??
            false;

        if (!hasAdminRole) {
          // Rediriger vers la route de fallback ou afficher une page d'erreur
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (fallbackRoute != null) {
              Navigator.of(context).pushReplacementNamed(fallbackRoute!);
            } else {
              Navigator.of(context).pop(); // Retour à l'écran précédent
            }
          });
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Accès refusé',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Vous n\'avez pas les permissions nécessaires',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // L'utilisateur est admin, afficher le contenu
        return child;
      },
    );
  }
}
