import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/views/state/engine_view_state.dart';
import 'fake_engine_bridge.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/views/design/ui_theme.dart';
import 'package:utrack_v1/views/layout/utrack_shell.dart';

void main() {
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
  for (final size in [
    const Size(1672, 941),
    const Size(1280, 850),
    const Size(720, 800),
    const Size(390, 844),
    const Size(1280, 650),
  ]) {
    testWidgets('Revisión visual ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bridge = FakeEngineBridge();
      final controller = EngineController(bridge);
      await controller.initialize();
      await controller.start();
      bridge.connected();
      final engineState = EngineViewState(controller);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: UiTheme.dark,
            home: UtrackShell(
              state: engineState,
              testMode: false,
              status: 'Sin conexión',
              connected: false,
              settings: const SizedBox(),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        final context = key.currentContext!;
        await precacheImage(
          const AssetImage('assets/images/zone_floor_plan_v2.png'),
          context,
        );
        await precacheImage(
          const AssetImage('assets/images/audio_interface.png'),
          context,
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('build/previews').create(recursive: true);
        await File(
          'build/previews/stage9-${size.width.toInt()}x${size.height.toInt()}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox());
      engineState.dispose();
      controller.dispose();
    });
  }
  testWidgets('Texto ampliado y movimiento reducido sin desbordamientos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bridge = FakeEngineBridge();
    final controller = EngineController(bridge);
    await controller.initialize();
    await controller.start();
    bridge.connected();
    final engineState = EngineViewState(controller);
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.5),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: UtrackShell(
          state: engineState,
          testMode: false,
          status: 'Motor listo · simulado',
          connected: true,
          settings: SizedBox(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    engineState.dispose();
    controller.dispose();
  });
}
