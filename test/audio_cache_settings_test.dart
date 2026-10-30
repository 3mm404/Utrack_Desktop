import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/models/engine_settings.dart';
import 'package:utrack_v1/models/engine_status.dart';
import 'package:utrack_v1/views/widgets/assigned_playlist_panel.dart';
import 'package:utrack_v1/views/state/engine_view_state.dart';
import 'fake_engine_bridge.dart';

void main() {
  test(
    'old engines receive no unknown setting and cannot enable caching',
    () async {
      expect(
        const EngineSettings().toJson().containsKey('audio_cache'),
        isFalse,
      );
      final bridge = FakeEngineBridge();
      final c = EngineController(bridge);
      addTearDown(c.dispose);
      await c.refresh();
      expect(
        await c.save(
          const EngineSettings(
            server: 'https://example.test',
            audioCache: true,
          ),
          '',
        ),
        isFalse,
      );
      expect(bridge.settings.audioCache, isFalse);
    },
  );

  test(
    'cache deletion refreshes storage and is blocked with pending changes or playback',
    () async {
      final bridge = FakeEngineBridge()
        ..audioCacheSupported = true
        ..audioCacheBytes = 4096
        ..audioCacheFiles = 2;
      final c = EngineController(bridge);
      addTearDown(c.dispose);
      await c.refresh();
      c.markDirty();
      expect(await c.clearAudioCache(), isFalse);
      await c.refresh();
      await c.start();
      expect(await c.clearAudioCache(), isFalse);
      await c.stop();
      expect(await c.clearAudioCache(), isTrue);
      expect(bridge.cacheClears, 1);
      expect(c.audioCacheFiles, 0);
      expect(c.audioCacheBytes, 0);
    },
  );

  testWidgets('downloads from library while engine remains running', (
    tester,
  ) async {
    final bridge = FakeEngineBridge()..playbackEnabled = true;
    final c = EngineController(bridge);
    await c.refresh();
    await c.start();
    bridge.connected();
    c.playlists = [
      const PlaylistInfo(
        id: 'p1',
        name: 'Relax',
        songs: {'s1': SongMetadata(title: 'Song')},
      ),
    ];
    final view = EngineViewState(c);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ListenableBuilder(
              listenable: c,
              builder: (context, _) => AssignedPlaylistPanel(state: view),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Descargar playlist'));
    await tester.pump();
    expect(bridge.playbackRequests.single['action'], 'download_playlist');
    expect(bridge.playbackRequests.single['playlist_id'], 'p1');
    expect(bridge.playbackRequests.single['zone_id'], '');
    expect(c.playbackPending, isFalse);
    bridge.playbackResult('succeeded');
    await tester.pumpAndSettle();
    expect(c.running, isTrue);
    expect(bridge.stops, 0);
    expect(c.dirty, isFalse);
    bridge.connected(
      playlists: [
        {
          'playlist_id': 'p1',
          'name': 'Relax',
          'songs': [
            {'song_id': 's1', 'title': 'Song'},
          ],
          'download': {'state': 'ready', 'completed': 1, 'total': 1},
        },
      ],
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Descarga completa'), findsOneWidget);
    expect(find.byTooltip('Verificar y actualizar'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    view.dispose();
    c.dispose();
  });

  testWidgets('shows progress and cancels without stopping playback', (
    tester,
  ) async {
    final bridge = FakeEngineBridge()..playbackEnabled = true;
    final c = EngineController(bridge);
    await c.refresh();
    await c.start();
    bridge.connected();
    c.playlists = [
      const PlaylistInfo(
        id: 'p1',
        name: 'Relax',
        songs: {'s1': SongMetadata(title: 'Song')},
        download: PlaylistDownloadInfo(
          state: 'downloading',
          completed: 1,
          total: 2,
        ),
      ),
    ];
    final view = EngineViewState(c);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AssignedPlaylistPanel(state: view),
          ),
        ),
      ),
    );
    expect(find.text('Descargando 1 de 2 canciones'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0.5,
    );
    await tester.tap(find.byTooltip('Cancelar descarga'));
    await tester.pump();
    expect(
      bridge.playbackRequests.single['action'],
      'cancel_playlist_download',
    );
    bridge.playbackResult('succeeded');
    await tester.pumpAndSettle();
    expect(c.running, isTrue);
    expect(bridge.stops, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    view.dispose();
    c.dispose();
  });
}
