import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_client.dart';
import 'network_service.dart';

class UsersService {
  final ApiClient _apiClient = ApiClient();
  String get baseUrl => AppConstants.baseUrl;

  // Lister tous les utilisateurs avec pagination et filtres
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    String? active,
    String? online,
  }) async {
    if (!await NetworkService.isConnected()) {
      throw Exception(AppConstants.networkErrorMessage);
    }

    return NetworkService.retryWithBackoff(() async {
      try {
        final queryParams = <String, String>{
          'page': page.toString(),
          'limit': limit.toString(),
        };

        if (search != null && search.isNotEmpty) {
          queryParams['search'] = search;
        }
        if (role != null && role.isNotEmpty) {
          queryParams['role'] = role;
        }
        if (active != null && active.isNotEmpty) {
          queryParams['active'] = active;
        }
        if (online != null && online.isNotEmpty) {
          queryParams['online'] = online;
        }

        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');

        final response = await _apiClient
            .get('/users?$queryString')
            .timeout(AppConstants.connectionTimeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return {
            'data':
                (data['data'] as List)
                    .map((userJson) => User.fromJson(userJson))
                    .toList(),
            'total': data['total'],
            'page': data['page'],
            'limit': data['limit'],
          };
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

  // Obtenir le détail d'un utilisateur
  Future<User> getUser(String id) async {
    if (!await NetworkService.isConnected()) {
      throw Exception(AppConstants.networkErrorMessage);
    }

    return NetworkService.retryWithBackoff(() async {
      try {
        final response = await _apiClient
            .get('/users/$id')
            .timeout(AppConstants.connectionTimeout);

        if (response.statusCode == 200) {
          return User.fromJson(jsonDecode(response.body));
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

  // Créer un utilisateur
  Future<User> createUser(Map<String, dynamic> data) async {
    if (!await NetworkService.isConnected()) {
      throw Exception(AppConstants.networkErrorMessage);
    }

    return NetworkService.retryWithBackoff(() async {
      try {
        final response = await _apiClient
            .post('/users', data)
            .timeout(AppConstants.connectionTimeout);

        if (response.statusCode == 201) {
          return User.fromJson(jsonDecode(response.body));
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

  // Mettre à jour un utilisateur
  Future<User> updateUser(String id, Map<String, dynamic> data) async {
    if (!await NetworkService.isConnected()) {
      throw Exception(AppConstants.networkErrorMessage);
    }

    return NetworkService.retryWithBackoff(() async {
      try {
        final response = await _apiClient
            .put('/users/$id', data)
            .timeout(AppConstants.connectionTimeout);

        if (response.statusCode == 200) {
          return User.fromJson(jsonDecode(response.body));
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

  // Désactiver un utilisateur
  Future<Map<String, dynamic>> deactivateUser(String id) async {
    if (!await NetworkService.isConnected()) {
      throw Exception(AppConstants.networkErrorMessage);
    }

    return NetworkService.retryWithBackoff(() async {
      try {
        final response = await _apiClient
            .delete('/users/$id')
            .timeout(AppConstants.connectionTimeout);

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
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

  // Réactiver un utilisateur
  Future<Map<String, dynamic>> activateUser(String id) async {
    if (!await NetworkService.isConnected()) {
      throw Exception(AppConstants.networkErrorMessage);
    }

    return NetworkService.retryWithBackoff(() async {
      try {
        final response = await _apiClient
            .put('/users/$id/activate', {})
            .timeout(AppConstants.connectionTimeout);

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
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

  // Lister tous les rôles
  Future<List<Role>> getRoles() async {
    if (!await NetworkService.isConnected()) {
      throw Exception(AppConstants.networkErrorMessage);
    }

    return NetworkService.retryWithBackoff(() async {
      try {
        final response = await _apiClient
            .get('/users/roles')
            .timeout(AppConstants.connectionTimeout);

        if (response.statusCode == 200) {
          final List<dynamic> rolesJson = jsonDecode(response.body);
          return rolesJson.map((roleJson) => Role.fromJson(roleJson)).toList();
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
}
