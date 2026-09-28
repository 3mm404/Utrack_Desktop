import 'dart:async';
import 'package:utrack_v1/models/engine_settings.dart';
import 'package:utrack_v1/services/engine_bridge.dart';

class FakeEngineBridge implements EngineBridge {
  final stream = StreamController<Map<String, dynamic>>.broadcast(sync: true);
  EngineSettings settings = const EngineSettings(
    server: 'https://example.test',
  );
  bool configured = true, externalRunning = false;
  int starts = 0, stops = 0;
  String? savedToken;
  Object? failure;

  @override
  Stream<Map<String, dynamic>> get events => stream.stream;
  @override
  Future<Map<String, dynamic>> inspect() async => {
    'protocol': 1,
    'version': '0.8.0',
    'configured': configured,
    'running': externalRunning,
    'drivers': ['Dante Virtual Soundcard (x64)'],
    'settings': settings.toJson(),
    'data_directory': r'C:\ProgramData\UtrackSound',
  };
  @override
  Future<void> configure(EngineSettings settings, String token) async {
    if (failure != null) throw failure!;
    this.settings = settings;
    savedToken = token;
    configured = true;
  }

  @override
  Future<void> start() async {
    if (failure != null) throw failure!;
    starts++;
  }

  @override
  Future<void> stop() async {
    stops++;
    stream.add({'type': 'exit', 'code': 0});
  }

  @override
  Future<void> dispose() async {
    await stream.close();
  }

  void connected() {
    stream.add({'type': 'connection', 'channel': 'sync', 'connected': true});
    stream.add({
      'type': 'connection',
      'channel': 'heartbeat',
      'connected': true,
    });
    stream.add({
      'type': 'status',
      'report': {
        'applied_config_revision': 3,
        'zones': [
          {
            'zone_id': '1',
            'state': 'playing',
            'volume': 60,
            'song_id': '5',
            'channel_mode': 'stereo',
            'output': {
              'channels': [1, 2],
            },
          },
        ],
      },
      'zones': [
        {'zone_id': '1', 'name': 'Terraza', 'playlist': 'Ambient'},
      ],
    });
  }
}
