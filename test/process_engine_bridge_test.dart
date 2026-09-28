import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/models/engine_settings.dart';
import 'package:utrack_v1/services/process_engine_bridge.dart';

void main() {
  test(
    'real bridge saves encrypted settings and stops its child process',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'utrack-bridge-test-',
      );
      final bridge = ProcessEngineBridge(
        executable: File('windows/engine/engine.exe').absolute.path,
        environment: {'ProgramData': temporary.path},
      );
      final received = <Map<String, dynamic>>[];
      final connection = Completer<void>();
      final events = bridge.events.listen((event) {
        received.add(event);
        if (event['type'] == 'connection' && !connection.isCompleted) {
          connection.complete();
        }
      });
      try {
        expect((await bridge.inspect())['configured'], isFalse);
        await bridge.configure(
          const EngineSettings(server: 'https://127.0.0.1:1'),
          'test-only-credential',
        );
        final info = await bridge.inspect();
        expect(info['configured'], isTrue);
        expect(info.toString(), isNot(contains('test-only-credential')));
        expect(info.toString(), isNot(contains('credential_dpapi')));
        await bridge.configure(
          const EngineSettings(server: 'https://127.0.0.1:1', mode: 'mono'),
          '',
        );
        expect(((await bridge.inspect())['settings'] as Map)['mode'], 'mono');
        await bridge.start();
        await connection.future.timeout(const Duration(seconds: 15));
        expect((await bridge.inspect())['running'], isTrue);
        await bridge.stop();
        expect((await bridge.inspect())['running'], isFalse);
        expect(
          received.any((e) => e['type'] == 'exit' && e['code'] == 0),
          isTrue,
        );
        expect(received.toString(), isNot(contains('test-only-credential')));
      } finally {
        await events.cancel();
        await bridge.dispose();
        await temporary.delete(recursive: true);
      }
    },
    skip:
        !Platform.isWindows ||
        Platform.environment['ENGINE_BRIDGE_TEST'] != '1',
  );
}
