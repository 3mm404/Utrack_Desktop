import 'dart:async';
import 'package:utrack_v1/models/engine_settings.dart';
import 'package:utrack_v1/services/engine_bridge.dart';

class FakeEngineBridge
    implements EngineBridge, PlaybackEngineBridge, AudioCacheEngineBridge {
  final stream = StreamController<Map<String, dynamic>>.broadcast(sync: true);
  EngineSettings settings = const EngineSettings(
    server: 'https://example.test',
  );
  bool configured = true, externalRunning = false;
  int starts = 0, stops = 0;
  String? savedToken;
  Object? failure;
  bool playbackEnabled = false;
  bool audioCacheSupported = false;
  int audioCacheBytes = 0, audioCacheFiles = 0, cacheClears = 0;
  @override
  Future<void> clearAudioCache() async {
    if (failure != null) throw failure!;
    cacheClears++;
    audioCacheBytes = 0;
    audioCacheFiles = 0;
  }

  final List<Map<String, dynamic>> playbackRequests = [];
  @override
  Future<void> sendPlayback(Map<String, dynamic> request) async {
    if (failure != null) throw failure!;
    playbackRequests.add(request);
  }

  void playbackResult(String outcome, {String? message}) {
    stream.add({
      'type': 'command_result',
      'request_id': playbackRequests.last['request_id'],
      'result': {
        'outcome': outcome,
        if (message != null) 'error': {'message': message},
      },
    });
  }

  @override
  Stream<Map<String, dynamic>> get events => stream.stream;
  @override
  Future<Map<String, dynamic>> inspect() async => {
    'protocol': 1,
    'capabilities': [
      if (audioCacheSupported) 'audio_cache_settings',
      if (playbackEnabled) ...[
        'download_playlist',
        'cancel_playlist_download',
        'play',
        'pause',
        'resume',
        'next',
        'previous',
        'playlist_read',
        'seek',
        'playback_modes',
        'play_playlist',
        'song_preference',
      ],
    ],
    'audio_cache_bytes': audioCacheBytes,
    'audio_cache_files': audioCacheFiles,
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

  void connected({
    String state = 'playing',
    Map<String, dynamic>? performance,
    List<Map<String, dynamic>> playlists = const [],
  }) {
    stream.add({'type': 'connection', 'channel': 'sync', 'connected': true});
    stream.add({
      'type': 'connection',
      'channel': 'heartbeat',
      'connected': true,
    });
    stream.add({
      'type': 'status',
      'server_control': true,
      'performance': ?performance,
      'playlists': playlists,
      'report': {
        'applied_config_revision': 3,
        'zones': [
          {
            'zone_id': '1',
            'state': state,
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
        {
          'zone_id': '1',
          'name': 'Terraza',
          'playlist': 'Ambient',
          if (playbackEnabled) 'songs': ['5', '6'],
        },
      ],
    });
  }
}
