import 'package:flutter/material.dart';
import 'controllers/engine_controller.dart';
import 'services/engine_bridge_factory.dart';
import 'views/engine_dashboard.dart';
import 'views/design/ui_theme.dart';
import 'views/design/ui_appearance.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UiAppearance.initialize();
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
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: UiAppearance.mode,
    builder: (context, mode, _) => MaterialApp(
      title: 'Utrack · Engine',
      debugShowCheckedModeBanner: false,
      theme: UiTheme.light,
      darkTheme: UiTheme.dark,
      themeMode: mode,
      home: EngineDashboard(controller: controller, testMode: testMode),
    ),
  );
}
