import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/views/state/engine_view_state.dart';
import 'fake_engine_bridge.dart';

void main() {
  test(
    'Envía modos al servidor y posición al engine sin cambiar el estado antes de confirmar',
    () async {
      final bridge = FakeEngineBridge()..playbackEnabled = true;
      final controller = EngineController(bridge);
      final view = EngineViewState(controller);
      addTearDown(view.dispose);
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.start();
      bridge.connected();
      bridge.stream.add({
        'type': 'status',
        'report': {
          'applied_config_revision': 3,
          'zones': [
            {'zone_id': '1', 'song_id': '5', 'state': 'playing', 'volume': 60},
          ],
        },
        'zones': [
          {
            'zone_id': '1',
            'name': 'Terraza',
            'playlist': 'Ambient',
            'duration_ms': 90000,
            'position_ms': 1000,
            'shuffle': false,
            'repeat_mode': 'off',
            'continuous_playback': true,
          },
        ],
      });
      expect(view.canSetPlaybackModes, isTrue);
      view.toggleShuffle();
      expect(bridge.playbackRequests.last['shuffle'], isTrue);
      expect(view.selected.shuffle, isFalse);
      bridge.playbackResult('succeeded');
      await Future<void>.delayed(Duration.zero);
      view.toggleRepeat();
      expect(bridge.playbackRequests.last['repeat_mode'], 'track');
      bridge.playbackResult('succeeded');
      await Future<void>.delayed(Duration.zero);
      view.toggleAutoAdvance();
      expect(bridge.playbackRequests.last['continuous_playback'], isFalse);
      bridge.playbackResult('succeeded');
      await Future<void>.delayed(Duration.zero);
      expect(view.canSeek, isTrue);
      view.seek(42);
      expect(bridge.playbackRequests.last['action'], 'seek');
      expect(bridge.playbackRequests.last['position_ms'], 42000);
      expect(view.selected.positionMs, 1000);
      bridge.playbackResult('succeeded');
      await Future<void>.delayed(Duration.zero);
    },
  );
  test('Muestra metadatos y modos enviados por Laravel', () async {
    final bridge = FakeEngineBridge();
    final controller = EngineController(bridge);
    final view = EngineViewState(controller);
    addTearDown(view.dispose);
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.start();
    bridge.connected();
    bridge.stream.add({
      'type': 'status',
      'performance': {
        'cpu_percent': 4.2,
        'heap_bytes': 20971520,
        'uptime_seconds': 123,
      },
      'report': {
        'applied_config_revision': 4,
        'zones': [
          {'zone_id': '1', 'state': 'playing', 'song_id': '5', 'volume': 60},
        ],
      },
      'zones': [
        {
          'zone_id': '1',
          'name': 'Terraza',
          'playlist': 'Ambient',
          'songs': ['5', '6'],
          'cover_path': 'C:/cache/playlist.img',
          'shuffle': true,
          'repeat_mode': 'playlist',
          'continuous_playback': true,
          'song_metadata': [
            {
              'song_id': '5',
              'title': 'Black Tide',
              'artist': 'Artista',
              'cover_path': 'C:/cache/individual.img',
            },
            {'song_id': '6', 'title': 'Otra canción', 'artist': null},
          ],
        },
      ],
    });
    expect(view.track.title, 'Black Tide');
    expect(view.cpu, 4.2);
    expect(view.heapBytes, 20971520);
    expect(view.uptimeSeconds, 123);
    expect(view.configurationRevision, 4);
    expect(view.serverSynced, isTrue);
    expect(view.lastHeartbeat, isNotNull);
    expect(view.track.artist, 'Artista');
    expect(view.track.coverPath, 'C:/cache/individual.img');
    expect(view.selected.coverPath, 'C:/cache/playlist.img');
    expect(view.selected.songMetadata['6']!.coverPath, 'C:/cache/playlist.img');
    expect(view.selected.songMetadata['6']!.artist, 'Artista no reportado');
    expect(view.selected.shuffle, isTrue);
    expect(view.selected.repeatMode, 'playlist');
    expect(view.selected.continuousPlayback, isTrue);
    expect(view.canControlZones, isFalse);
  });
  late FakeEngineBridge bridge;
  late EngineController controller;
  late EngineViewState view;
  setUp(() {
    bridge = FakeEngineBridge();
    controller = EngineController(bridge);
    view = EngineViewState(controller);
  });
  tearDown(() {
    view.dispose();
    controller.dispose();
  });

  test(
    'Producción inicia sin datos de muestra ni métricas inventadas',
    () async {
      await controller.initialize();
      expect(view.isSimulated, isFalse);
      expect(view.zones, isEmpty);
      expect(view.hasSelection, isFalse);
      expect(view.cpu, isNull);
      expect(view.latencyMs, isNull);
      expect(view.track.title, 'Sin canción reportada');
      expect(view.server, 'https://example.test');
      expect(view.canControlZones, isFalse);
    },
  );
  test('Inicio, snapshot real y parada se reflejan en la UI', () async {
    await controller.initialize();
    view.toggleEngine();
    await Future<void>.delayed(Duration.zero);
    expect(bridge.starts, 1);
    bridge.connected();
    expect(view.connected, isTrue);
    expect(view.zones.single.id, '1');
    expect(view.selected.name, 'Terraza');
    expect(view.selected.volume, 60);
    expect(view.selected.source, 'Ambient');
    expect(view.track.title, 'Canción 5');
    expect(view.selected.positionMs, isNull);
    expect(view.activeZones, 1);
    expect(view.canSetVolume, isFalse);
    view.setVolume(0, 10);
    expect(bridge.playbackRequests, isEmpty);
    expect(view.selected.volume, 60);
    view.toggleEngine();
    await Future<void>.delayed(Duration.zero);
    expect(bridge.stops, 1);
    expect(view.activeZones, 0);
    expect(view.selected.playing, isFalse);
  });
  test(
    'Selección por ID sobrevive reordenado y se limpia al eliminar zonas',
    () async {
      await controller.initialize();
      await controller.start();
      void report(List<String> ids) => bridge.stream.add({
        'type': 'status',
        'report': {
          'zones': [
            for (final id in ids)
              {
                'zone_id': id,
                'state': 'paused',
                'volume': 25,
                'channel_mode': 'mono',
              },
          ],
        },
        'zones': [
          for (final id in ids)
            {'zone_id': id, 'name': 'Zona $id', 'playlist': ''},
        ],
      });
      report(['A', 'B']);
      view.select(1);
      report(['B', 'A']);
      expect(view.selected.id, 'B');
      report([]);
      expect(view.hasSelection, isFalse);
      expect(view.selected.name, 'Sin zona seleccionada');
    },
  );
  test(
    'Evento incompatible muestra error recuperable sin excepción de stream',
    () async {
      await controller.initialize();
      bridge.stream.add({'type': 'status', 'report': 'incompatible'});
      expect(controller.error, contains('evento incompatible'));
      expect(view.error, isNotEmpty);
    },
  );
  test(
    'Configuración faltante y proceso externo no permiten iniciar otro motor',
    () async {
      bridge.configured = false;
      await controller.initialize();
      expect(view.needsConfiguration, isTrue);
      expect(view.canToggleEngine, isFalse);
      bridge.configured = true;
      bridge.externalRunning = true;
      await controller.refresh();
      expect(view.engineRunning, isTrue);
      expect(view.canToggleEngine, isFalse);
    },
  );
}
