import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height,
      child:
          isOutlined
              ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: OutlinedButton.styleFrom(
                  padding:
                      padding ??
                      const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: AppConstants.defaultPadding,
                      ),
                  side: BorderSide(
                    color: backgroundColor ?? AppConstants.primaryColor,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        borderRadius ??
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: _buildButtonContent(theme),
              )
              : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor ?? AppConstants.primaryColor,
                  foregroundColor: foregroundColor ?? Colors.white,
                  padding:
                      padding ??
                      const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: AppConstants.defaultPadding,
                      ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        borderRadius ??
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  elevation: 2,
                ),
                child: _buildButtonContent(theme),
              ),
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppConstants.iconSize),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

// Bouton de connexion spécialisé
class LoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const LoginButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Se connecter',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppConstants.primaryColor,
      icon: Icons.login,
    );
  }
}

// Bouton d'inscription spécialisé
class RegisterButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const RegisterButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'S\'inscrire',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppConstants.secondaryColor,
      icon: Icons.person_add,
    );
  }
}

// Bouton de déconnexion spécialisé
class LogoutButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const LogoutButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Se déconnecter',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppConstants.errorColor,
      icon: Icons.logout,
    );
  }
}
