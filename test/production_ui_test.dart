import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/main.dart';
import 'package:utrack_v1/views/layout/utrack_header.dart';
import 'package:utrack_v1/views/state/engine_view_state.dart';
import 'package:utrack_v1/views/widgets/player_bar.dart';
import 'package:utrack_v1/views/widgets/ui_controls.dart';
import 'fake_engine_bridge.dart';

void main() {
  testWidgets(
    'Producción usa estado real, solicita configuración y nunca inserta demos',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 950);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bridge = FakeEngineBridge()..configured = false;
      final controller = EngineController(bridge);
      await tester.pumpWidget(MainApp(controller: controller));
      await tester.pumpAndSettle();
      expect(
        tester.widget<PlayerBar>(find.byType(PlayerBar)).state,
        isA<EngineViewState>(),
      );
      expect(find.text('Conecta tu equipo'), findsOneWidget);
      expect(find.textContaining('Hotel Valhalla'), findsNothing);
      expect(find.textContaining('Datos simulados'), findsNothing);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'https://configured.example.test');
      await tester.enterText(fields.at(1), 'test-only-secret');
      await tester.ensureVisible(find.text('Guardar configuración'));
      await tester.tap(find.text('Guardar configuración'));
      await tester.pumpAndSettle();
      expect(bridge.settings.server, 'https://configured.example.test');
      expect(bridge.savedToken, 'test-only-secret');
      final tokenField = tester.widget<TextFormField>(
        find.byType(TextFormField).at(1),
      );
      expect(tokenField.controller!.text, isEmpty);
      await tester.ensureVisible(find.text('Guardar y conectar'));
      await tester.tap(find.text('Guardar y conectar'));
      await tester.pumpAndSettle();
      bridge.connected();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Abrir navegación'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Inicio'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Canción 5'), findsWidgets);
      expect(
        tester
            .widgetList<Slider>(find.byType(Slider))
            .every((slider) => slider.onChanged == null),
        isTrue,
      );
      for (final control in tester.widgetList<UiIconControl>(
        find.byType(UiIconControl),
      )) {
        if ([
          'Canción siguiente',
          'Canción anterior',
          'Repetir',
          'Aleatorio',
        ].contains(control.label)) {
          expect(control.onPressed, isNull);
        }
      }
      await tester.tap(find.byTooltip('Abrir navegación'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
      expect(
        tester.widget<UtrackHeader>(find.byType(UtrackHeader)).connected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
