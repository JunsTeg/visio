import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ErrorHandlerService {
  // Gérer les erreurs de manière centralisée
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
  }) {
    String message = customMessage ?? _getErrorMessage(error);

    // Afficher un SnackBar avec l'erreur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Gérer les erreurs avec une action de retry
  static void handleErrorWithRetry(
    BuildContext context,
    dynamic error,
    VoidCallback onRetry, {
    String? customMessage,
  }) {
    String message = customMessage ?? _getErrorMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        action: SnackBarAction(
          label: 'Réessayer',
          textColor: Colors.white,
          onPressed: onRetry,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // Gérer les erreurs avec une boîte de dialogue
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    String? customMessage,
    VoidCallback? onRetry,
  }) async {
    String message = customMessage ?? _getErrorMessage(error);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'Erreur'),
          content: Text(message),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Réessayer'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Gérer les erreurs de validation
  static void handleValidationError(
    BuildContext context,
    String field,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$field: $message'),
        backgroundColor: AppConstants.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }

  // Gérer les erreurs de permission
  static void handlePermissionError(BuildContext context, String permission) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permission requise: $permission'),
        backgroundColor: AppConstants.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        action: SnackBarAction(
          label: 'Paramètres',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Ouvrir les paramètres de l'application
          },
        ),
      ),
    );
  }

  // Gérer les erreurs de session
  static void handleSessionError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Session expirée. Veuillez vous reconnecter.'),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        action: SnackBarAction(
          label: 'Se connecter',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Naviguer vers l'écran de connexion
          },
        ),
      ),
    );
  }

  // Obtenir le message d'erreur approprié
  static String _getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }

    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }

    // Gérer les erreurs réseau
    if (error is SocketException) {
      return AppConstants.networkErrorMessage;
    }

    if (error is TimeoutException) {
      return 'Délai d\'attente dépassé';
    }

    if (error is HttpException) {
      return 'Erreur de connexion au serveur';
    }

    if (error is FormatException) {
      return 'Erreur de format de données';
    }

    return AppConstants.genericErrorMessage;
  }

  // Logger les erreurs (pour le débogage)
  static void logError(dynamic error, {String? context}) {
    print('${context != null ? '[$context] ' : ''}Error: $error');
    // TODO: Implémenter un vrai système de logging
  }

  // Vérifier si une erreur est critique
  static bool isCriticalError(dynamic error) {
    if (error is String) {
      return error.toLowerCase().contains('critique') ||
          error.toLowerCase().contains('fatale');
    }

    return false;
  }

  // Gérer les erreurs de manière silencieuse (pour les opérations non critiques)
  static void handleSilentError(dynamic error, {String? context}) {
    logError(error, context: context);
    // Ne pas afficher d'interface utilisateur
  }
}
