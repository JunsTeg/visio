import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/users_service.dart';

enum UsersState { initial, loading, loaded, error }

class UsersProvider with ChangeNotifier {
  final UsersService _usersService = UsersService();

  UsersState _state = UsersState.initial;
  List<User> _users = [];
  String? _errorMessage;
  bool _isLoading = false;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 0;
  int _totalUsers = 0;
  int _limit = 20;

  // Filtres
  String? _searchQuery;
  String? _roleFilter;
  String? _activeFilter;
  String? _onlineFilter;

  // Getters
  UsersState get state => _state;
  List<User> get users => _users;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalUsers => _totalUsers;
  int get limit => _limit;
  String? get searchQuery => _searchQuery;
  String? get roleFilter => _roleFilter;
  String? get activeFilter => _activeFilter;
  String? get onlineFilter => _onlineFilter;

  // Charger la liste des utilisateurs
  Future<void> loadUsers({bool refresh = false}) async {
    try {
      _setLoading(true);
      _clearError();

      if (refresh) {
        _currentPage = 1;
      }

      final result = await _usersService.getUsers(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery,
        role: _roleFilter,
        active: _activeFilter,
        online: _onlineFilter,
      );

      if (refresh) {
        _users = result['data'] as List<User>;
      } else {
        _users.addAll(result['data'] as List<User>);
      }

      _totalUsers = result['total'] as int;
      _totalPages = (_totalUsers / _limit).ceil();

      _setLoaded();
    } catch (e) {
      _setError('Erreur lors du chargement des utilisateurs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Charger la page suivante
  Future<void> loadNextPage() async {
    if (_currentPage < _totalPages && !_isLoading) {
      _currentPage++;
      await loadUsers();
    }
  }

  // Rechercher
  Future<void> search(String query) async {
    _searchQuery = query.isEmpty ? null : query;
    await loadUsers(refresh: true);
  }

  // Filtrer par rôle
  Future<void> filterByRole(String? role) async {
    _roleFilter = role;
    await loadUsers(refresh: true);
  }

  // Filtrer par statut actif
  Future<void> filterByActive(String? active) async {
    _activeFilter = active;
    await loadUsers(refresh: true);
  }

  // Filtrer par statut online
  Future<void> filterByOnline(String? online) async {
    _onlineFilter = online;
    await loadUsers(refresh: true);
  }

  // Réinitialiser les filtres
  Future<void> resetFilters() async {
    _searchQuery = null;
    _roleFilter = null;
    _activeFilter = null;
    _onlineFilter = null;
    await loadUsers(refresh: true);
  }

  // Désactiver un utilisateur
  Future<bool> deactivateUser(String userId) async {
    try {
      await _usersService.deactivateUser(userId);
      // Recharger la liste pour refléter les changements
      await loadUsers(refresh: true);
      return true;
    } catch (e) {
      _setError('Erreur lors de la désactivation: $e');
      return false;
    }
  }

  // Réactiver un utilisateur
  Future<bool> activateUser(String userId) async {
    try {
      await _usersService.activateUser(userId);
      // Recharger la liste pour refléter les changements
      await loadUsers(refresh: true);
      return true;
    } catch (e) {
      _setError('Erreur lors de la réactivation: $e');
      return false;
    }
  }

  // Méthodes privées pour gérer l'état
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _state = UsersState.loading;
    }
    notifyListeners();
  }

  void _setLoaded() {
    _state = UsersState.loaded;
    _clearError();
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = UsersState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == UsersState.error) {
      _state = UsersState.initial;
    }
  }

  // Effacer les erreurs manuellement
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
