import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class UploadService {
  static String get _baseUrl => AppConstants.baseUrl;
  static const String _uploadAvatarEndpoint = '/upload/avatar';
  static const String _uploadAvatarPublicEndpoint = '/upload/avatar/public';

  // Upload d'avatar pour utilisateurs connectés (avec token)
  static Future<String?> uploadAvatar(File imageFile, [String? token]) async {
    try {
      // Récupérer le token s'il n'est pas fourni
      final api = ApiClient();
      final resolvedToken = token ?? (await api.getAccessToken());

      // Fonction d'envoi (factorisée pour réutilisation après refresh)
      Future<http.StreamedResponse> send(String bearer) async {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl$_uploadAvatarEndpoint'),
        );
        request.headers['Authorization'] = 'Bearer $bearer';
        request.files.add(
          await http.MultipartFile.fromPath('avatar', imageFile.path),
        );
        return await request.send();
      }

      if (resolvedToken == null) {
        return null;
      }

      // Premier envoi
      var response = await send(resolvedToken);
      var responseData = await response.stream.bytesToString();

      // Si 401, tenter un refresh puis rejouer une seule fois
      if (response.statusCode == 401) {
        final refreshed = await api.refreshTokens();
        if (refreshed) {
          final newToken = await api.getAccessToken();
          if (newToken != null) {
            response = await send(newToken);
            responseData = await response.stream.bytesToString();
          }
        }
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        // La réponse backend est attendue au format JSON { avatarUrl: string, ... }
        try {
          final Map<String, dynamic> data =
              jsonDecode(responseData) as Map<String, dynamic>;
          return data['avatarUrl'] as String? ?? data['avatar_url'] as String?;
        } catch (_) {
          // Fallback si jamais la réponse n'est pas JSON
          return null;
        }
      }

      print('Erreur upload: ${response.statusCode} - $responseData');
      return null;
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
        try {
          final Map<String, dynamic> data =
              jsonDecode(responseData) as Map<String, dynamic>;
          return data['avatarUrl'] as String? ?? data['avatar_url'] as String?;
        } catch (_) {
          return null;
        }
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
