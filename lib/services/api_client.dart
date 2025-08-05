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
    final headers = await _authHeaders;
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return response;
  }

  // Méthode POST
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _authHeaders;
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return response;
  }

  // Méthode PUT
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _authHeaders;
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return response;
  }

  // Méthode DELETE
  Future<http.Response> delete(String endpoint) async {
    final headers = await _authHeaders;
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return response;
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
