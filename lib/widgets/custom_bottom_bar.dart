import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom bottom navigation bar for social media application
/// Implements adaptive navigation states with subtle animations and content-aware spacing
class CustomBottomBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final BottomBarVariant variant;
  final bool showLabels;
  final double elevation;

  const CustomBottomBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.variant = BottomBarVariant.standard,
    this.showLabels = true,
    this.elevation = 0,
  });

  /// Factory constructor for main navigation
  factory CustomBottomBar.main({
    Key? key,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: BottomBarVariant.main,
      showLabels: true,
    );
  }

  /// Factory constructor for minimal navigation
  factory CustomBottomBar.minimal({
    Key? key,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: BottomBarVariant.minimal,
      showLabels: false,
    );
  }

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    final itemCount = _getNavigationItems().length;
    _animationControllers = List.generate(
      itemCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers
        .map((controller) => Tween<double>(
              begin: 1.0,
              end: 1.1,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            )))
        .toList();

    // Animate the current index
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(CustomBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reset previous animation
      if (oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }
      // Start new animation
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<BottomNavigationItem> _getNavigationItems() {
    switch (widget.variant) {
      case BottomBarVariant.main:
        return [
          BottomNavigationItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            route: '/home-screen',
          ),
          BottomNavigationItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search_rounded,
            label: 'Search',
            route: '/search-screen',
          ),
          BottomNavigationItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications_rounded,
            label: 'Notifications',
            route: '/notifications-screen',
          ),
          BottomNavigationItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
            route: '/profile-screen',
          ),
        ];
      case BottomBarVariant.minimal:
        return [
          BottomNavigationItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            route: '/home-screen',
          ),
          BottomNavigationItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search_rounded,
            label: 'Search',
            route: '/search-screen',
          ),
          BottomNavigationItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
            route: '/profile-screen',
          ),
        ];
      case BottomBarVariant.standard:
        return [
          BottomNavigationItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            route: '/home-screen',
          ),
          BottomNavigationItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search_rounded,
            label: 'Search',
            route: '/search-screen',
          ),
          BottomNavigationItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications_rounded,
            label: 'Notifications',
            route: '/notifications-screen',
          ),
          BottomNavigationItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
            route: '/profile-screen',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navigationItems = _getNavigationItems();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: widget.elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: _getBottomBarHeight(),
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(),
            vertical: _getVerticalPadding(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.currentIndex;

              return Expanded(
                child: _buildNavigationItem(
                  context,
                  item,
                  index,
                  isSelected,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    BottomNavigationItem item,
    int index,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimations[index],
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _handleItemTap(context, index, item.route),
          onTapDown: (_) => _animationControllers[index].forward(),
          onTapUp: (_) => _animationControllers[index].reverse(),
          onTapCancel: () => _animationControllers[index].reverse(),
          child: Transform.scale(
            scale: _scaleAnimations[index].value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(colorScheme, item, isSelected),
                  if (widget.showLabels) ...[
                    const SizedBox(height: 4),
                    _buildLabel(theme, item, isSelected),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(
      ColorScheme colorScheme, BottomNavigationItem item, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isSelected ? item.activeIcon : item.icon,
        size: 30,
        color: isSelected
            ? colorScheme.primary
            : colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildLabel(
      ThemeData theme, BottomNavigationItem item, bool isSelected) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        letterSpacing: 0.4,
      ),
      child: Text(
        item.label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _handleItemTap(BuildContext context, int index, String route) {
    // Provide haptic feedback
    _triggerHapticFeedback();

    // Call the onTap callback
    widget.onTap?.call(index);

    // Navigate to the route
    Navigator.pushNamed(context, route);
  }

  void _triggerHapticFeedback() {
    // Haptic feedback would be implemented here
    // HapticFeedback.lightImpact();
  }

  double _getBottomBarHeight() {
    switch (widget.variant) {
      case BottomBarVariant.main:
        return widget.showLabels ? 80 : 64;
      case BottomBarVariant.minimal:
        return 64;
      case BottomBarVariant.standard:
        return widget.showLabels ? 72 : 56;
    }
  }

  double _getHorizontalPadding() {
    switch (widget.variant) {
      case BottomBarVariant.main:
        return 16;
      case BottomBarVariant.minimal:
        return 24;
      case BottomBarVariant.standard:
        return 16;
    }
  }

  double _getVerticalPadding() {
    return 8;
  }
}

/// Data class for bottom navigation items
class BottomNavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const BottomNavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Enum defining different bottom bar variants for the social media application
enum BottomBarVariant {
  /// Standard bottom bar with all navigation items
  standard,

  /// Main bottom bar with primary navigation items and enhanced styling
  main,

  /// Minimal bottom bar with reduced items and compact layout
  minimal,
}
