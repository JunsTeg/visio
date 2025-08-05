import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_router.dart';
import '../utils/constants.dart';

class AuthDropdown extends StatelessWidget {
  const AuthDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (authProvider.isAuthenticated) {
          return _buildAuthenticatedDropdown(context, authProvider);
        } else {
          return _buildUnauthenticatedDropdown(context);
        }
      },
    );
  }

  Widget _buildAuthenticatedDropdown(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle),
      tooltip: 'Menu utilisateur',
      onSelected:
          (value) =>
              _handleAuthenticatedMenuSelection(context, value, authProvider),
      itemBuilder:
          (context) => [
            // En-tête avec les infos utilisateur
            PopupMenuItem<String>(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.user?.fullName ?? 'Utilisateur',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authProvider.user?.email ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Divider(),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 8),
                  Text('Mon profil'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 8),
                  Text('Paramètres'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Se déconnecter', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
    );
  }

  Widget _buildUnauthenticatedDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle_outlined),
      tooltip: 'Menu d\'authentification',
      onSelected:
          (value) => _handleUnauthenticatedMenuSelection(context, value),
      itemBuilder:
          (context) => [
            const PopupMenuItem<String>(
              value: 'login',
              child: Row(
                children: [
                  Icon(Icons.login, size: 20),
                  SizedBox(width: 8),
                  Text('Se connecter'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'register',
              child: Row(
                children: [
                  Icon(Icons.person_add, size: 20),
                  SizedBox(width: 8),
                  Text('S\'inscrire'),
                ],
              ),
            ),
          ],
    );
  }

  void _handleAuthenticatedMenuSelection(
    BuildContext context,
    String value,
    AuthProvider authProvider,
  ) {
    switch (value) {
      case 'profile':
        // TODO: Naviguer vers la page de profil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Page de profil à implémenter')),
        );
        break;
      case 'settings':
        // TODO: Naviguer vers les paramètres
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Page des paramètres à implémenter')),
        );
        break;
      case 'logout':
        _showLogoutDialog(context, authProvider);
        break;
    }
  }

  void _handleUnauthenticatedMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'login':
        AppRouter.navigateToLogin(context);
        break;
      case 'register':
        AppRouter.navigateToRegister(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(AppConstants.logoutSuccessMessage),
                      backgroundColor: AppConstants.successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );
  }
}
