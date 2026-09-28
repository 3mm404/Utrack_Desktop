import 'package:flutter/material.dart';
import 'controllers/engine_controller.dart';
import 'services/process_engine_bridge.dart';
import 'views/engine_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp(controller: EngineController(ProcessEngineBridge())));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.controller});
  final EngineController controller;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Utrack · Engine',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff57d5be),
        brightness: Brightness.dark,
        surface: const Color(0xff141d2b),
      ),
      scaffoldBackgroundColor: const Color(0xff0c1320),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xff0e1725),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    ),
    home: EngineDashboard(controller: controller),
  );
}
