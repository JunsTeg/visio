import 'package:flutter/material.dart';
import 'auth_dropdown.dart';

class CustomNavbar extends StatefulWidget {
  final VoidCallback onMenuPressed;
  final bool isSidebarOpen;

  const CustomNavbar({
    super.key,
    required this.onMenuPressed,
    required this.isSidebarOpen,
  });

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25, // 90 degrés = 0.25 * 360
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(CustomNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSidebarOpen != oldWidget.isSidebarOpen) {
      if (widget.isSidebarOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight + 16, // Augmentation de 16px pour plus d'espace
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end, // Aligne les éléments vers le bas
        children: [
          // Menu hamburger à gauche avec rotation fluide
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return IconButton(
                icon: Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: const Icon(Icons.menu),
                ),
                onPressed: widget.onMenuPressed,
                tooltip: 'Menu',
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  padding: const EdgeInsets.all(
                    12.0,
                  ), // Augmentation de la zone de clic
                ),
              );
            },
          ),

          // Espace flexible pour centrer le titre
          const Expanded(child: SizedBox()),

          // Titre VISIO au centre
          const Text(
            'VISIO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),

          // Espace flexible pour équilibrer
          const Expanded(child: SizedBox()),

          // Dropdown à droite (inchangé)
          const AuthDropdown(),
        ],
      ),
    );
  }
}
