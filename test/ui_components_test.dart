import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/views/design/ui_theme.dart';
import 'package:utrack_v1/views/widgets/ui_controls.dart';
import 'package:utrack_v1/views/widgets/configuration_row.dart';

void main() {
  testWidgets('Controles respetan callbacks y estado deshabilitado', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: Scaffold(
          body: Row(
            children: [
              CircularControl(
                icon: Icons.play_arrow,
                label: 'Iniciar prueba',
                onPressed: () => calls++,
              ),
              const UiIconControl(
                icon: Icons.stop,
                label: 'Detener prueba',
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Iniciar prueba'));
    await tester.tap(find.byTooltip('Detener prueba'));
    expect(calls, 1);
  });
  testWidgets('Slider acota el valor y emite cambios en una fila estrecha', (
    tester,
  ) async {
    double? changed;
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: ConfigurationRow(
              label: 'Salida',
              control: UiSlider(
                label: 'Volumen',
                value: 140,
                onChanged: (value) => changed = value,
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.widget<Slider>(find.byType(Slider)).value, 100);
    await tester.tapAt(tester.getCenter(find.byType(Slider)));
    await tester.pump();
    expect(changed, inInclusiveRange(0, 100));
    expect(tester.takeException(), isNull);
  });
}
