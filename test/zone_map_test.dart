import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/views/design/ui_theme.dart';
import 'package:utrack_v1/views/widgets/zone_map.dart';
import 'package:utrack_v1/views/widgets/ui_controls.dart';

void main() {
  for (final width in [390.0, 1280.0]) {
    testWidgets('Zonas: selección, volumen y estado a $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: UiTheme.dark,
          home: const Scaffold(body: SingleChildScrollView(child: ZoneMap())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Plano no disponible'), findsNothing);
      expect(find.text('Zona seleccionada: Sala'), findsOneWidget);
      await tester.tap(find.byTooltip('Terraza · 72% · Activa'));
      await tester.pump();
      expect(find.text('Zona seleccionada: Terraza'), findsOneWidget);
      final slider = find.descendant(
        of: find.byWidgetPredicate(
          (widget) => widget is UiSlider && widget.label == 'Volumen Terraza',
        ),
        matching: find.byType(Slider),
      );
      await tester.ensureVisible(slider);
      await tester.tapAt(tester.getCenter(slider));
      await tester.pump();
      expect(tester.widget<Slider>(slider).value, lessThan(72));
      final toggle = find.byTooltip('Desactivar Terraza (simulado)');
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pump();
      expect(find.byTooltip('Activar Terraza (simulado)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
