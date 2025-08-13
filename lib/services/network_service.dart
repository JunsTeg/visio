import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class NetworkService {
  // Vérifier la connectivité réseau
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Gérer les erreurs HTTP
  static String handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return 'Succès'; // Codes de succès
      case 400:
        return 'Requête invalide';
      case 401:
        return 'Non autorisé - Veuillez vous reconnecter';
      case 403:
        return 'Accès interdit';
      case 404:
        return 'Ressource non trouvée';
      case 409:
        return 'Conflit - Cette ressource existe déjà';
      case 422:
        return 'Données invalides';
      case 429:
        return 'Trop de requêtes - Veuillez patienter';
      case 500:
        return 'Erreur serveur interne';
      case 502:
        return 'Erreur de passerelle';
      case 503:
        return 'Service temporairement indisponible';
      case 504:
        return 'Délai d\'attente dépassé';
      default:
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return 'Succès'; // Codes de succès HTTP
        } else {
          return 'Erreur inconnue (${response.statusCode})';
        }
    }
  }

  // Gérer les exceptions réseau
  static String handleNetworkException(dynamic error) {
    if (error is SocketException) {
      return 'Erreur de connexion réseau';
    } else if (error is HttpException) {
      return 'Erreur HTTP';
    } else if (error is FormatException) {
      return 'Erreur de format de données';
    } else if (error is TimeoutException) {
      return 'Délai d\'attente dépassé';
    } else {
      return 'Erreur réseau inconnue';
    }
  }

  // Vérifier si une erreur est récupérable
  static bool isRecoverableError(dynamic error) {
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is HttpException) return true;
    return false;
  }

  // Retry logic avec backoff exponentiel
  static Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int retryCount = 0;
    Duration delay = initialDelay;

    while (retryCount < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries || !isRecoverableError(e)) {
          rethrow;
        }

        await Future.delayed(delay);
        delay = Duration(milliseconds: delay.inMilliseconds * 2);
      }
    }

    throw Exception('Nombre maximum de tentatives atteint');
  }
}
