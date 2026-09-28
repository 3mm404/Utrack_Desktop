import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/models/engine_settings.dart';
import 'fake_engine_bridge.dart';

void main() {
  test(
    'requires confirmed sync and heartbeat before reporting connected',
    () async {
      final bridge = FakeEngineBridge();
      final controller = EngineController(bridge);
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.start();
      expect(controller.running, isTrue);
      expect(controller.connected, isFalse);
      bridge.connected();
      expect(controller.connected, isTrue);
      expect(controller.zones.single.name, 'Terraza');
      expect(controller.zones.single.label, 'Reproduciendo');
      bridge.stream.add({
        'type': 'connection',
        'channel': 'heartbeat',
        'connected': false,
        'message': 'Sin red',
      });
      expect(controller.connected, isFalse);
      await controller.stop();
      expect(controller.running, isFalse);
      expect(bridge.stops, 1);
    },
  );

  test('blocks starting with unsaved settings or an external engine', () async {
    final bridge = FakeEngineBridge();
    final controller = EngineController(bridge);
    addTearDown(controller.dispose);
    await controller.initialize();
    controller.markDirty();
    await controller.start();
    expect(bridge.starts, 0);
    bridge.externalRunning = true;
    await controller.refresh();
    await controller.start();
    expect(controller.canConfigure, isFalse);
    expect(bridge.starts, 0);
  });

  test(
    'saves settings without retaining the token and prevents invalid URLs',
    () async {
      final bridge = FakeEngineBridge()..configured = false;
      final controller = EngineController(bridge);
      addTearDown(controller.dispose);
      await controller.initialize();
      expect(
        await controller.save(
          const EngineSettings(server: 'http://example.test'),
          'secret',
        ),
        isFalse,
      );
      expect(bridge.savedToken, isNull);
      expect(
        await controller.save(
          const EngineSettings(server: 'https://example.test'),
          '',
        ),
        isFalse,
      );
      expect(
        await controller.save(
          const EngineSettings(server: 'https://example.test'),
          'secret',
        ),
        isTrue,
      );
      expect(controller.canStart, isTrue);
      expect(
        controller.activity.map((e) => e.message).join(),
        isNot(contains('secret')),
      );
    },
  );

  test('surfaces launch failures and process exits', () async {
    final bridge = FakeEngineBridge()..failure = StateError('Archivo ausente');
    final controller = EngineController(bridge);
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.start();
    expect(controller.running, isFalse);
    expect(controller.error, contains('Archivo ausente'));
    bridge.failure = null;
    await controller.start();
    bridge.connected();
    bridge.stream.add({'type': 'exit', 'code': 1});
    expect(controller.connected, isFalse);
    expect(controller.error, contains('error'));
  });

  test('validates driver, rate, buffer and output channel ranges', () {
    expect(
      const EngineSettings(
        server: 'https://example.test',
        backend: 'asio',
      ).validate(),
      isNotNull,
    );
    expect(
      const EngineSettings(
        server: 'https://example.test',
        backend: 'asio',
        driver: 'Dante',
        channels: 65,
      ).validate(),
      isNotNull,
    );
    expect(
      const EngineSettings(
        server: 'https://example.test',
        backend: 'asio',
        driver: 'Dante',
        bufferSize: 0,
      ).validate(),
      isNotNull,
    );
    expect(
      const EngineSettings(
        server: 'https://example.test',
        backend: 'asio',
        driver: 'Dante',
        sampleRate: 48000,
      ).validate(),
      isNull,
    );
    expect(
      const EngineSettings(
        server: 'https://user:token@example.test',
      ).validate(),
      isNotNull,
    );
  });
}
