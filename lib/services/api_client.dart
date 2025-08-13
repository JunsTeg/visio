import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiClient {
  // Utiliser la configuration dynamique au lieu d'une URL statique
  String get baseUrl => AppConstants.baseUrl;
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Future<bool>? _refreshingToken;

  // Headers par défaut
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Obtenir les headers avec token d'authentification
  Future<Map<String, String>> get _authHeaders async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      ..._defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Méthode GET
  Future<http.Response> get(String endpoint) async {
    return _request('GET', endpoint);
  }

  // Méthode POST
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return _request('POST', endpoint, body: body);
  }

  // Méthode PUT
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    return _request('PUT', endpoint, body: body);
  }

  // Méthode DELETE
  Future<http.Response> delete(String endpoint) async {
    return _request('DELETE', endpoint);
  }

  Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool isRetry = false,
  }) async {
    // Ne pas tenter de rafraîchir pour l'endpoint de refresh lui-même
    final isRefreshEndpoint = endpoint == '/auth/refresh';

    Map<String, String> headers =
        isRefreshEndpoint ? _defaultHeaders : await _authHeaders;
    final uri = Uri.parse('$baseUrl$endpoint');

    Future<http.Response> send() async {
      switch (method) {
        case 'GET':
          return await http.get(uri, headers: headers);
        case 'POST':
          return await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'PUT':
          return await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'DELETE':
          return await http.delete(uri, headers: headers);
        default:
          throw Exception('Méthode HTTP non supportée: $method');
      }
    }

    http.Response response = await send();

    if (response.statusCode == 401 && !isRetry && !isRefreshEndpoint) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        headers = await _authHeaders; // recharger le nouveau token
        response = await _request(method, endpoint, body: body, isRetry: true);
      }
    }

    return response;
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshingToken != null) {
      return await _refreshingToken!;
    }

    _refreshingToken =
        (() async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final refreshToken = prefs.getString('refresh_token');
            if (refreshToken == null) {
              await clearTokens();
              return false;
            }

            final response = await http.post(
              Uri.parse('$baseUrl/auth/refresh'),
              headers: _defaultHeaders,
              body: jsonEncode({'refreshToken': refreshToken}),
            );

            if (response.statusCode == 200) {
              final data = jsonDecode(response.body) as Map<String, dynamic>;
              final String? newAccess = data['accessToken'] as String?;
              final String? newRefresh = data['refreshToken'] as String?;
              if (newAccess != null && newRefresh != null) {
                await saveTokens(newAccess, newRefresh);
                return true;
              }
            }

            await clearTokens();
            return false;
          } catch (_) {
            await clearTokens();
            return false;
          } finally {
            _refreshingToken = null;
          }
        })();

    return await _refreshingToken!;
  }

  // Exposer publiquement le rafraîchissement pour les cas spéciaux (ex: multipart)
  Future<bool> refreshTokens() {
    return _refreshAccessToken();
  }

  // Sauvegarder les tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  // Supprimer les tokens
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // Obtenir le token d'accès
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Obtenir le token de rafraîchissement
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }
}
