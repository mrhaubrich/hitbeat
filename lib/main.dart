import 'package:flutter/material.dart';
import 'package:flutter_desktop_template/src/app_widget.dart';
import 'package:flutter_desktop_template/src/modules/app_module.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:menubar/menubar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setApplicationMenu([]);

  return runApp(
    ModularApp(
      module: AppModule(),
      child: const AppWidget(),
    ),
  );
}
