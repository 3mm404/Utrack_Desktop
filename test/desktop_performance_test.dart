import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/views/state/engine_view_state.dart';
import 'package:utrack_v1/views/widgets/accessible_controls.dart';
import 'package:utrack_v1/views/widgets/assigned_playlist_panel.dart';
import 'package:utrack_v1/views/widgets/audio_state_builder.dart';

import 'fake_engine_bridge.dart';

void catalogStatus(
  FakeEngineBridge bridge,
  List<Map<String, dynamic>> playlists,
) {
  bridge.stream.add({
    'type': 'status',
    'server_control': true,
    'playlists': playlists,
    'report': {
      'applied_config_revision': 3,
      'zones': [
        {
          'zone_id': '1',
          'state': 'playing',
          'volume': 60,
          'song_id': '5',
          'channel_mode': 'stereo',
          'output': {
            'channels': [1, 2],
          },
        },
      ],
    },
    'zones': [
      {'zone_id': '1', 'name': 'Terraza', 'playlist': 'Ambient'},
    ],
  });
}

void main() {
  testWidgets('playback ticks do not rebuild unchanged sections', (
    tester,
  ) async {
    final source = ChangeNotifier();
    var title = 'TEST';
    var builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AudioStateBuilder(
          listenable: source,
          select: () => [title],
          builder: (_) {
            builds++;
            return Text(title);
          },
        ),
      ),
    );

    for (var i = 0; i < 50; i++) {
      source.notifyListeners();
      await tester.pump();
    }
    expect(builds, 1);
    title = 'Otra playlist';
    source.notifyListeners();
    await tester.pump();
    expect(builds, 2);
    expect(find.text(title), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    source.dispose();
  });

  test(
    'unchanged catalogs retain identity and changed artwork invalidates them',
    () async {
      final bridge = FakeEngineBridge();
      final controller = EngineController(bridge);
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.start();
      bridge.connected();
      Map<String, dynamic> playlist(String cover) => {
        'playlist_id': '6',
        'name': 'TEST',
        'songs': [
          {'song_id': '344', 'title': 'Track', 'cover_path': cover},
        ],
      };
      catalogStatus(bridge, [playlist('first.img')]);
      final original = controller.playlists;
      catalogStatus(bridge, [playlist('first.img')]);
      expect(identical(controller.playlists, original), isTrue);
      catalogStatus(bridge, [playlist('second.img')]);
      expect(identical(controller.playlists, original), isFalse);
      expect(controller.playlists.single.songs['344']!.coverPath, 'second.img');
    },
  );

  testWidgets('large playlists build thirty rows and can page to later songs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bridge = FakeEngineBridge()..playbackEnabled = true;
    final controller = EngineController(bridge);
    await controller.initialize();
    await controller.start();
    bridge.connected();
    catalogStatus(bridge, [
      {
        'playlist_id': '6',
        'name': 'Large playlist',
        'songs': [
          for (var i = 1; i <= 90; i++) {'song_id': '$i', 'title': 'Track $i'},
        ],
      },
    ]);
    final state = EngineViewState(controller);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AssignedPlaylistPanel(state: state),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Large playlist'));
    await tester.pumpAndSettle();
    expect(find.text('Track 1'), findsOneWidget);
    expect(find.text('Track 31'), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(30));
    await tester.ensureVisible(find.text('Siguiente'));
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Track 31'), findsOneWidget);
    expect(find.text('Track 1'), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(30));
    await tester.pumpWidget(const SizedBox());
    state.dispose();
    controller.dispose();
  });

  testWidgets('adjacent overlay controls keep distinct accessible anchors', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              Row(
                children: [
                  AccessibleIconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {},
                    tooltip: 'Play test',
                  ),
                  AccessibleIconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () {},
                    tooltip: 'Pause test',
                  ),
                ],
              ),
              AccessibleSlider(
                value: .5,
                onChanged: (_) {},
                semanticFormatterCallback: (_) => 'Volume 50 percent',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Play test'), findsOneWidget);
    expect(find.byTooltip('Pause test'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byType(IconButton).first)
          .getSemanticsData()
          .tooltip,
      'Play test',
    );
    expect(
      tester
          .getSemantics(find.byType(IconButton).last)
          .getSemanticsData()
          .tooltip,
      'Pause test',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });

  testWidgets(
    'Windows slider supports pointer and keyboard without overlay portals',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final semantics = tester.ensureSemantics();
      var value = 25.0;
      var completed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => AccessibleSlider(
                value: value,
                max: 100,
                semanticFormatterCallback: (v) => 'Volume ${v.round()}',
                onChanged: (v) => setState(() => value = v),
                onChangeEnd: (_) => completed++,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(AccessibleSlider));
      await tester.pump();
      expect(value, closeTo(50, 1));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(value, closeTo(51, 1));
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(value, 100);
      expect(completed, 3);
      expect(find.byType(OverlayPortal), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
