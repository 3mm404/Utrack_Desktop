import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/views/design/ui_theme.dart';
import 'package:utrack_v1/views/state/engine_view_state.dart';
import 'package:utrack_v1/views/widgets/assigned_playlist_panel.dart';
import 'package:utrack_v1/views/widgets/cover_artwork.dart';
import 'fake_engine_bridge.dart';

void main() {
  testWidgets('Consulta playlists y solicita reproducir en la zona elegida', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bridge = FakeEngineBridge()..playbackEnabled = true;
    final controller = EngineController(bridge);
    final state = EngineViewState(controller);
    await controller.initialize();
    await controller.start();
    bridge.connected();
    bridge.stream.add({
      'type': 'status',
      'report': {
        'applied_config_revision': 3,
        'zones': [
          {'zone_id': '1', 'state': 'playing', 'volume': 60},
          {'zone_id': '2', 'state': 'stopped', 'volume': 50},
        ],
      },
      'zones': [
        {'zone_id': '1', 'name': 'Terraza', 'playlist': 'Ambient'},
        {'zone_id': '2', 'name': 'Barra', 'playlist': 'Anterior'},
      ],
      'playlists': [
        {
          'playlist_id': '9',
          'name': 'Night Jazz',
          'songs': [
            {'song_id': '11', 'title': 'Blue Hour', 'artist': 'Quartet'},
          ],
        },
        {'playlist_id': '10', 'name': 'Morning Coffee', 'songs': []},
        {'playlist_id': '12', 'name': 'Soft House', 'songs': []},
        {
          'playlist_id': '7',
          'name': 'Lounge Sunset',
          'songs': [
            {'song_id': '8', 'title': 'Tema Lounge', 'artist': 'Artista'},
          ],
        },
      ],
    });
    final libraryPreviewKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: UiTheme.dark,
        home: RepaintBoundary(
          key: libraryPreviewKey,
          child: Scaffold(
            body: SingleChildScrollView(
              child: AssignedPlaylistPanel(state: state),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barra').last);
    await tester.pumpAndSettle();
    await saveLibraryPreview(tester, libraryPreviewKey, 'library-grid');
    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.pumpAndSettle();
    expect(find.text('No encontramos playlists'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Quartet');
    await tester.pumpAndSettle();
    expect(find.text('Night Jazz'), findsOneWidget);
    expect(find.text('Lounge Sunset'), findsNothing);
    await tester.tap(find.byTooltip('Limpiar búsqueda'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lounge Sunset'));
    await tester.pumpAndSettle();
    expect(find.text('Tema Lounge'), findsOneWidget);
    expect(bridge.playbackRequests, isEmpty);
    await saveLibraryPreview(tester, libraryPreviewKey, 'library-detail');
    await tester.tap(find.text('Todas las playlists'));
    await tester.pumpAndSettle();
    expect(find.text('Night Jazz'), findsOneWidget);
    await tester.tap(find.text('Lounge Sunset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reproducir en Barra'));
    await tester.pump();
    expect(bridge.playbackRequests.last, containsPair('zone_id', '2'));
    expect(bridge.playbackRequests.last, containsPair('playlist_id', '7'));
    expect(
      bridge.playbackRequests.last,
      containsPair('action', 'play_playlist'),
    );
    expect(state.selected.source, 'Anterior');
    expect(state.zones.first.source, 'Ambient');
    bridge.playbackResult(
      'failed',
      message: 'La playlist ya no está disponible.',
    );
    await tester.pumpAndSettle();
    expect(find.text('La playlist ya no está disponible.'), findsOneWidget);
    expect(state.selected.source, 'Anterior');
    await tester.tap(find.byTooltip('Reproducir Tema Lounge'));
    await tester.pump();
    expect(bridge.playbackRequests.last['playlist_id'], '7');
    expect(bridge.playbackRequests.last['song_id'], '8');
    expect(bridge.playbackRequests.last['zone_id'], '2');
    bridge.playbackResult('succeeded');
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    state.dispose();
    controller.dispose();
  });
  setUpAll(() async {
    final font = File('C:/Windows/Fonts/segoeui.ttf');
    if (await font.exists()) {
      await (FontLoader(
        'Roboto',
      )..addFont(font.readAsBytes().then(ByteData.sublistView))).load();
      await (FontLoader(
        'Ahem',
      )..addFont(font.readAsBytes().then(ByteData.sublistView))).load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final width in [390.0, 1100.0]) {
    for (final dark in [false, true]) {
      testWidgets('Playlist con portadas a $width px, oscuro: $dark', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 850);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final bridge = FakeEngineBridge();
        final controller = EngineController(bridge);
        final state = EngineViewState(controller);
        await controller.initialize();
        await controller.start();
        bridge.connected();
        bridge.stream.add({
          'type': 'status',
          'report': {
            'applied_config_revision': 1,
            'zones': [
              {
                'zone_id': '1',
                'state': 'playing',
                'song_id': '5',
                'volume': 60,
              },
            ],
          },
          'zones': [
            {
              'zone_id': '1',
              'name': 'Terraza',
              'playlist': 'Ambient Sessions',
              'songs': ['5', '6'],
              'song_metadata': [
                {'song_id': '5', 'title': 'Ocean Drive', 'artist': 'Artista'},
                {'song_id': '6', 'title': 'Nightfall', 'artist': 'Artista'},
              ],
            },
          ],
        });
        final key = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? UiTheme.dark : UiTheme.light,
            home: RepaintBoundary(
              key: key,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AssignedPlaylistPanel(state: state),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CoverArtwork), findsNWidgets(3));
        expect(find.text('Ambient Sessions'), findsOneWidget);
        expect(
          tester.widgetList<ListTile>(find.byType(ListTile)).first.selected,
          isTrue,
        );
        expect(tester.takeException(), isNull);
        final boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build/previews').create(recursive: true);
          await File(
            'build/previews/playlist-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        bridge.stream.add({
          'type': 'status',
          'report': {
            'applied_config_revision': 1,
            'zones': [
              {
                'zone_id': '1',
                'state': 'playing',
                'song_id': '5',
                'volume': 60,
              },
            ],
          },
          'zones': [
            {
              'zone_id': '1',
              'name': 'Terraza',
              'playlist': 'Ambient Sessions',
              'playlist_id': '7',
            },
          ],
          'playlists': [
            for (var i = 0; i < 4; i++)
              {
                'playlist_id': '${7 + i}',
                'name': [
                  'Ambient Sessions',
                  'Night Jazz',
                  'Morning Coffee',
                  'Lounge Sunset',
                ][i],
                'songs': [
                  {'song_id': '5', 'title': 'Ocean Drive', 'artist': 'Artista'},
                ],
              },
          ],
        });
        await tester.pumpAndSettle();
        expect(find.text('Tus playlists'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await saveLibraryPreview(
          tester,
          key,
          'library-grid-${width.toInt()}-${dark ? 'dark' : 'light'}',
        );
        await tester.pumpWidget(const SizedBox());
        state.dispose();
        controller.dispose();
      });
    }
  }
}

Future<void> saveLibraryPreview(
  WidgetTester tester,
  GlobalKey key,
  String name,
) async {
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/previews').create(recursive: true);
    await File(
      'build/previews/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
