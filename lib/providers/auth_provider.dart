import 'package:flutter/foundation.dart';
//import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialiser l'état d'authentification au démarrage
  Future<void> _initializeAuth() async {
    try {
      _setLoading(true);
      final isAuth = await _authService.isAuthenticated();

      if (isAuth) {
        final user = await _authService.getProfile();
        _setAuthenticated(user);
      } else {
        _setUnauthenticated();
      }
    } catch (e) {
      _setError('Erreur lors de l\'initialisation: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);

      _setAuthenticated(response.user);
      return true;
    } catch (e) {
      _setError('Erreur de connexion: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Inscription
  Future<bool> register(
    String fullName,
    String email,
    String password,
    String? phoneNumber,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final request = RegisterRequest(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      final response = await _authService.register(request);
      _setAuthenticated(response.user);
      return true;
    } catch (e) {
      _setError('Erreur d\'inscription: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authService.logout();
      _setUnauthenticated();
    } catch (e) {
      _setError('Erreur de déconnexion: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Rafraîchissement du token
  Future<bool> refreshToken() async {
    try {
      final response = await _authService.refreshToken();
      _setAuthenticated(response.user);
      return true;
    } catch (e) {
      _setError('Erreur de rafraîchissement: $e');
      _setUnauthenticated();
      return false;
    }
  }

  // Mettre à jour le profil utilisateur
  Future<void> updateProfile() async {
    try {
      if (_user != null) {
        final updatedUser = await _authService.getProfile();
        _setAuthenticated(updatedUser);
      }
    } catch (e) {
      _setError('Erreur de mise à jour du profil: $e');
    }
  }

  // Méthodes privées pour gérer l'état
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _state = AuthState.loading;
    }
    notifyListeners();
  }

  void _setAuthenticated(User user) {
    _user = user;
    _state = AuthState.authenticated;
    _clearError();
    notifyListeners();
  }

  void _setUnauthenticated() {
    _user = null;
    _state = AuthState.unauthenticated;
    _clearError();
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state =
          _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
  }

  // Effacer les erreurs manuellement
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
