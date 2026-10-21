import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/views/configuration_view.dart';
import 'fake_engine_bridge.dart';

void main() {
  testWidgets('Guarda la credencial y conecta desde configuración', (
    tester,
  ) async {
    final bridge = FakeEngineBridge()..configured = false;
    final controller = EngineController(bridge);
    await controller.initialize();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) =>
                  ConfigurationView(controller: controller),
            ),
          ),
        ),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Servidor HTTPS'),
      'https://utracksound.test',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Token del equipo'),
      'credential',
    );
    final connect = find.text('Guardar y conectar');
    await tester.ensureVisible(connect);
    await tester.tap(connect);
    await tester.pumpAndSettle();
    expect(bridge.savedToken, 'credential');
    expect(bridge.settings.server, 'https://utracksound.test');
    expect(bridge.starts, 1);
    expect(controller.running, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
