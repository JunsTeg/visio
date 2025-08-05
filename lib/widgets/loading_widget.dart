import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const LoadingWidget({super.key, this.message, this.size = 40.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppConstants.primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              message!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Widget de chargement plein écran
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const FullScreenLoading({super.key, this.message, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.white,
      child: LoadingWidget(message: message ?? 'Chargement...', size: 50.0),
    );
  }
}

// Widget de chargement pour les boutons
class ButtonLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const ButtonLoading({super.key, this.size = 20.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.white),
      ),
    );
  }
}

// Widget de chargement avec overlay
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? overlayColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withOpacity(0.5),
            child: LoadingWidget(
              message: message,
              size: 50.0,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}
