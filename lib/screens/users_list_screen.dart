import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/users_provider.dart';
import '../models/user.dart';
//import '../utils/constants.dart';
import '../routes/app_router.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Charger les utilisateurs quand les dépendances changent
    _loadUsersIfNeeded();
  }

  void _loadUsersIfNeeded() {
    // Utiliser un délai pour s'assurer que le provider est disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final usersProvider = Provider.of<UsersProvider>(
            context,
            listen: false,
          );
          if (usersProvider.users.isEmpty &&
              usersProvider.state == UsersState.initial) {
            usersProvider.loadUsers(refresh: true);
          }
        } catch (e) {
          // Le provider n'est pas encore disponible, on réessaiera plus tard
          print('UsersProvider pas encore disponible: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      try {
        Provider.of<UsersProvider>(context, listen: false).loadNextPage();
      } catch (e) {
        // Le provider n'est pas disponible, ignorer
        print('UsersProvider pas disponible dans _onScroll: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Charger les utilisateurs au premier build si nécessaire
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final usersProvider = Provider.of<UsersProvider>(
            context,
            listen: false,
          );
          if (usersProvider.users.isEmpty &&
              usersProvider.state == UsersState.initial) {
            usersProvider.loadUsers(refresh: true);
          }
        } catch (e) {
          // Le provider n'est pas encore disponible
          print('UsersProvider pas encore disponible dans build: $e');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilisateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.security),
            tooltip: 'Gestion des rôles',
            onPressed: () {
              AppRouter.navigateToRolesManagement(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              AppRouter.navigateToUserCreate(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Consumer<UsersProvider>(
              builder: (context, usersProvider, child) {
                if (usersProvider.state == UsersState.initial) {
                  return const Center(child: Text('Aucun utilisateur trouvé'));
                }

                if (usersProvider.state == UsersState.loading &&
                    usersProvider.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (usersProvider.state == UsersState.error &&
                    usersProvider.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Erreur: ${usersProvider.errorMessage}'),
                        ElevatedButton(
                          onPressed:
                              () => usersProvider.loadUsers(refresh: true),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildUsersList(usersProvider),
                    if (usersProvider.isLoading &&
                        usersProvider.users.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher par nom ou email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  Provider.of<UsersProvider>(context, listen: false).search('');
                },
              ),
            ),
            onSubmitted: (query) {
              Provider.of<UsersProvider>(context, listen: false).search(query);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Rôle',
                  ['Tous', 'admin', 'user', 'seller'],
                  (value) {
                    final role = value == 'Tous' ? null : value;
                    Provider.of<UsersProvider>(
                      context,
                      listen: false,
                    ).filterByRole(role);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown(
                  'Statut',
                  ['Tous', 'Actif', 'Inactif'],
                  (value) {
                    String? active;
                    if (value == 'Actif') active = 'true';
                    if (value == 'Inactif') active = 'false';
                    Provider.of<UsersProvider>(
                      context,
                      listen: false,
                    ).filterByActive(active);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: 'Tous',
      items:
          options.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildUsersList(UsersProvider usersProvider) {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: usersProvider.users.length,
        itemBuilder: (context, index) {
          final user = usersProvider.users[index];
          return _buildUserCard(user, usersProvider);
        },
      ),
    );
  }

  Widget _buildUserCard(User user, UsersProvider usersProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(child: Text(user.fullName[0].toUpperCase())),
        title: Text(user.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            if (user.roles != null && user.roles!.isNotEmpty)
              Text(
                'Rôles: ${user.roles!.map((r) => r.name).join(', ')}',
                style: const TextStyle(fontSize: 12),
              ),
            Row(
              children: [
                Icon(
                  user.active == true ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: user.active == true ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  user.active == true ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    fontSize: 12,
                    color: user.active == true ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  user.online == true ? Icons.circle : Icons.circle_outlined,
                  size: 16,
                  color: user.online == true ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  user.online == true ? 'En ligne' : 'Hors ligne',
                  style: TextStyle(
                    fontSize: 12,
                    color: user.online == true ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user, usersProvider),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('Voir'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: user.active == true ? 'deactivate' : 'activate',
                  child: Row(
                    children: [
                      Icon(
                        user.active == true ? Icons.block : Icons.check_circle,
                      ),
                      const SizedBox(width: 8),
                      Text(user.active == true ? 'Désactiver' : 'Réactiver'),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () {
          AppRouter.navigateToUserDetail(context, user.id);
        },
      ),
    );
  }

  void _handleUserAction(
    String action,
    User user,
    UsersProvider usersProvider,
  ) {
    switch (action) {
      case 'view':
        AppRouter.navigateToUserDetail(context, user.id);
        break;
      case 'edit':
        AppRouter.navigateToUserEdit(context, user.id);
        break;
      case 'deactivate':
        _showConfirmDialog(
          'Désactiver l\'utilisateur',
          'Êtes-vous sûr de vouloir désactiver ${user.fullName} ?',
          () => usersProvider.deactivateUser(user.id),
        );
        break;
      case 'activate':
        _showConfirmDialog(
          'Réactiver l\'utilisateur',
          'Êtes-vous sûr de vouloir réactiver ${user.fullName} ?',
          () => usersProvider.activateUser(user.id),
        );
        break;
    }
  }

  void _showConfirmDialog(
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                child: const Text('Confirmer'),
              ),
            ],
          ),
    );
  }
}
