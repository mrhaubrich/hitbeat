import 'package:flutter/material.dart';
import 'package:hitbeat/src/modules/home/widgets/enhanced_sidebar.dart';

export 'package:hitbeat/src/modules/home/widgets/enhanced_sidebar.dart';

/// The controller of the sidebar.
///
/// This is now a compatibility wrapper around [EnhancedSidebarController].
class MySideBarController extends EnhancedSidebarController {
  /// Creates a new sidebar controller.
  MySideBarController() : super(initialIndex: 0);
}

/// The sidebar widget with enhanced styling and animations.
class Sidebar extends StatelessWidget {
  /// Creates a new sidebar widget.
  const Sidebar({
    required EnhancedSidebarController controller,
    super.key,
  }) : _controller = controller;

  static final _mainItems = [
    const SidebarMenuItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard/',
      tooltip: 'Dashboard',
    ),
    const SidebarMenuItem(
      icon: Icons.queue_music,
      label: 'Tracks',
      route: '/tracks/',
      tooltip: 'View all tracks',
    ),
    const SidebarMenuItem(
      icon: Icons.playlist_play,
      label: 'Playlists',
      route: '/playlists/',
      tooltip: 'Manage playlists',
    ),
    const SidebarMenuItem(
      icon: Icons.search,
      label: 'Search',
      route: '/search/',
      tooltip: 'Search music',
    ),
  ];

  static final _footerItems = [
    const SidebarMenuItem(
      icon: Icons.settings,
      label: 'Settings',
      route: '/settings/',
      tooltip: 'Application settings',
    ),
  ];

  final EnhancedSidebarController _controller;

  @override
  Widget build(BuildContext context) {
    return EnhancedSidebar(
      controller: _controller,
      mainItems: _mainItems,
      footerItems: _footerItems,
    );
  }
}
