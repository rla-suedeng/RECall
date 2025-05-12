import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:template/app/theme/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/routing/router_service.dart';

class RECallAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onSettingsPressed;
  final TextStyle? titleTextStyle;
  final Color? iconColor;
  final bool showBackButton;
  final List<Widget>? actions;

  const RECallAppBar({
    super.key,
    required this.title,
    this.onNotificationsPressed,
    this.onSettingsPressed,
    this.titleTextStyle,
    this.iconColor,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: Text(
        title,
        style: titleTextStyle ??
            GoogleFonts.pacifico(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0.5,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: onNotificationsPressed ??
              () {
                context.go(Routes.apply);
              },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: onSettingsPressed ??
              () {
                context.go(Routes.profile);
              },
        ),
      ],
    );
  }
}
