import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/views/design/ui_theme.dart';
import 'package:utrack_v1/views/state/engine_view_state.dart';
import 'package:utrack_v1/views/widgets/zone_cards.dart';

import 'fake_engine_bridge.dart';

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
  for (final width in [390.0, 1280.0]) {
    testWidgets('Zone cards control the chosen zone at $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bridge = FakeEngineBridge()..playbackEnabled = true;
      final controller = EngineController(bridge);
      final state = EngineViewState(controller);
      await controller.initialize();
      await controller.start();
      controller.capabilities.add('volume');
      bridge.connected();
      bridge.stream.add({
        'type': 'status',
        'report': {
          'applied_config_revision': 3,
          'zones': [
            {'zone_id': '1', 'state': 'playing', 'volume': 60},
            {'zone_id': '2', 'state': 'stopped', 'volume': 30},
          ],
        },
        'zones': [
          {'zone_id': '1', 'name': 'Terraza', 'playlist': 'Ambient'},
          {'zone_id': '2', 'name': 'Barra', 'playlist': 'Lounge'},
        ],
      });
      var libraryOpened = false;
      final previewKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: width < 600 ? UiTheme.dark : UiTheme.light,
          home: RepaintBoundary(
            key: previewKey,
            child: Scaffold(
              body: SingleChildScrollView(
                child: ListenableBuilder(
                  listenable: state,
                  builder: (context, _) => ZoneCards(
                    state: state,
                    onLibrary: () => libraryOpened = true,
                    onConfigure: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Terraza'), findsWidgets);
      expect(find.text('Barra'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final boundary =
          previewKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('build/previews').create(recursive: true);
        await File(
          'build/previews/studio-zones-${width.toInt()}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.tap(find.text('Barra'));
      await tester.pumpAndSettle();
      expect(bridge.playbackRequests, isEmpty);
      await tester.ensureVisible(find.byTooltip('Reproducir Barra'));
      await tester.tap(find.byTooltip('Reproducir Barra'));
      await tester.pump();
      expect(bridge.playbackRequests.last['zone_id'], '2');
      expect(bridge.playbackRequests.last['action'], 'play');
      expect(state.selected.playing, isFalse);
      bridge.playbackResult('succeeded');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(Slider).last);
      await tester.drag(find.byType(Slider).last, const Offset(40, 0));
      await tester.pump(const Duration(milliseconds: 250));
      expect(bridge.playbackRequests.last['zone_id'], '2');
      expect(bridge.playbackRequests.last['action'], 'volume');
      bridge.playbackResult('succeeded');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terraza').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Elegir música'));
      await tester.tap(find.text('Elegir música'));
      expect(libraryOpened, isTrue);
      expect(state.selected.id, '1');
      await tester.pumpWidget(const SizedBox());
      state.dispose();
      controller.dispose();
    });
  }
}
