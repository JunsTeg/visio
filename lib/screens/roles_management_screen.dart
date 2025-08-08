import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/users_service.dart';

class RolesManagementScreen extends StatefulWidget {
  const RolesManagementScreen({Key? key}) : super(key: key);

  @override
  State<RolesManagementScreen> createState() => _RolesManagementScreenState();
}

class _RolesManagementScreenState extends State<RolesManagementScreen> {
  final UsersService _usersService = UsersService();

  List<Role> _roles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final roles = await _usersService.getRoles();
      setState(() {
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des rôles'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRoles),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erreur: $_errorMessage'),
            ElevatedButton(
              onPressed: _loadRoles,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_roles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun rôle disponible',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Les rôles sont gérés côté serveur',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _roles.length,
      itemBuilder: (context, index) {
        final role = _roles[index];
        return _buildRoleCard(role);
      },
    );
  }

  Widget _buildRoleCard(Role role) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role.name),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: ${role.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (role.description != null && role.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                role.description!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            _buildRolePermissions(role),
          ],
        ),
      ),
    );
  }

  Widget _buildRolePermissions(Role role) {
    // Définir les permissions par rôle (à adapter selon votre logique métier)
    final permissions = _getRolePermissions(role.name);

    if (permissions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Permissions :',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children:
              permissions.map((permission) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    permission,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'seller':
        return Colors.orange;
      case 'user':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  List<String> _getRolePermissions(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return [
          'Gestion utilisateurs',
          'Gestion rôles',
          'Accès complet',
          'Modération',
        ];
      case 'seller':
        return ['Gestion produits', 'Gestion commandes', 'Ventes'];
      case 'user':
        return ['Achat', 'Profil personnel', 'Historique commandes'];
      default:
        return [];
    }
  }
}
