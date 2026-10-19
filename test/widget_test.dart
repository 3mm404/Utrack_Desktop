import 'package:flutter/material.dart';
import 'package:utrack_v1/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/services/demo_engine_bridge.dart';

void main() {
  test('Demo configura, recibe zonas y se detiene sin motor externo', () async {
    final c = EngineController(DemoEngineBridge());
    try {
      await c.initialize();
      expect(c.canStart, isTrue);
      await c.start();
      await Future<void>.delayed(Duration.zero);
      expect(c.connected, isTrue);
      expect(c.zones.length, 2);
      await c.stop();
      await Future<void>.delayed(Duration.zero);
      expect(c.running, isFalse);
    } finally {
      c.dispose();
    }
  });
  testWidgets('Test visible y navegación usable en pantalla de 390 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MainApp(controller: EngineController(DemoEngineBridge()), testMode: true),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('MODO TEST'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.byTooltip('Abrir ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Conecta tu equipo'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
