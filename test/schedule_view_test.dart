import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/main.dart';
import 'package:utrack_v1/views/schedule_view.dart';
import 'package:utrack_v1/views/state/engine_view_state.dart';
import 'fake_engine_bridge.dart';

void main() {
  testWidgets('Abre Programación desde la navegación sin inventar horarios', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = EngineController(FakeEngineBridge());
    await tester.pumpWidget(MainApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Abrir navegación'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Programación'));
    await tester.pumpAndSettle();
    expect(
      find.text('Solo lectura · administrada desde Laravel'),
      findsOneWidget,
    );
    expect(find.text('Sin zonas recibidas'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  for (final width in [400.0, 1200.0]) {
    testWidgets('Refleja programación de solo lectura a $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bridge = FakeEngineBridge();
      final controller = EngineController(bridge);
      final view = EngineViewState(controller);
      await controller.initialize();
      await controller.start();
      bridge.connected();
      bridge.stream.add({
        'type': 'status',
        'report': {
          'zones': [
            {'zone_id': '1', 'state': 'stopped', 'volume': 50},
            {'zone_id': '2', 'state': 'stopped', 'volume': 50},
          ],
        },
        'zones': [
          {
            'zone_id': '1',
            'name': 'Terraza',
            'schedule': {
              'schedule_id': '10',
              'name': 'Horario nocturno',
              'timezone': 'America/Cancun',
              'stop_outside_slots': true,
              'slots': [
                {
                  'slot_id': '20',
                  'days': [5, 6],
                  'starts_at': '22:00',
                  'ends_at': '02:00',
                  'crosses_midnight': true,
                  'playlist_name': 'Lounge',
                  'volume': null,
                },
                {
                  'slot_id': '21',
                  'days': [7],
                  'starts_at': '08:00',
                  'ends_at': '12:00',
                  'crosses_midnight': false,
                  'playlist_name': 'Jazz',
                  'volume': 0,
                },
              ],
            },
          },
          {'zone_id': '2', 'name': 'Lobby', 'schedule': null},
        ],
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ScheduleView(state: view)),
          ),
        ),
      );
      expect(view.zones.first.schedule!.slots.first.volume, isNull);
      expect(find.text('Horario nocturno'), findsOneWidget);
      expect(find.text('Zona horaria: America/Cancun'), findsOneWidget);
      expect(find.text('Vie · Sáb'), findsOneWidget);
      expect(
        find.text('22:00–02:00 · termina al día siguiente'),
        findsOneWidget,
      );
      expect(find.text('Playlist: Lounge'), findsOneWidget);
      expect(find.text('Volumen: sin cambio'), findsOneWidget);
      expect(find.text('Volumen: 0%'), findsOneWidget);
      expect(find.text('Sin programación asignada'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      expect(bridge.playbackRequests, isEmpty);
      await controller.stop();
      await tester.pump();
      expect(
        find.textContaining('Sin actualización del engine'),
        findsOneWidget,
      );
      expect(find.text('Horario nocturno'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      view.dispose();
      controller.dispose();
    });
  }
}
