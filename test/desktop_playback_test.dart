import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/main.dart';
import 'package:utrack_v1/views/widgets/ui_controls.dart';
import 'fake_engine_bridge.dart';

void main() {
  test(
    'Commands wait for final result, retain observed state, and reject duplicates',
    () async {
      final bridge = FakeEngineBridge()..playbackEnabled = true;
      final controller = EngineController(bridge);
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.start();
      bridge.connected();
      final result = controller.playback('1', 'pause');
      expect(bridge.playbackRequests.single['config_revision'], 3);
      expect(controller.playbackPending, isTrue);
      expect(controller.zones.single.state, 'playing');
      expect(await controller.playback('1', 'next'), isFalse);
      bridge.playbackResult('pending');
      expect(controller.playbackPending, isTrue);
      bridge.playbackResult('succeeded');
      expect(await result, isTrue);
      expect(controller.playbackPending, isFalse);
      expect(controller.zones.single.state, 'playing');
      final rejected = controller.playback('1', 'play', songId: '6');
      expect(bridge.playbackRequests.last['song_id'], '6');
      bridge.playbackResult('failed', message: 'Revisión distinta');
      expect(await rejected, isFalse);
      expect(controller.error, contains('Revisión distinta'));
      final disconnected = controller.playback('1', 'next');
      await controller.stop();
      expect(await disconnected, isFalse);
      expect(controller.error, contains('cerró'));
    },
  );
  test(
    'Old engine stays read-only and write failures release pending command',
    () async {
      final bridge = FakeEngineBridge();
      final controller = EngineController(bridge);
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.start();
      bridge.connected();
      expect(await controller.playback('1', 'pause'), isFalse);
      expect(bridge.playbackRequests, isEmpty);
      await controller.stop();
      bridge.playbackEnabled = true;
      await controller.refresh();
      await controller.start();
      bridge.connected();
      bridge.failure = StateError('Pipe cerrado');
      expect(await controller.playback('1', 'pause'), isFalse);
      expect(controller.playbackPending, isFalse);
      expect(controller.error, contains('Pipe cerrado'));
    },
  );
  testWidgets(
    'Desktop sends pause, next, previous and selected assigned song',
    (tester) async {
      tester.view.physicalSize = const Size(1500, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bridge = FakeEngineBridge()..playbackEnabled = true;
      final controller = EngineController(bridge);
      await tester.pumpWidget(MainApp(controller: controller));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciar motor'));
      await tester.pumpAndSettle();
      bridge.connected();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Abrir navegación'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Inicio'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Pausar'));
      await tester.pump();
      expect(bridge.playbackRequests.last['action'], 'pause');
      final nextControl = tester
          .widgetList<UiIconControl>(find.byType(UiIconControl))
          .firstWhere((c) => c.label == 'Canción siguiente');
      expect(nextControl.onPressed, isNull);
      bridge.playbackResult('succeeded');
      await tester.pumpAndSettle();
      bridge.connected(state: 'paused');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Reanudar'));
      await tester.pump();
      expect(bridge.playbackRequests.last['action'], 'resume');
      bridge.playbackResult('succeeded');
      bridge.connected();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Canción siguiente'));
      await tester.pump();
      expect(bridge.playbackRequests.last['action'], 'next');
      bridge.playbackResult('succeeded');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Canción anterior'));
      await tester.pump();
      expect(bridge.playbackRequests.last['action'], 'previous');
      bridge.playbackResult('succeeded');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Abrir navegación'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Biblioteca'));
      await tester.pumpAndSettle();
      expect(find.text('Playlist asignada'), findsOneWidget);
      await tester.tap(find.byTooltip('Reproducir canción 6'));
      await tester.pump();
      expect(bridge.playbackRequests.last['action'], 'play');
      expect(bridge.playbackRequests.last['song_id'], '6');
      bridge.playbackResult('succeeded');
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
}
