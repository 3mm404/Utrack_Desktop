import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/views/state/engine_view_state.dart';
import 'fake_engine_bridge.dart';

void main() {
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
    expect(() => view.setVolume(0, 10), throwsUnsupportedError);
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
