import '../models/engine_settings.dart';

abstract interface class PlaybackEngineBridge {
  Future<void> sendPlayback(Map<String, dynamic> request);
}

abstract class EngineBridge {
  Stream<Map<String, dynamic>> get events;
  Future<Map<String, dynamic>> inspect();
  Future<void> configure(EngineSettings settings, String token);
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
}
