import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class AdminGuard extends StatefulWidget {
  final Widget child;
  final String? fallbackRoute;

  const AdminGuard({Key? key, required this.child, this.fallbackRoute})
    : super(key: key);

  @override
  State<AdminGuard> createState() => _AdminGuardState();
}

class _AdminGuardState extends State<AdminGuard> {
  bool _isCheckingRoles = false;
  bool _hasAdminRole = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    setState(() {
      _isCheckingRoles = true;
      _errorMessage = null;
    });

    try {
      // Attendre un peu pour s'assurer que les rôles sont chargés
      await Future.delayed(const Duration(milliseconds: 200));

      // Vérifier à nouveau l'état d'authentification
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (!authProvider.isAuthenticated || authProvider.user == null) {
        developer.log('AdminGuard - Utilisateur non authentifié');
        setState(() {
          _isCheckingRoles = false;
          _hasAdminRole = false;
        });
        return;
      }

      final user = authProvider.user!;
      developer.log('AdminGuard - Utilisateur trouvé: ${user.email}');
      developer.log(
        'AdminGuard - Rôles actuels: ${user.roles?.map((r) => '${r.id}:${r.name}').toList()}',
      );

      // Si les rôles ne sont pas chargés, forcer le rechargement du profil
      if (user.roles == null || user.roles!.isEmpty) {
        developer.log(
          'AdminGuard - Rôles non chargés, rechargement du profil...',
        );
        try {
          await authProvider.refreshProfile();

          // Attendre un peu après le rechargement
          await Future.delayed(const Duration(milliseconds: 100));

          // Vérifier à nouveau après le rechargement
          if (authProvider.user == null) {
            developer.log('AdminGuard - Utilisateur perdu après rechargement');
            setState(() {
              _isCheckingRoles = false;
              _hasAdminRole = false;
            });
            return;
          }
        } catch (e) {
          developer.log('AdminGuard - Erreur lors du rechargement: $e');
          setState(() {
            _isCheckingRoles = false;
            _hasAdminRole = false;
            _errorMessage = 'Erreur lors du chargement des rôles: $e';
          });
          return;
        }
      }

      // Récupérer l'utilisateur mis à jour
      final updatedUser = authProvider.user!;
      developer.log(
        'AdminGuard - Rôles après rechargement: ${updatedUser.roles?.map((r) => '${r.id}:${r.name}').toList()}',
      );

      // Vérification plus robuste des rôles admin
      final hasAdminRole =
          updatedUser.roles != null &&
          updatedUser.roles!.isNotEmpty &&
          updatedUser.roles!.any(
            (role) =>
                role.name.toLowerCase() == 'admin' ||
                role.name.toLowerCase() == 'administrator' ||
                role.name.toLowerCase() == 'superadmin',
          );

      developer.log('AdminGuard - A le rôle admin: $hasAdminRole');

      setState(() {
        _isCheckingRoles = false;
        _hasAdminRole = hasAdminRole;
      });

      // Si pas de rôle admin, naviguer vers la route de fallback
      if (!hasAdminRole) {
        developer.log('AdminGuard - Pas de rôle admin, redirection...');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.fallbackRoute != null) {
            Navigator.of(context).pushReplacementNamed(widget.fallbackRoute!);
          } else {
            Navigator.of(context).pop(); // Retour à l'écran précédent
          }
        });
      }
    } catch (e) {
      developer.log('AdminGuard - Erreur lors de la vérification: $e');
      setState(() {
        _isCheckingRoles = false;
        _hasAdminRole = false;
        _errorMessage = 'Erreur lors de la vérification des permissions: $e';
      });
    }
  }

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

        // Vérifier si l'utilisateur existe
        if (authProvider.user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Afficher l'indicateur de chargement pendant la vérification des rôles
        if (_isCheckingRoles) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Vérification des permissions...'),
                ],
              ),
            ),
          );
        }

        // Afficher l'erreur si il y en a une
        if (_errorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Erreur de permissions'),
              automaticallyImplyLeading: false,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de vérification',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkAdminRole,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        // Si l'utilisateur n'a pas le rôle admin
        if (!_hasAdminRole) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Accès refusé'),
              automaticallyImplyLeading: false,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Accès refusé',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Vous n\'avez pas les permissions nécessaires\npour accéder à cette page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // L'utilisateur est admin, afficher le contenu
        return widget.child;
      },
    );
  }
}
