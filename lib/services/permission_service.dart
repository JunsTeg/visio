import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum PermissionType {
  camera,
  microphone,
  location,
  storage,
  notification,
  internet,
}

class PermissionService {
  static final Map<PermissionType, bool> _permissionStatus = {};

  // Vérifier si une permission est accordée
  static Future<bool> hasPermission(PermissionType permission) async {
    // TODO: Implémenter la vérification réelle des permissions
    // Pour l'instant, on simule les permissions
    return _permissionStatus[permission] ?? false;
  }

  // Demander une permission
  static Future<bool> requestPermission(
    BuildContext context,
    PermissionType permission,
  ) async {
    try {
      // TODO: Implémenter la demande réelle de permission
      // Pour l'instant, on simule la demande
      
      final granted = await _showPermissionDialog(context, permission);
      _permissionStatus[permission] = granted;
      
      return granted;
    } catch (e) {
      return false;
    }
  }

  // Afficher une boîte de dialogue pour demander la permission
  static Future<bool> _showPermissionDialog(
    BuildContext context,
    PermissionType permission,
  ) async {
    final permissionInfo = _getPermissionInfo(permission);
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission ${permissionInfo['title']!}'),
          content: Text(permissionInfo['description']!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Refuser'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Autoriser'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  // Obtenir les informations d'une permission
  static Map<String, String> _getPermissionInfo(PermissionType permission) {
    switch (permission) {
      case PermissionType.camera:
        return {
          'title': 'Caméra',
          'description': 'Cette application a besoin d\'accéder à votre caméra pour prendre des photos et vidéos.',
        };
      case PermissionType.microphone:
        return {
          'title': 'Microphone',
          'description': 'Cette application a besoin d\'accéder à votre microphone pour l\'enregistrement audio.',
        };
      case PermissionType.location:
        return {
          'title': 'Localisation',
          'description': 'Cette application a besoin d\'accéder à votre localisation pour vous fournir des services personnalisés.',
        };
      case PermissionType.storage:
        return {
          'title': 'Stockage',
          'description': 'Cette application a besoin d\'accéder à votre stockage pour sauvegarder et charger des fichiers.',
        };
      case PermissionType.notification:
        return {
          'title': 'Notifications',
          'description': 'Cette application a besoin d\'envoyer des notifications pour vous tenir informé.',
        };
      case PermissionType.internet:
        return {
          'title': 'Internet',
          'description': 'Cette application a besoin d\'accéder à Internet pour fonctionner correctement.',
        };
    }
  }

  // Vérifier toutes les permissions requises
  static Future<Map<PermissionType, bool>> checkAllPermissions() async {
    final results = <PermissionType, bool>{};
    
    for (final permission in PermissionType.values) {
      results[permission] = await hasPermission(permission);
    }
    
    return results;
  }

  // Demander toutes les permissions requises
  static Future<Map<PermissionType, bool>> requestAllPermissions(
    BuildContext context,
  ) async {
    final results = <PermissionType, bool>{};
    
    for (final permission in PermissionType.values) {
      results[permission] = await requestPermission(context, permission);
    }
    
    return results;
  }

  // Vérifier si toutes les permissions critiques sont accordées
  static Future<bool> hasCriticalPermissions() async {
    const criticalPermissions = [
      PermissionType.internet,
      PermissionType.notification,
    ];
    
    for (final permission in criticalPermissions) {
      if (!await hasPermission(permission)) {
        return false;
      }
    }
    
    return true;
  }

  // Obtenir les permissions manquantes
  static Future<List<PermissionType>> getMissingPermissions() async {
    final missing = <PermissionType>[];
    
    for (final permission in PermissionType.values) {
      if (!await hasPermission(permission)) {
        missing.add(permission);
      }
    }
    
    return missing;
  }

  // Réinitialiser les permissions (pour les tests)
  static void resetPermissions() {
    _permissionStatus.clear();
  }

  // Obtenir le statut d'une permission
  static bool getPermissionStatus(PermissionType permission) {
    return _permissionStatus[permission] ?? false;
  }

  // Définir le statut d'une permission (pour les tests)
  static void setPermissionStatus(PermissionType permission, bool status) {
    _permissionStatus[permission] = status;
  }

  // Vérifier les permissions au démarrage de l'application
  static Future<void> checkStartupPermissions(BuildContext context) async {
    final missingPermissions = await getMissingPermissions();
    
    if (missingPermissions.isNotEmpty) {
      // Afficher un message informatif
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Certaines permissions sont requises pour le bon fonctionnement de l\'application.',
          ),
          backgroundColor: AppConstants.warningColor,
          behavior: SnackBarBehavior.floating,
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
  }
} 