import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnly({Key? key, required this.child, this.fallback})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Vérifier si l'utilisateur est connecté et a le rôle admin
        if (!authProvider.isAuthenticated || authProvider.user == null) {
          return fallback ?? const SizedBox.shrink();
        }

        final hasAdminRole =
            authProvider.user!.roles?.any(
              (role) => role.name.toLowerCase() == 'admin',
            ) ??
            false;

        if (!hasAdminRole) {
          return fallback ?? const SizedBox.shrink();
        }

        // L'utilisateur est admin, afficher le contenu
        return child;
      },
    );
  }
}
