import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../services/upload_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  bool _isEditing = false;
  String? _avatarUrl;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _passwordController = TextEditingController();
    _avatarUrl = user?.avatarUrl;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choisir une photo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Appareil photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galerie'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
    );

    if (source != null) {
      final imageFile = await UploadService.pickImage(source: source);
      if (imageFile != null) {
        setState(() {
          _selectedImageFile = imageFile;
          _avatarUrl = null; // Réinitialiser l'URL si on a un fichier
        });
      }
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _passwordController.clear();
        _selectedImageFile = null; // Réinitialiser l'image sélectionnée
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Si on a une nouvelle image, on l'upload d'abord
      String? finalAvatarUrl = _avatarUrl;
      if (_selectedImageFile != null) {
        try {
          // Obtenir le token depuis le service d'auth
          final token = await authProvider.getAccessToken();
          if (token == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Erreur: Token d\'authentification non disponible',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Upload de l'image
          final uploadedUrl = await UploadService.uploadAvatar(
            _selectedImageFile!,
            token,
          );
          if (uploadedUrl != null) {
            finalAvatarUrl = uploadedUrl;
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'upload de l\'image: $e'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final data = <String, dynamic>{
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'avatarUrl': finalAvatarUrl,
      };

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      final success = await authProvider.updateProfileMe(data);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
        setState(() {
          _isEditing = false;
          _selectedImageFile = null;
          _avatarUrl = finalAvatarUrl;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erreur inconnue'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _isEditing ? _selectImage : null,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            _selectedImageFile != null
                                ? FileImage(_selectedImageFile!)
                                : (user.avatarUrl != null &&
                                    user.avatarUrl!.isNotEmpty)
                                ? NetworkImage(user.avatarUrl!)
                                : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                ? NetworkImage(_avatarUrl!)
                                : null,
                        child:
                            (_selectedImageFile == null &&
                                    (user.avatarUrl == null ||
                                        user.avatarUrl!.isEmpty) &&
                                    (_avatarUrl == null || _avatarUrl!.isEmpty))
                                ? const Icon(
                                  Icons.account_circle,
                                  size: 48,
                                  color: Colors.grey,
                                )
                                : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 8),
                Text(
                  'Appuyez pour modifier la photo',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: 'Email'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                enabled: _isEditing,
                decoration: const InputDecoration(labelText: 'Téléphone'),
              ),
              const SizedBox(height: 16),
              if (_isEditing)
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nouveau mot de passe',
                  ),
                ),
              const SizedBox(height: 24),
              if (_isEditing)
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _saveProfile,
                  child:
                      authProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Enregistrer'),
                ),
              if (!_isEditing)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text('Email vérifié : ${user.isVerified ? "Oui" : "Non"}'),
                    if (user.createdAt != null)
                      Text(
                        'Inscrit le : ${user.createdAt!.toLocal().toString().split(" ")[0]}',
                      ),
                    if (user.roles != null && user.roles!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Rôles :',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...user.roles!.map(
                            (role) => Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text('• ${role.name}'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
