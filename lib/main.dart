import 'package:flutter/material.dart';
import 'controllers/engine_controller.dart';
import 'services/engine_bridge_factory.dart';
import 'views/engine_dashboard.dart';
import 'views/design/ui_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp(controller: EngineController(createEngineBridge())));
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required this.controller,
    this.testMode = isTestMode,
  });
  final EngineController controller;
  final bool testMode;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Utrack · Engine',
    debugShowCheckedModeBanner: false,
    theme: UiTheme.dark,
    home: EngineDashboard(controller: controller, testMode: testMode),
  );
}
