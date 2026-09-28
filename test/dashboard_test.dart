import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/main.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'fake_engine_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = File('C:/Windows/Fonts/segoeui.ttf');
    if (await font.exists()) {
      await (FontLoader(
        'Roboto',
      )..addFont(font.readAsBytes().then(ByteData.sublistView))).load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets('shows live zones and exposes configuration without a console', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bridge = FakeEngineBridge();
    final controller = EngineController(bridge);
    final preview = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: preview,
        child: MainApp(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar motor'));
    await tester.pumpAndSettle();
    bridge.connected();
    await tester.pump();
    expect(find.text('Terraza'), findsOneWidget);
    expect(find.text('Reproduciendo'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final boundary =
        preview.currentContext!.findRenderObject() as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('build/previews').create(recursive: true);
      await File(
        'build/previews/dashboard.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
    await tester.tap(find.text('Detener motor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configuración'));
    await tester.pumpAndSettle();
    expect(find.text('Conecta tu equipo'), findsOneWidget);
    await tester.ensureVisible(find.text('ASIO · canales independientes'));
    await tester.tap(find.text('ASIO · canales independientes'));
    await tester.pumpAndSettle();
    expect(find.text('Nombre exacto del driver ASIO'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('remains usable in a narrow desktop window', (tester) async {
    tester.view.physicalSize = const Size(720, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MainApp(controller: EngineController(FakeEngineBridge())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.tune).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
