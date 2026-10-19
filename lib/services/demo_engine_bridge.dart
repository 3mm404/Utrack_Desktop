import 'dart:async';
import '../models/engine_settings.dart';
import 'engine_bridge.dart';

/// In-memory preview. Does not start processes, store tokens, or play audio.
class DemoEngineBridge implements EngineBridge {
  final _events = StreamController<Map<String, dynamic>>.broadcast();
  EngineSettings _settings = const EngineSettings(
    server: 'https://demo.example.com',
  );
  Timer? _timer;
  @override
  Stream<Map<String, dynamic>> get events => _events.stream;
  @override
  Future<Map<String, dynamic>> inspect() async => {
    'protocol': 1,
    'version': 'TEST',
    'configured': true,
    'running': false,
    'drivers': <String>[],
    'settings': _settings.toJson(),
    'data_directory': 'Solo memoria · datos simulados',
  };
  @override
  Future<void> configure(EngineSettings settings, String token) async {
    _settings = settings;
  }

  @override
  Future<void> start() async {
    if (_timer != null) return;
    _events.add({'type': 'connection', 'channel': 'sync', 'connected': true});
    _events.add({
      'type': 'connection',
      'channel': 'heartbeat',
      'connected': true,
    });
    _snapshot();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _snapshot());
  }

  void _snapshot() {
    _events.add({
      'type': 'status',
      'report': {
        'applied_config_revision': 1,
        'zones': [
          for (var i = 1; i <= 2; i++)
            {
              'zone_id': '$i',
              'state': 'playing',
              'volume': 60,
              'song_id': 'demo',
              'channel_mode': _settings.mode,
              'output': {
                'channels': [i * 2 - 1, i * 2],
              },
            },
        ],
      },
      'zones': [
        {'zone_id': '1', 'name': 'Terraza · demo', 'playlist': 'Ambient'},
        {'zone_id': '2', 'name': 'Salón · demo', 'playlist': 'Lounge'},
      ],
    });
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    if (!_events.isClosed) _events.add({'type': 'exit', 'code': 0});
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _events.close();
  }
}
