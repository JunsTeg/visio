import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/users_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class UserEditScreen extends StatefulWidget {
  final String userId;

  const UserEditScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final UsersService _usersService = UsersService();

  User? _user;
  List<Role> _availableRoles = [];
  List<int> _selectedRoleIds = [];

  bool _isLoading = false;
  bool _isLoadingUser = true;
  bool _isLoadingRoles = true;
  String? _errorMessage;
  bool _isPasswordChanged = false;

  @override
  void initState() {
    super.initState();
    _loadUserAndRoles();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndRoles() async {
    try {
      setState(() {
        _isLoadingUser = true;
        _isLoadingRoles = true;
        _errorMessage = null;
      });

      // Charger l'utilisateur et les rôles en parallèle
      await Future.wait([_loadUser(), _loadRoles()]);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingUser = false;
        _isLoadingRoles = false;
      });
    }
  }

  Future<void> _loadUser() async {
    try {
      final user = await _usersService.getUser(widget.userId);
      setState(() {
        _user = user;
        _isLoadingUser = false;
      });

      // Pré-remplir les champs
      _fullNameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';

      // Pré-sélectionner les rôles existants
      if (user.roles != null) {
        _selectedRoleIds = user.roles!.map((role) => role.id).toList();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement de l\'utilisateur: $e';
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await _usersService.getRoles();
      setState(() {
        _availableRoles = roles;
        _isLoadingRoles = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des rôles: $e';
        _isLoadingRoles = false;
      });
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un rôle'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier si le mot de passe a été modifié
    if (_isPasswordChanged &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userData = <String, dynamic>{
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber':
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        'roleIds': _selectedRoleIds,
      };

      // Ajouter le mot de passe seulement s'il a été modifié
      if (_isPasswordChanged) {
        userData['password'] = _passwordController.text;
      }

      final updatedUser = await _usersService.updateUser(
        widget.userId,
        userData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Utilisateur ${updatedUser.fullName} modifié avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(updatedUser);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $_errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleRole(int roleId) {
    setState(() {
      if (_selectedRoleIds.contains(roleId)) {
        _selectedRoleIds.remove(roleId);
      } else {
        _selectedRoleIds.add(roleId);
      }
    });
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _isPasswordChanged = value.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier l\'utilisateur')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingUser || _isLoadingRoles) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && (_user == null || _availableRoles.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erreur: $_errorMessage'),
            ElevatedButton(
              onPressed: _loadUserAndRoles,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_user == null) {
      return const Center(child: Text('Utilisateur non trouvé'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPersonalInfoSection(),
            const SizedBox(height: 24),
            _buildPasswordSection(),
            const SizedBox(height: 24),
            _buildRolesSection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations personnelles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _fullNameController,
              labelText: 'Nom complet *',
              validator: Validators.validateFullName,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email *',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              labelText: 'Téléphone (optionnel)',
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mot de passe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Laissez vide pour conserver le mot de passe actuel',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Nouveau mot de passe (optionnel)',
              obscureText: true,
              validator:
                  _isPasswordChanged ? Validators.validatePassword : null,
              onChanged: _onPasswordChanged,
            ),
            if (_isPasswordChanged) ...[
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirmer le nouveau mot de passe *',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer le mot de passe';
                  }
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRolesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rôles *',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sélectionnez au moins un rôle pour l\'utilisateur',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_availableRoles.isEmpty)
              const Text(
                'Aucun rôle disponible',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ..._availableRoles.map((role) => _buildRoleCheckbox(role)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCheckbox(Role role) {
    final isSelected = _selectedRoleIds.contains(role.id);

    return CheckboxListTile(
      title: Text(role.name),
      subtitle: role.description != null ? Text(role.description!) : null,
      value: isSelected,
      onChanged: (value) => _toggleRole(role.id),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      onPressed: _isLoading ? null : _updateUser,
      text: _isLoading ? 'Modification en cours...' : 'Modifier l\'utilisateur',
      isLoading: _isLoading,
    );
  }
}
