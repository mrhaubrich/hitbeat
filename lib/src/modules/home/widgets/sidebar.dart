import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hitbeat/src/modules/home/widgets/animated_logo.dart';
import 'package:hitbeat/src/theme/sidebar_theme_extension.dart';
import 'package:sidebarx/sidebarx.dart';

/// The controller of the sidebar.
class MySideBarController extends SidebarXController {
  /// Creates a new sidebar controller.
  MySideBarController() : super(selectedIndex: 0);
}

/// The sidebar widget.
class Sidebar extends StatelessWidget {
  /// Creates a new sidebar widget.
  const Sidebar({
    required SidebarXController controller,
    super.key,
  }) : _controller = controller;

  static final _items = [
    _SidebarItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard/',
    ),
    _SidebarItem(
      icon: Icons.queue_music,
      label: 'Tracks',
      route: '/tracks/',
    ),
    _SidebarItem(
      icon: Icons.icecream,
      label: 'Ice-Cream',
      route: '/ice-cream/',
    ),
    _SidebarItem(
      icon: Icons.search,
      label: 'Search',
      route: '/search/',
    ),
  ];
  static final _footerItems = [
    _SidebarItem(
      icon: Icons.settings,
      label: 'Settings',
      route: '/settings/',
    ),
  ];

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    final sidebarTheme = Theme.of(context).extension<SidebarThemeExtension>()!;
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: sidebarTheme.canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: TextStyle(color: sidebarTheme.textColor),
        selectedTextStyle: TextStyle(color: sidebarTheme.textColor),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          border: Border.all(color: sidebarTheme.canvasColor),
        ),
        selectedIconTheme: IconThemeData(
          color: sidebarTheme.activeIconColor,
          size: 24,
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sidebarTheme.actionColor.withValues(alpha: 0.37),
          ),
          gradient: LinearGradient(
            colors: [
              sidebarTheme.accentCanvasColor,
              sidebarTheme.accentCanvasColor,
              sidebarTheme.actionColor,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 30,
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: sidebarTheme.textColor,
          size: 20,
        ),
      ),
      extendedTheme: SidebarXTheme(
        width: 250,
        decoration: BoxDecoration(
          color: sidebarTheme.canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(10),
      ),
      footerDivider: Divider(
        color: sidebarTheme.textColor,
        thickness: 0.5,
      ),
      headerBuilder: (context, extended) {
        return SizedBox(
          width: double.infinity,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _controller.toggleExtended,
            child: DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedLogo(extended: extended),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: extended ? 50 : 0,
                    margin: extended
                        ? const EdgeInsets.only(top: 10)
                        : EdgeInsets.zero,
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: extended ? 1 : 0,
                      child: Text(
                        'HitBeat',
                        style: TextStyle(
                          color: sidebarTheme.textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      items: _items,
      footerItems: _footerItems,
      footerFitType: FooterFitType.fit,
      toggleButtonBuilder: (context, extended) {
        return const SizedBox(
          height: 10,
        );
      },
    );
  }
}

class _SidebarItem extends SidebarXItem {
  _SidebarItem({
    required this.route,
    super.icon,
    super.label,
    dynamic Function()? onTap,
  }) : super(
          onTap: () {
            Modular.to.navigate(route);
            if (onTap != null) onTap();
          },
        );
  final String route;
}
