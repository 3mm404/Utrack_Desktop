import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/views/design/ui_theme.dart';
import 'package:utrack_v1/views/state/zone_preview_state.dart';
import 'package:utrack_v1/views/widgets/player_bar.dart';
import 'package:utrack_v1/views/layout/utrack_shell.dart';
import 'package:utrack_v1/views/widgets/engine_status_panel.dart';

void main() {
  testWidgets('Reloj simulado inicia, pausa y se libera al cerrar', (
    tester,
  ) async {
    final state = ZonePreviewState();
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: Scaffold(body: PlayerBar(state: state)),
      ),
    );
    state.togglePlayback();
    await tester.pump(const Duration(seconds: 2));
    expect(state.selected.progress, 86);
    state.togglePlayback();
    await tester.pump(const Duration(seconds: 2));
    expect(state.selected.progress, 86);
    state.togglePlayback();
    await tester.pumpWidget(const SizedBox());
    state.dispose();
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
  testWidgets('Shell sincroniza parada de motor, indicadores y controles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: const UtrackShell(
          status: '',
          connected: false,
          settings: SizedBox(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Dispositivos'));
    await tester.pumpAndSettle();
    final stop = find.text('Detener motor simulado');
    await tester.ensureVisible(stop);
    await tester.tap(stop);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<EngineStatusPanel>(find.byType(EngineStatusPanel))
          .activeZones,
      0,
    );
    final player = tester.widget<PlayerBar>(find.byType(PlayerBar));
    expect(player.state!.engineRunning, isFalse);
    expect(player.state!.connected, isFalse);
    await tester.tap(find.byTooltip('Reproducir vista previa'));
    await tester.pump();
    expect(player.state!.selected.playing, isFalse);
    await tester.pumpWidget(const SizedBox());
  });
}
