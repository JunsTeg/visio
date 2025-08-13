import 'package:flutter/material.dart';
import '../services/security_service.dart';
import '../utils/constants.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showSuggestions;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showSuggestions = true,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = SecurityService.getPasswordStrength(password);
    final level = SecurityService.getPasswordSecurityLevel(password);
    final suggestions = SecurityService.getPasswordSuggestions(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barre de progression
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStrengthColor(strength),
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              '$strength%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getStrengthColor(strength),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Niveau de sécurité
        Text(
          level,
          style: TextStyle(
            fontSize: 12,
            color: _getStrengthColor(strength),
            fontWeight: FontWeight.w500,
          ),
        ),

        // Suggestions d'amélioration
        if (showSuggestions && suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...suggestions.map(
            (suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 12,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getStrengthColor(int strength) {
    if (strength >= 80) return Colors.green;
    if (strength >= 60) return Colors.blue;
    if (strength >= 40) return Colors.orange;
    if (strength >= 20) return Colors.red.shade400;
    return Colors.red;
  }
}

// Widget compact pour la force du mot de passe
class CompactPasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const CompactPasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = SecurityService.getPasswordStrength(password);
    final level = SecurityService.getPasswordSecurityLevel(password);

    return Row(
      children: [
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: strength / 100,
            child: Container(
              decoration: BoxDecoration(
                color: _getStrengthColor(strength),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          level,
          style: TextStyle(
            fontSize: 10,
            color: _getStrengthColor(strength),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStrengthColor(int strength) {
    if (strength >= 80) return Colors.green;
    if (strength >= 60) return Colors.blue;
    if (strength >= 40) return Colors.orange;
    if (strength >= 20) return Colors.red.shade400;
    return Colors.red;
  }
}
