import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';

class UploadService {
  static String get _baseUrl => AppConstants.baseUrl;
  static const String _uploadAvatarEndpoint = '/upload/avatar';
  static const String _uploadAvatarPublicEndpoint = '/upload/avatar/public';

  // Upload d'avatar pour utilisateurs connectés (avec token)
  static Future<String?> uploadAvatar(File imageFile, String token) async {
    try {
      // Créer la requête multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_uploadAvatarEndpoint'),
      );

      // Ajouter le token d'authentification
      request.headers['Authorization'] = 'Bearer $token';

      // Ajouter le fichier
      request.files.add(
        await http.MultipartFile.fromPath('avatar', imageFile.path),
      );

      // Envoyer la requête
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parser la réponse pour obtenir l'URL de l'avatar
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          Map.fromEntries(
            responseData.split('&').map((pair) {
              final parts = pair.split('=');
              return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
            }),
          ),
        );

        return data['avatarUrl'] ?? data['avatar_url'];
      } else {
        print('Erreur upload: ${response.statusCode} - $responseData');
        return null;
      }
    } catch (e) {
      print('Erreur lors de l\'upload: $e');
      return null;
    }
  }

  // Upload d'avatar public pour l'inscription (sans token)
  static Future<String?> uploadAvatarPublic(File imageFile) async {
    try {
      // Créer la requête multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_uploadAvatarPublicEndpoint'),
      );

      // Ajouter le fichier
      request.files.add(
        await http.MultipartFile.fromPath('avatar', imageFile.path),
      );

      // Envoyer la requête
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parser la réponse pour obtenir l'URL de l'avatar
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          Map.fromEntries(
            responseData.split('&').map((pair) {
              final parts = pair.split('=');
              return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
            }),
          ),
        );

        return data['avatarUrl'] ?? data['avatar_url'];
      } else {
        print('Erreur upload public: ${response.statusCode} - $responseData');
        return null;
      }
    } catch (e) {
      print('Erreur lors de l\'upload public: $e');
      return null;
    }
  }

  static Future<File?> pickImage({
    required ImageSource source,
    int imageQuality = 80,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la sélection d\'image: $e');
      return null;
    }
  }

  static Future<String?> showImageSourceDialog() async {
    // Cette méthode sera utilisée pour afficher le dialog de sélection
    // Retourne 'camera' ou 'gallery' selon le choix de l'utilisateur
    return null;
  }
}
