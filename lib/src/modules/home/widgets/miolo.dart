import 'package:flutter/material.dart';

/// The widget that represents the main content of the application.
class Miolo extends StatelessWidget {
  /// The widget that represents the main content of the application.
  const Miolo({
    required this.child,
    super.key,
    this.appBar,
  });

  /// Child widget that will be displayed in the main content.
  final Widget child;

  /// The app bar of the application.
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: child,
    );
  }
}
