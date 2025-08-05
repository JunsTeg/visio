import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // Couleurs de l'application
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;

  // URLs de l'API - Configuration dynamique selon la plateforme
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://pleasant-vaguely-drum.ngrok-free.app';
    } else if (Platform.isAndroid) {
      // Pour l'émulateur Android, utiliser l'IP de l'hôte
      return 'http://10.0.2.2:3000';
    } else {
      // Pour iOS et autres plateformes
      return 'https://pleasant-vaguely-drum.ngrok-free.app';
    }
  }

  static const String apiVersion = '/api/v1';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Messages
  static const String appName = 'Visio';
  static const String welcomeMessage = 'Bienvenue sur Visio';
  static const String loginSuccessMessage = 'Connexion réussie !';
  static const String registerSuccessMessage = 'Inscription réussie !';
  static const String logoutSuccessMessage = 'Déconnexion réussie';
  static const String genericErrorMessage = 'Une erreur est survenue';
  static const String networkErrorMessage = 'Erreur de connexion réseau';

  // Validation messages
  static const String emailRequired = 'Veuillez entrer votre email';
  static const String emailInvalid = 'Veuillez entrer un email valide';
  static const String passwordRequired = 'Veuillez entrer votre mot de passe';
  static const String passwordMinLength =
      'Le mot de passe doit contenir au moins 6 caractères';
  static const String nameRequired = 'Veuillez entrer votre nom complet';
  static const String nameMinLength =
      'Le nom doit contenir au moins 2 caractères';
  static const String phoneInvalid =
      'Veuillez entrer un numéro de téléphone valide';
  static const String passwordMismatch =
      'Les mots de passe ne correspondent pas';

  // Routes
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Sizes
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 64.0;
}
