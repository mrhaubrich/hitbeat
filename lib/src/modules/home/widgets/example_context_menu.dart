import 'package:flutter/material.dart';
import 'package:super_context_menu/super_context_menu.dart';

/// An example context menu widget.
class ExampleContextMenu extends StatelessWidget {
  /// Creates an example context menu widget.
  const ExampleContextMenu({
    required this.child,
    super.key,
  });

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ContextMenuWidget(
      child: child,
      menuProvider: (context) {
        return Menu(
          title: 'Menu',
          children: [
            MenuAction(
              title: 'Menu Item 2',
              callback: () {},
              image: MenuImage.icon(Icons.ac_unit),
            ),
            MenuAction(
              title: 'Menu Item 3',
              callback: () {},
              image: MenuImage.icon(Icons.access_alarm),
            ),
            MenuSeparator(),
            Menu(
              title: 'Submenu',
              children: [
                MenuAction(
                  title: 'Submenu Item 1',
                  callback: () {},
                  image: MenuImage.icon(Icons.access_time),
                ),
                MenuAction(
                  title: 'Submenu Item 2',
                  callback: () {},
                  image: MenuImage.icon(Icons.accessibility),
                ),
                Menu(
                  title: 'Nested Submenu',
                  children: [
                    MenuAction(
                      title: 'Submenu Item 1',
                      callback: () {},
                      image: MenuImage.icon(Icons.accessible_forward),
                    ),
                    MenuAction(
                      title: 'Submenu Item 2',
                      callback: () {},
                      image: MenuImage.icon(Icons.accessible),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
