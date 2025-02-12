import 'package:flutter/material.dart';
import 'package:flutter_desktop_template/src/colors.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:sidebarx/sidebarx.dart';

/// Sidebar controller.
class MySideBarController extends SidebarXController {
  /// Sidebar controller.
  MySideBarController() : super(selectedIndex: 0);
}

/// Sidebar widget.
class Sidebar extends StatelessWidget {
  /// Sidebar widget.
  const Sidebar({
    required this.controller,
    super.key,
  });
  static final _items = [
    _SidebarItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard/',
    ),
    _SidebarItem(
      icon: Icons.shopping_cart,
      label: 'Shop',
      route: '/shop/',
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

  /// The controller of the sidebar.
  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: const TextStyle(color: Colors.white),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            ),
          ],
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: SidebarXTheme(
        width: 250,
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(10),
      ),
      footerDivider: const Divider(
        color: Colors.white,
        thickness: 0.5,
      ),
      headerBuilder: (context, extended) {
        return InkWell(
          onTap: controller.toggleExtended,
          child: DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: extended ? 1 : 0,
                  child: const FlutterLogo(),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: extended ? 50 : 0,
                  margin: extended
                      ? const EdgeInsets.only(top: 10)
                      : EdgeInsets.zero,
                  child: const Text(
                    'Flutter Desktop',
                    style: TextStyle(
                      color: white,
                      fontSize: 24,
                    ),
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                ),
              ],
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
            if (onTap != null) {
              onTap();
            }
          },
        );
  final String route;
}
