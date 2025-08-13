import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_widget.dart';
import '../widgets/password_strength_indicator.dart';
import '../models/register_request.dart';
import '../services/upload_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'user';
  String? _selectedAvatarUrl;
  File? _selectedImageFile;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
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
          _selectedAvatarUrl = null; // Réinitialiser l'URL si on a un fichier
        });
      }
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Si on a une image sélectionnée, on l'upload d'abord
      String? finalAvatarUrl = _selectedAvatarUrl;
      if (_selectedImageFile != null) {
        try {
          // Upload de l'image via l'endpoint public
          final uploadedUrl = await UploadService.uploadAvatarPublic(_selectedImageFile!);
          if (uploadedUrl != null) {
            finalAvatarUrl = uploadedUrl;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur lors de l\'upload de l\'image'),
                backgroundColor: Colors.red,
              ),
            );
            return;
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

      final registerRequest = RegisterRequest(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        role: _selectedRole,
        avatarUrl: finalAvatarUrl,
      );

      final success = await authProvider.register(registerRequest);

      if (success && mounted) {
        Navigator.of(context).pop(); // Retour à l'écran précédent
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.registerSuccessMessage),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        );
      }
    }
  }

  // Méthode pour afficher la description détaillée du rôle sélectionné
  Widget _buildRoleDescription(String role) {
    switch (role) {
      case 'seller':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rôle Vendeur',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '• Publier et gérer vos produits\n'
              '• Accéder aux statistiques de vente\n'
              '• Gérer les commandes et les clients\n'
              '• Accéder aux outils de marketing',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        );
      case 'user':
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rôle Utilisateur',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '• Parcourir et acheter des produits\n'
              '• Gérer votre profil et vos commandes\n'
              '• Noter et commenter les produits\n'
              '• Accéder aux fonctionnalités standard',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SafeArea(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false, // Masque les barres de défilement
              ),
              child: SingleChildScrollView(
                // Défilement fluide sans rebond
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Logo / Avatar (tap pour ajouter/modifier une photo)
                      Center(
                        child: GestureDetector(
                          onTap: _selectImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.green.withOpacity(0.15),
                                backgroundImage:
                                    _selectedImageFile != null
                                        ? FileImage(_selectedImageFile!)
                                        : (_selectedAvatarUrl != null &&
                                            _selectedAvatarUrl!.isNotEmpty)
                                        ? NetworkImage(_selectedAvatarUrl!)
                                        : null,
                                child:
                                    (_selectedImageFile == null &&
                                            (_selectedAvatarUrl == null ||
                                                _selectedAvatarUrl!.isEmpty))
                                        ? const Icon(
                                          Icons.person_add,
                                          size: 48,
                                          color: Colors.green,
                                        )
                                        : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
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
                      const SizedBox(height: 8),
                      Text(
                        'Appuyez pour ajouter une photo',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Champ nom complet
                      CustomTextField(
                        controller: _fullNameController,
                        labelText: 'Nom complet *',
                        prefixIcon: Icons.person,
                        textCapitalization: TextCapitalization.words,
                        validator: Validators.validateFullName,
                      ),
                      const SizedBox(height: 16),

                      // Champ email
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email *',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // Champ mot de passe
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Mot de passe *',
                        prefixIcon: Icons.lock,
                        obscureText: true,
                        validator: Validators.validatePassword,
                        onChanged:
                            (_) => setState(() {}), // mise à jour en temps réel
                      ),
                      const SizedBox(height: 8),

                      // Indicateur de force du mot de passe
                      PasswordStrengthIndicator(
                        password: _passwordController.text,
                        showSuggestions: true,
                      ),
                      const SizedBox(height: 16),

                      // Champ confirmation mot de passe
                      CustomTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirmer le mot de passe *',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator:
                            (value) => Validators.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Champ numéro de téléphone (optionnel)
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'Numéro de téléphone (optionnel)',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                      ),
                      const SizedBox(height: 16),

                      // Sélection du rôle
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Sélectionnez votre rôle *',
                          helperText:
                              _selectedRole == 'seller'
                                  ? 'Vendeur: vous pourrez publier et gérer vos produits.'
                                  : 'Utilisateur: compte standard pour naviguer et acheter.',
                          helperMaxLines: 3,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppConstants.borderRadius),
                            ),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            items: const [
                              DropdownMenuItem(
                                value: 'user',
                                child: Text('Utilisateur'),
                              ),
                              DropdownMenuItem(
                                value: 'seller',
                                child: Text('Vendeur'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Aide contextuelle détaillée
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Aide au choix du rôle',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildRoleDescription(_selectedRole),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Message d'erreur
                      if (authProvider.errorMessage != null)
                        ErrorDisplayWidget(
                          message: authProvider.errorMessage!,
                          onRetry: () => authProvider.clearError(),
                        ),
                      const SizedBox(height: 16),

                      // Bouton d'inscription
                      RegisterButton(
                        onPressed: _register,
                        isLoading: authProvider.isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Lien vers connexion
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Vous avez déjà un compte ?'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text('Se connecter'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
