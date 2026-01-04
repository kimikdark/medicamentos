import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// AppBar customizado com estilo da aplicação
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: navbarContrastColor,
      elevation: 4,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// AppBar especial para tela principal com logo
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAdminTap;
  final VoidCallback? onProfileTap;

  const HomeAppBar({
    Key? key,
    required this.onAdminTap,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: navbarContrastColor,
      elevation: 4,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('imagens/logo.png'),
      ),
      title: const Text(
        appName,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (onProfileTap != null)
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 32,
            ),
            onPressed: onProfileTap,
            tooltip: 'Perfil',
          ),
        IconButton(
          icon: const Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
            size: 32,
          ),
          onPressed: onAdminTap,
          tooltip: 'Administração',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

