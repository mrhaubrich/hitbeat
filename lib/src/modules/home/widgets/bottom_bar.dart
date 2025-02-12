import 'package:flutter/material.dart';
import 'package:flutter_desktop_template/src/modules/home/controllers/bottom_bar_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// The bottom bar of the application.
class BottomBar extends StatelessWidget {
  /// Creates the bottom bar.
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Modular.get<BottomBarController>(),
      builder: (context, child) {
        final controller = Modular.get<BottomBarController>();
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCirc,
          height: controller.isBottomBarVisible ? 60 : 0,
          margin: EdgeInsets.only(
            bottom: controller.isBottomBarVisible ? 10 : 0,
            left: 10,
            right: 10,
          ),
          decoration: BoxDecoration(
            color: controller.isBottomBarVisible ? Colors.blue : Colors.white,
            borderRadius: controller.isBottomBarVisible
                ? const BorderRadius.all(Radius.circular(14))
                : null,
          ),
          child: const Center(
            child: Text('Bottom Bar'),
          ),
        );
      },
    );
  }
}
