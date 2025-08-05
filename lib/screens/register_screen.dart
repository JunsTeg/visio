import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_widget.dart';
import '../widgets/password_strength_indicator.dart';
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _fullNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Logo ou titre
                  const Icon(Icons.person_add, size: 80, color: Colors.green),
                  const SizedBox(height: 24),
                  const Text(
                    'Créer un compte',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
          );
        },
      ),
    );
  }
}
