import '../models/engine_settings.dart';
import 'engine_bridge.dart';

EngineBridge createPlatformBridge() => _UnavailableEngineBridge();

class _UnavailableEngineBridge implements EngineBridge {
  Never _unsupported() => throw UnsupportedError(
    'El motor local requiere la aplicación de escritorio. El navegador no puede ejecutar engine.exe.',
  );
  @override
  Stream<Map<String, dynamic>> get events => const Stream.empty();
  @override
  Future<Map<String, dynamic>> inspect() async => _unsupported();
  @override
  Future<void> configure(EngineSettings settings, String token) async =>
      _unsupported();
  @override
  Future<void> start() async => _unsupported();
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}
