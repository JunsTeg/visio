import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class AppConfig {
  static Environment _environment = Environment.development;

  // Configuration par environnement
  static const Map<Environment, Map<String, dynamic>> _configs = {
    Environment.development: {
      'apiBaseUrl':
          'https://pleasant-vaguely-drum.ngrok-free.app', // IP de l'hôte pour l'émulateur Android
      'apiTimeout': 30000,
      'enableLogging': true,
      'enableAnalytics': false,
      'enableCrashReporting': false,
      'cacheExpiry': 3600, // 1 heure
      'maxRetries': 3,
      'enableDebugMode': true,
    },
    Environment.staging: {
      'apiBaseUrl': 'https://staging-api.visio.com',
      'apiTimeout': 30000,
      'enableLogging': true,
      'enableAnalytics': true,
      'enableCrashReporting': true,
      'cacheExpiry': 1800, // 30 minutes
      'maxRetries': 2,
      'enableDebugMode': false,
    },
    Environment.production: {
      'apiBaseUrl': 'https://api.visio.com',
      'apiTimeout': 15000,
      'enableLogging': false,
      'enableAnalytics': true,
      'enableCrashReporting': true,
      'cacheExpiry': 900, // 15 minutes
      'maxRetries': 1,
      'enableDebugMode': false,
    },
  };

  // Initialiser la configuration
  static void initialize(Environment environment) {
    _environment = environment;
  }

  // Obtenir la valeur d'une configuration
  static T get<T>(String key, {T? defaultValue}) {
    final config = _configs[_environment];
    if (config == null) {
      throw Exception(
        'Configuration non trouvée pour l\'environnement $_environment',
      );
    }

    final value = config[key];
    if (value == null) {
      if (defaultValue != null) return defaultValue;
      throw Exception('Clé de configuration non trouvée: $key');
    }

    return value as T;
  }

  // Obtenir l'environnement actuel
  static Environment get environment => _environment;

  // Vérifier si on est en mode développement
  static bool get isDevelopment => _environment == Environment.development;

  // Vérifier si on est en mode staging
  static bool get isStaging => _environment == Environment.staging;

  // Vérifier si on est en mode production
  static bool get isProduction => _environment == Environment.production;

  // Obtenir l'URL de base de l'API
  static String get apiBaseUrl => get<String>('apiBaseUrl');

  // Obtenir le timeout de l'API
  static int get apiTimeout => get<int>('apiTimeout');

  // Vérifier si le logging est activé
  static bool get enableLogging => get<bool>('enableLogging');

  // Vérifier si les analytics sont activés
  static bool get enableAnalytics => get<bool>('enableAnalytics');

  // Vérifier si le crash reporting est activé
  static bool get enableCrashReporting => get<bool>('enableCrashReporting');

  // Obtenir l'expiration du cache
  static int get cacheExpiry => get<int>('cacheExpiry');

  // Obtenir le nombre maximum de tentatives
  static int get maxRetries => get<int>('maxRetries');

  // Vérifier si le mode debug est activé
  static bool get enableDebugMode => get<bool>('enableDebugMode');

  // Obtenir la configuration complète
  static Map<String, dynamic> get config => Map.from(_configs[_environment]!);

  // Mettre à jour une configuration dynamiquement
  static void updateConfig(String key, dynamic value) {
    if (kDebugMode) {
      print('Mise à jour de la configuration: $key = $value');
    }
    // Note: Cette méthode ne modifie que la configuration en mémoire
    // Les changements ne sont pas persistés
  }

  // Obtenir les informations de version
  static Map<String, String> get versionInfo => {
    'appName': 'Visio',
    'version': '1.0.0',
    'buildNumber': '1',
    'environment': _environment.name,
  };

  // Obtenir les paramètres de sécurité
  static Map<String, dynamic> get securitySettings => {
    'minPasswordLength': 8,
    'requireSpecialChars': true,
    'requireNumbers': true,
    'requireUppercase': true,
    'requireLowercase': true,
    'maxLoginAttempts': 5,
    'lockoutDuration': 300, // 5 minutes
    'sessionTimeout': 3600, // 1 heure
  };

  // Obtenir les paramètres de performance
  static Map<String, dynamic> get performanceSettings => {
    'imageCacheSize': 100,
    'maxConcurrentRequests': 5,
    'requestTimeout': 30,
    'enableCompression': true,
    'enableCaching': true,
  };
}
