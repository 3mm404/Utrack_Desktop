import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/views/design/ui_theme.dart';
import 'package:utrack_v1/views/state/zone_preview_state.dart';
import 'package:utrack_v1/views/widgets/selected_zone_panel.dart';
import 'package:utrack_v1/views/widgets/volume_knob.dart';
import 'package:utrack_v1/views/widgets/zone_map.dart';

void main() {
  testWidgets('Perilla responde a arrastre y teclado; el valor se limita', (
    tester,
  ) async {
    final state = ZonePreviewState();
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: Scaffold(
          body: SingleChildScrollView(child: SelectedZonePanel(state: state)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(VolumeKnob), const Offset(0, -40));
    await tester.pumpAndSettle();
    expect(state.selected.volume, greaterThan(65));
    final before = state.selected.volume;
    await tester.tap(find.byType(VolumeKnob));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(state.selected.volume, before - 1);
    state.setVolume(state.selectedIndex, 200);
    await tester.pump();
    expect(state.selected.volume, 100);
    state.setVolume(state.selectedIndex, -20);
    await tester.pump();
    expect(state.selected.volume, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
  testWidgets('Plano y panel comparten selección y volumen a 390 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = ZonePreviewState();
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                ZoneMap(state: state),
                SelectedZonePanel(state: state),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Terraza · 72% · Activa'));
    await tester.pumpAndSettle();
    expect(state.selected.name, 'Terraza');
    final increase = find.byTooltip('Subir volumen');
    await tester.ensureVisible(increase);
    await tester.tap(increase);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Terraza · 73% · Activa'), findsOneWidget);
    final next = find.byTooltip('Zona siguiente');
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(state.selected.name, 'Cocina');
    expect(find.text('Zona seleccionada: Cocina'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
}
