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

  // Validation de numéro de téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }

    final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{8,}$');
    if (!phoneRegex.hasMatch(value)) {
      return AppConstants.phoneInvalid;
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
