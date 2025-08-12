import '../utils/constants.dart';

class Validators {
  // Validation d'email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emailRequired;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppConstants.emailInvalid;
    }

    return null;
  }

  // Validation de mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequired;
    }

    if (value.length < 6) {
      return AppConstants.passwordMinLength;
    }

    return null;
  }

  // Validation de nom complet
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.nameRequired;
    }

    if (value.length < 2) {
      return AppConstants.nameMinLength;
    }

    return null;
  }

  // Validation de numéro de téléphone (format international)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }

    // Regex universelle pour les numéros de téléphone internationaux
    // Accepte : +[indicatif][numéro], (indicatif)[numéro], indicatif-numéro, etc.
    final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)\.]{7,20}$');

    if (!phoneRegex.hasMatch(value)) {
      return AppConstants.phoneInvalid;
    }

    // Vérification supplémentaire : doit contenir au moins 7 chiffres
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return 'Le numéro doit contenir entre 7 et 15 chiffres';
    }

    return null;
  }

  // Validation de confirmation de mot de passe
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }

    if (value != password) {
      return AppConstants.passwordMismatch;
    }

    return null;
  }

  // Validation combinée pour l'inscription
  static Map<String, String?> validateRegistration({
    required String? fullName,
    required String? email,
    required String? password,
    required String? confirmPassword,
    String? phoneNumber,
  }) {
    return {
      'fullName': validateFullName(fullName),
      'email': validateEmail(email),
      'password': validatePassword(password),
      'confirmPassword': validateConfirmPassword(
        confirmPassword,
        password ?? '',
      ),
      'phoneNumber': validatePhone(phoneNumber),
    };
  }

  // Validation combinée pour la connexion
  static Map<String, String?> validateLogin({
    required String? email,
    required String? password,
  }) {
    return {
      'email': validateEmail(email),
      'password': validatePassword(password),
    };
  }
}
