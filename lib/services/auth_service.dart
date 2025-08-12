import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_client.dart';
import 'network_service.dart';
import 'cache_service.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  // Utiliser la configuration dynamique au lieu d'une URL statique
  String get baseUrl => AppConstants.baseUrl;

  // Connexion
  Future<AuthResponse> login(LoginRequest request) async {
    // Vérifier la connectivité réseau
    if (!await NetworkService.isConnected()) {
      throw Exception(AppConstants.networkErrorMessage);
    }

    return NetworkService.retryWithBackoff(() async {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/auth/login'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(request.toJson()),
            )
            .timeout(AppConstants.connectionTimeout);

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('DEBUG: Connexion réussie - Status: ${response.statusCode}');
          print('DEBUG: Body: ${response.body}');

          try {
            final authResponse = AuthResponse.fromJson(
              jsonDecode(response.body),
            );

            // Sauvegarder les tokens
            await _apiClient.saveTokens(
              authResponse.accessToken,
              authResponse.refreshToken,
            );

            // Mettre en cache les données utilisateur
            await CacheService.cacheUser(authResponse.user.toJson());

            return authResponse;
          } catch (parseError) {
            print('DEBUG: Erreur de parsing JSON: $parseError');
            print('DEBUG: Body reçu: ${response.body}');
            throw Exception(
              'Erreur de parsing de la réponse du serveur: $parseError',
            );
          }
        } else {
          final errorMessage = NetworkService.handleHttpError(response);
          throw Exception(errorMessage);
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception(NetworkService.handleNetworkException(e));
      }
    });
  }

  // Inscription
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));

        // Sauvegarder les tokens
        await _apiClient.saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken,
        );

        return authResponse;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur d\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      final token = await _apiClient.getAccessToken();
      if (token != null) {
        await http
            .post(
              Uri.parse('$baseUrl/auth/logout'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(AppConstants.connectionTimeout);
      }
    } catch (e) {
      // Ignorer les erreurs de déconnexion
      print('Erreur lors de la déconnexion: $e');
    } finally {
      // Toujours supprimer les tokens locaux et le cache
      await _apiClient.clearTokens();
      await CacheService.removeData('user_cache');
    }
  }

  // Rafraîchissement du token
  Future<AuthResponse> refreshToken() async {
    try {
      final refreshToken = await _apiClient.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('Aucun token de rafraîchissement disponible');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));

        // Sauvegarder les nouveaux tokens
        await _apiClient.saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken,
        );

        return authResponse;
      } else {
        throw Exception('Erreur de rafraîchissement du token');
      }
    } catch (e) {
      throw Exception('Erreur de rafraîchissement: $e');
    }
  }

  // Obtenir le profil utilisateur
  Future<User> getProfile() async {
    // Essayer d'abord le cache
    final cachedUser = await CacheService.getCachedUser();
    if (cachedUser != null) {
      try {
        return User.fromJson(cachedUser);
      } catch (e) {
        // Si le cache est corrompu, le supprimer
        await CacheService.removeData('user_cache');
      }
    }

    // Vérifier la connectivité réseau
    if (!await NetworkService.isConnected()) {
      throw Exception(AppConstants.networkErrorMessage);
    }

    return NetworkService.retryWithBackoff(() async {
      try {
        final response = await _apiClient
            .get('/auth/profile')
            .timeout(AppConstants.connectionTimeout);

        if (response.statusCode == 200) {
          final user = User.fromJson(jsonDecode(response.body));

          // Mettre en cache les nouvelles données
          await CacheService.cacheUser(user.toJson());

          return user;
        } else {
          final errorMessage = NetworkService.handleHttpError(response);
          throw Exception(errorMessage);
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception(NetworkService.handleNetworkException(e));
      }
    });
  }

  // Mettre à jour le profil utilisateur (PUT /users/me)
  Future<User> updateProfileMe(Map<String, dynamic> data) async {
    // Vérifier la connectivité réseau
    if (!await NetworkService.isConnected()) {
      throw Exception(AppConstants.networkErrorMessage);
    }
    return NetworkService.retryWithBackoff(() async {
      try {
        final response = await _apiClient
            .put('/users/me', data)
            .timeout(AppConstants.connectionTimeout);
        if (response.statusCode == 200) {
          final user = User.fromJson(jsonDecode(response.body));
          await CacheService.cacheUser(user.toJson());
          return user;
        } else {
          final errorMessage = NetworkService.handleHttpError(response);
          throw Exception(errorMessage);
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception(NetworkService.handleNetworkException(e));
      }
    });
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    final token = await _apiClient.getAccessToken();
    return token != null;
  }

  // Méthode pour obtenir le token d'accès
  Future<String?> getAccessToken() async {
    return await _apiClient.getAccessToken();
  }

  // Méthode pour obtenir le token de rafraîchissement
  Future<String?> getRefreshToken() async {
    return await _apiClient.getRefreshToken();
  }
}
