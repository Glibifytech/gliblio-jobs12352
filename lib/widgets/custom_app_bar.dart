import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar widget for social media application
/// Implements Contemporary Social Minimalism design with content-forward approach
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final AppBarVariant variant;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.variant = AppBarVariant.standard,
  });

  /// Factory constructor for home screen app bar
  factory CustomAppBar.home({
    Key? key,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: 'Social',
      variant: AppBarVariant.home,
      actions: actions ??
          [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => _navigateToSearch(),
              tooltip: 'Search',
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => _navigateToNotifications(),
              tooltip: 'Notifications',
            ),
          ],
    );
  }

  /// Factory constructor for profile screen app bar
  factory CustomAppBar.profile({
    Key? key,
    String? username,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: username ?? 'Profile',
      variant: AppBarVariant.profile,
      actions: actions ??
          [
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () => _showProfileMenu(),
              tooltip: 'More options',
            ),
          ],
    );
  }

  /// Factory constructor for search screen app bar
  factory CustomAppBar.search({
    Key? key,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      key: key,
      variant: AppBarVariant.search,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBackPressed ?? () => _navigateBack(),
        tooltip: 'Back',
      ),
      title: 'Search',
    );
  }

  /// Factory constructor for minimal app bar
  factory CustomAppBar.minimal({
    Key? key,
    String? title,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      variant: AppBarVariant.minimal,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBackPressed ?? () => _navigateBack(),
        tooltip: 'Back',
      ),
    );
  }

  static void _navigateToSearch() {
    // Navigation will be handled by the context when available
  }

  static void _navigateToNotifications() {
    // Navigation will be handled by the context when available
  }

  static void _navigateBack() {
    // Navigation will be handled by the context when available
  }

  static void _showProfileMenu() {
    // Profile menu will be handled by the context when available
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Handle navigation for static methods
    _handleNavigation(context);

    // Handle navigation for leading button
    Widget? customLeading = leading;
    if (leading is IconButton) {
      final leadingButton = leading as IconButton;
      if (leadingButton.tooltip == 'Back') {
        customLeading = IconButton(
          icon: leadingButton.icon,
          onPressed: () => Navigator.pop(context),
          tooltip: leadingButton.tooltip,
        );
      }
    }

    return AppBar(
      title: title != null ? _buildTitle(context) : null,
      leading: customLeading,
      actions: _buildActions(context),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? _getBackgroundColor(theme),
      foregroundColor: foregroundColor ?? _getForegroundColor(theme),
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      surfaceTintColor: Colors.transparent,
      shadowColor: theme.shadowColor.withValues(alpha: 0.1),
      toolbarHeight: _getToolbarHeight(),
      titleSpacing: _getTitleSpacing(),
      leadingWidth: _getLeadingWidth(),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case AppBarVariant.home:
        return Text(
          title!,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
            letterSpacing: -0.2,
          ),
        );
      case AppBarVariant.profile:
        return Text(
          title!,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.1,
          ),
        );
      case AppBarVariant.search:
      case AppBarVariant.minimal:
      case AppBarVariant.standard:
        return Text(
          title!,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0,
          ),
        );
    }
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (actions == null) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: action,
        );
      }
      return action;
    }).toList();
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (variant) {
      case AppBarVariant.home:
        return theme.colorScheme.surface;
      case AppBarVariant.profile:
      case AppBarVariant.search:
      case AppBarVariant.minimal:
      case AppBarVariant.standard:
        return theme.colorScheme.surface;
    }
  }

  Color _getForegroundColor(ThemeData theme) {
    return theme.colorScheme.onSurface;
  }

  double _getToolbarHeight() {
    switch (variant) {
      case AppBarVariant.home:
        return 64;
      case AppBarVariant.profile:
      case AppBarVariant.search:
      case AppBarVariant.minimal:
      case AppBarVariant.standard:
        return 56;
    }
  }

  double? _getTitleSpacing() {
    switch (variant) {
      case AppBarVariant.home:
        return 20;
      case AppBarVariant.profile:
      case AppBarVariant.search:
      case AppBarVariant.minimal:
      case AppBarVariant.standard:
        return null;
    }
  }

  double? _getLeadingWidth() {
    return 56;
  }

  void _handleNavigation(BuildContext context) {
    // Handle navigation for actions
    if (actions != null) {
      for (var action in actions!) {
        if (action is IconButton) {
          final originalOnPressed = action.onPressed;
          if (originalOnPressed != null) {
            // Override navigation for specific actions
            if (action.tooltip == 'Search') {
              action = IconButton(
                icon: action.icon,
                onPressed: () => Navigator.pushNamed(context, '/search-screen'),
                tooltip: action.tooltip,
              );
            } else if (action.tooltip == 'Notifications') {
              action = IconButton(
                icon: action.icon,
                onPressed: () =>
                    Navigator.pushNamed(context, '/notifications-screen'),
                tooltip: action.tooltip,
              );
            }
          }
        }
      }
    }

  }

  @override
  Size get preferredSize {
    final double height =
        _getToolbarHeight() + (bottom?.preferredSize.height ?? 0);
    return Size.fromHeight(height);
  }
}

/// Enum defining different app bar variants for the social media application
enum AppBarVariant {
  /// Standard app bar with default styling
  standard,

  /// Home screen app bar with brand styling and primary actions
  home,

  /// Profile screen app bar with user context
  profile,

  /// Search screen app bar with search-focused layout
  search,

  /// Minimal app bar with reduced visual weight
  minimal,
}
