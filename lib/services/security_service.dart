import 'dart:convert';
import 'dart:math';

class SecurityService {
  // Validation des mots de passe
  static bool isPasswordStrong(String password) {
    if (password.length < 8) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  // Calculer la force du mot de passe (0-100)
  static int getPasswordStrength(String password) {
    int score = 0;

    // Longueur
    if (password.length >= 8) score += 20;
    if (password.length >= 12) score += 10;

    // Complexité
    if (password.contains(RegExp(r'[A-Z]'))) score += 15;
    if (password.contains(RegExp(r'[a-z]'))) score += 15;
    if (password.contains(RegExp(r'[0-9]'))) score += 15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 15;

    // Variété des caractères
    final uniqueChars = password.split('').toSet().length;
    if (uniqueChars >= 8) score += 10;

    return score.clamp(0, 100);
  }

  // Obtenir des suggestions pour améliorer le mot de passe
  static List<String> getPasswordSuggestions(String password) {
    final suggestions = <String>[];

    if (password.length < 8) {
      suggestions.add('Le mot de passe doit contenir au moins 8 caractères');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      suggestions.add('Ajoutez au moins une lettre majuscule');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      suggestions.add('Ajoutez au moins une lettre minuscule');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      suggestions.add('Ajoutez au moins un chiffre');
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      suggestions.add('Ajoutez au moins un caractère spécial');
    }

    return suggestions;
  }

  // Validation des emails
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }

  // Validation des numéros de téléphone
  static bool isValidPhoneNumber(String phone) {
    // Supprimer les espaces et caractères spéciaux
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Vérifier si c'est un numéro français valide
    if (cleanPhone.startsWith('+33') && cleanPhone.length == 12) {
      return true;
    }

    // Vérifier si c'est un numéro français sans indicatif
    if (cleanPhone.startsWith('0') && cleanPhone.length == 10) {
      return true;
    }

    return false;
  }

  // Nettoyer les données d'entrée
  static String sanitizeInput(String input) {
    // Supprimer les caractères dangereux
    return input
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .trim();
  }

  // Valider les données JSON
  static bool isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Générer un token sécurisé
  static String generateSecureToken(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Masquer les données sensibles
  static String maskSensitiveData(String data, {int visibleChars = 4}) {
    if (data.length <= visibleChars) return '*' * data.length;

    final visible = data.substring(data.length - visibleChars);
    final masked = '*' * (data.length - visibleChars);
    return masked + visible;
  }

  // Valider l'URL
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Vérifier si une chaîne contient des caractères dangereux
  static bool containsDangerousCharacters(String input) {
    final dangerousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'data:text/html', caseSensitive: false),
    ];

    return dangerousPatterns.any((pattern) => pattern.hasMatch(input));
  }

  // Obtenir le niveau de sécurité d'un mot de passe
  static String getPasswordSecurityLevel(String password) {
    final strength = getPasswordStrength(password);

    if (strength >= 80) return 'Très fort';
    if (strength >= 60) return 'Fort';
    if (strength >= 40) return 'Moyen';
    if (strength >= 20) return 'Faible';
    return 'Très faible';
  }

  // Valider la complexité d'un nom
  static bool isValidName(String name) {
    if (name.length < 2) return false;

    // Vérifier qu'il ne contient que des lettres, espaces et tirets
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s\-]+$');
    return nameRegex.hasMatch(name);
  }
}
