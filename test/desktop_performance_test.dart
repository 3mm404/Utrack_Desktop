import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/views/state/engine_view_state.dart';
import 'package:utrack_v1/views/widgets/accessible_controls.dart';
import 'package:utrack_v1/views/widgets/assigned_playlist_panel.dart';
import 'package:utrack_v1/views/widgets/audio_state_builder.dart';
import 'fake_engine_bridge.dart';

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
      Map<String, dynamic> playlist(String cover) => {
        'playlist_id': '6',
        'name': 'TEST',
        'songs': [
          {'song_id': '344', 'title': 'Track', 'cover_path': cover},
        ],
      };
      bridge.connected(playlists: [playlist('first.img')]);
      final original = controller.playlists;
      bridge.connected(playlists: [playlist('first.img')]);
      expect(identical(controller.playlists, original), isTrue);
      bridge.connected(playlists: [playlist('second.img')]);
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
    bridge.connected(
      playlists: [
        {
          'playlist_id': '6',
          'name': 'Large playlist',
          'songs': [
            for (var i = 1; i <= 90; i++)
              {'song_id': '$i', 'title': 'Track $i'},
          ],
        },
      ],
    );
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
    expect(tester.getSemantics(find.byType(IconButton).first).getSemanticsData().tooltip, 'Play test');
    expect(tester.getSemantics(find.byType(IconButton).last).getSemanticsData().tooltip, 'Pause test');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });
}
