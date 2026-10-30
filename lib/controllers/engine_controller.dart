import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/engine_settings.dart';
import '../models/engine_status.dart';
import '../services/engine_bridge.dart';
import '../integrations/engine_api/engine_api_catalog.dart';
import '../integrations/engine_api/engine_api_request.dart';

class EngineController extends ChangeNotifier {
  EngineController(this._bridge) {
    _subscription = _bridge.events.listen(
      _onEvent,
      onError: (Object error) => _fail(error),
    );
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (running) notifyListeners();
      if (externalRunning && !busy && !dirty) unawaited(refresh());
    });
  }

  final EngineBridge _bridge;
  bool _disposed = false;
  late final StreamSubscription<Map<String, dynamic>> _subscription;
  late final Timer _timer;
  EngineSettings settings = const EngineSettings();
  int audioCacheBytes = 0, audioCacheFiles = 0;
  String audioCacheError = '';
  bool get supportsAudioCache => capabilities.contains('audio_cache_settings');
  bool get canClearAudioCache =>
      supportsAudioCache &&
      configured &&
      canConfigure &&
      !dirty &&
      _bridge is AudioCacheEngineBridge;
  List<String> drivers = [];
  List<ZoneStatus> zones = [];
  List<PlaylistInfo> playlists = [];
  bool serverControl = false;
  final List<ActivityEntry> activity = [];
  String version = '—', dataDirectory = '', error = '', driverWarning = '';
  String configurationError = '';
  bool configured = false,
      running = false,
      externalRunning = false,
      busy = false,
      dirty = false;
  bool _sync = false, _heartbeat = false;
  DateTime? lastSnapshot, lastHeartbeat;
  int revision = 0;
  double? cpuPercent;
  int? heapBytes, uptimeSeconds;
  bool get serverSynced => _sync;
  bool get heartbeatHealthy => _heartbeat;
  Set<String> capabilities = {};
  final Map<String, Completer<Map<String, dynamic>>> _commands = {};
  int _requestSequence = 0;
  final Set<String> _downloadCommands = {};
  final Set<String> playlistRequests = {};
  bool get playbackPending =>
      _commands.keys.any((id) => !_downloadCommands.contains(id));
  bool get canDownloadPlaylists =>
      running &&
      fresh &&
      supportsPlayback('download_playlist') &&
      configurationError.isEmpty;

  Future<bool> downloadPlaylist(String id, {bool cancel = false}) async {
    if (playlistRequests.contains(id)) return false;
    playlistRequests.add(id);
    notifyListeners();
    try {
      return await executeEngineRequest(
        EngineApiRequest(
          operation: cancel
              ? EngineOperation.cancelPlaylistDownload
              : EngineOperation.downloadPlaylist,
          zoneId: '',
          playlistId: id,
        ),
      );
    } finally {
      playlistRequests.remove(id);
      notifyListeners();
    }
  }

  bool _stopPending = false;
  bool get stopPending => _stopPending;
  bool supportsPlayback(String action) =>
      _bridge is PlaybackEngineBridge && capabilities.contains(action);

  Future<bool> playback(
    String zoneId,
    String action, {
    String? songId,
    String? playlistId,
    String? preference,
    int? volume,
    int? positionMs,
    bool? shuffle,
    String? repeatMode,
    bool? continuousPlayback,
  }) async {
    final operation = EngineOperation.fromWire(action);
    if (operation == null) {
      _fail(StateError('Operación local no registrada.'));
      return false;
    }
    return executeEngineRequest(
      EngineApiRequest(
        operation: operation,
        zoneId: zoneId,
        songId: songId,
        playlistId: playlistId,
        preference: preference,
        volume: volume,
        positionMs: positionMs,
        shuffle: shuffle,
        repeatMode: repeatMode,
        continuousPlayback: continuousPlayback,
      ),
    );
  }

  /// New integrations use typed requests; playback remains a compatibility shim.
  Future<bool> executeEngineRequest(EngineApiRequest request) async {
    final validation = request.validate();
    if (validation != null) {
      _fail(StateError(validation));
      return false;
    }
    if (!running ||
        !fresh ||
        (!request.operation.isPlaylistDownload &&
            playbackPending &&
            (request.operation != EngineOperation.stop || stopPending)) ||
        !supportsPlayback(request.operation.wireName) ||
        configurationError.isNotEmpty) {
      return false;
    }
    final requestId =
        '${DateTime.now().microsecondsSinceEpoch}-${++_requestSequence}';
    final result = Completer<Map<String, dynamic>>();
    _commands[requestId] = result;
    if (request.operation.isPlaylistDownload) _downloadCommands.add(requestId);
    if (request.operation == EngineOperation.stop) _stopPending = true;
    error = '';
    notifyListeners();
    // Attach timeout/error handling before writing to the process.
    final response = result.future.timeout(const Duration(seconds: 40));
    try {
      await (_bridge as PlaybackEngineBridge).sendPlayback(
        request.toJson(requestId: requestId, revision: revision),
      );
      final value = await response;
      if (value['outcome'] != 'succeeded') {
        final failure = value['error'] as Map?;
        // An explicit local stop may supersede the track still loading.
        if (failure?['code'] == 'command_superseded' && stopPending) {
          return false;
        }
        throw StateError(
          failure?['message']?.toString() ?? 'El motor rechazó la orden.',
        );
      }
      return true;
    } catch (e) {
      if (!result.isCompleted) result.complete({'outcome': 'failed'});
      _fail(
        e is TimeoutException
            ? StateError(
                'El motor no confirmó la orden. Revisa el estado antes de reintentar.',
              )
            : e,
      );
      return false;
    } finally {
      _commands.remove(requestId);
      _downloadCommands.remove(requestId);
      if (request.operation == EngineOperation.stop) _stopPending = false;
      notifyListeners();
    }
  }

  void _cancelPlayback() {
    for (final command in _commands.values) {
      if (!command.isCompleted) {
        command.complete({
          'outcome': 'failed',
          'error': {
            'message': 'El motor se cerró antes de confirmar la orden.',
          },
        });
      }
    }
  }

  bool get fresh =>
      lastSnapshot != null &&
      DateTime.now().difference(lastSnapshot!) < const Duration(seconds: 5);
  bool get connected => running && fresh && _sync && _heartbeat;
  bool get canStart =>
      configured && !running && !externalRunning && !busy && !dirty;
  bool get canConfigure => !running && !externalRunning && !busy;
  String get statusLabel {
    if (externalRunning) return 'Abierto fuera de esta app';
    if (!running) return configured ? 'Motor detenido' : 'Por configurar';
    if (!fresh && lastSnapshot != null) return 'Sin actualización';
    if (connected) {
      return configurationError.isEmpty ? 'Conectado' : 'Revisar configuración';
    }
    return 'Conectando / reintentando';
  }

  Future<void> initialize({bool autoStart = false}) async {
    await refresh();
    if (autoStart && !_disposed && error.isEmpty && canStart) {
      await start();
    }
  }

  Future<void> _inspect() async {
    final info = await _bridge.inspect();
    if (info['protocol'] != 1) {
      throw StateError('El ejecutable no es compatible con esta interfaz.');
    }
    version = info['version'] as String? ?? '—';
    capabilities = (info['capabilities'] as List? ?? [])
        .whereType<String>()
        .toSet();
    dataDirectory = info['data_directory'] as String? ?? '';
    audioCacheBytes = info['audio_cache_bytes'] as int? ?? 0;
    audioCacheFiles = info['audio_cache_files'] as int? ?? 0;
    audioCacheError = info['audio_cache_error'] as String? ?? '';
    drivers = (info['drivers'] as List? ?? []).cast<String>();
    configured = info['configured'] == true;
    externalRunning = !running && info['running'] == true;
    driverWarning = info['driver_error'] as String? ?? '';
    if (info['settings'] is Map<String, dynamic>) {
      settings = EngineSettings.fromJson(
        info['settings'] as Map<String, dynamic>,
      );
    }
    final configError = info['configuration_error'] as String?;
    if (configError != null) throw StateError(configError);
  }

  Future<void> refresh() async {
    if (busy || running) return;
    busy = true;
    error = '';
    notifyListeners();
    try {
      await _inspect();
      dirty = false;
    } catch (e) {
      _fail(e);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void markDirty() {
    dirty = true;
    notifyListeners();
  }

  void clearActivity() {
    activity.clear();
    notifyListeners();
  }

  Future<bool> save(EngineSettings value, String token) async {
    if (!canConfigure) {
      _fail(
        externalRunning
            ? 'Cierra el engine abierto fuera de Desktop y pulsa Actualizar.'
            : 'Detén el motor antes de guardar la credencial.',
      );
      return false;
    }
    final validation = value.validate();
    if (value.audioCache && !supportsAudioCache) {
      _fail('Actualiza el motor para activar las descargas protegidas.');
      return false;
    }
    if (validation != null || (!configured && token.trim().isEmpty)) {
      _fail(validation ?? 'Ingresa el token del equipo generado en Laravel.');
      return false;
    }
    busy = true;
    error = '';
    notifyListeners();
    try {
      await _bridge.configure(value, token.trim());
      await _inspect();
      dirty = false;
      _log('Configuración guardada en el motor.');
      return true;
    } catch (e) {
      _fail(e);
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> clearAudioCache() async {
    if (!canClearAudioCache) return false;
    busy = true;
    error = '';
    notifyListeners();
    try {
      await (_bridge as AudioCacheEngineBridge).clearAudioCache();
      await _inspect();
      _log('Descargas de audio eliminadas de este equipo.');
      return true;
    } catch (e) {
      _fail(e);
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> start() async {
    if (!canStart) return;
    busy = true;
    error = '';
    zones = [];
    playlists = [];
    cpuPercent = null;
    heapBytes = null;
    uptimeSeconds = null;
    configurationError = '';
    _sync = false;
    _heartbeat = false;
    lastSnapshot = null;
    lastHeartbeat = null;
    notifyListeners();
    try {
      running = true;
      await _bridge.start();
      _log('Motor iniciado. Esperando conexión con el servidor.');
    } catch (e) {
      running = false;
      _fail(e);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    if (!running || busy) return;
    busy = true;
    notifyListeners();
    try {
      await _bridge.stop();
    } catch (e) {
      _fail(e);
    } finally {
      running = false;
      _sync = false;
      _heartbeat = false;
      busy = false;
      notifyListeners();
    }
  }

  void _onEvent(Map<String, dynamic> event) {
    if (_disposed) return;
    try {
      _handleEvent(event);
    } on Object {
      _fail(
        StateError(
          'El motor envió un evento incompatible. Revisa la versión del ejecutable.',
        ),
      );
    }
  }

  void _handleEvent(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'command_result':
        final result = event['result'] as Map<String, dynamic>;
        final command = _commands[event['request_id']];
        if (command != null &&
            !command.isCompleted &&
            result['outcome'] != 'pending') {
          command.complete(result);
        }
      case 'log':
        final message = event['message'] as String? ?? '';
        _log(message);
        _showConnectionFailure(message);
      case 'connection':
        final ok = event['connected'] == true;
        if (event['channel'] == 'sync') _sync = ok;
        if (event['channel'] == 'heartbeat') {
          _heartbeat = ok;
          if (ok) lastHeartbeat = DateTime.now();
        }
        if (!ok) {
          final message = event['message'] as String? ?? 'Conexión pendiente.';
          _log(message);
          _showConnectionFailure(message);
        }
      case 'status':
        serverControl = event['server_control'] == true;
        final performance = event['performance'] as Map<String, dynamic>?;
        cpuPercent = (performance?['cpu_percent'] as num?)?.toDouble();
        heapBytes = (performance?['heap_bytes'] as num?)?.toInt();
        uptimeSeconds = (performance?['uptime_seconds'] as num?)?.toInt();
        final nextPlaylists = (event['playlists'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(PlaylistInfo.fromJson)
            .toList();
        if (!listEquals(playlists, nextPlaylists)) playlists = nextPlaylists;
        final report = event['report'] as Map<String, dynamic>;
        final names = <String, Map<String, dynamic>>{};
        for (final value in event['zones'] as List? ?? []) {
          final zone = value as Map<String, dynamic>;
          names[zone['zone_id'] as String] = zone;
        }
        zones = (report['zones'] as List? ?? []).map((value) {
          final zone = value as Map<String, dynamic>;
          return ZoneStatus.fromJson(zone, names[zone['zone_id']] ?? {});
        }).toList();
        revision = report['applied_config_revision'] as int? ?? 0;
        configurationError =
            (report['config_error'] as Map<String, dynamic>?)?['message']
                as String? ??
            '';
        lastSnapshot = DateTime.now();
      case 'exit':
        _cancelPlayback();
        running = false;
        _sync = false;
        _heartbeat = false;
        if (event['code'] != 0 && error.isEmpty) {
          error =
              'El motor terminó con un error. Revisa el registro de actividad.';
        }
        _log('Motor cerrado (código ${event['code']}).');
    }
    notifyListeners();
  }

  void _showConnectionFailure(String message) {
    if (message.contains('invalid_credential') ||
        message.contains('HTTP 401')) {
      error =
          'Laravel rechazó la credencial: el token no está vigente o el equipo está deshabilitado. '
          'Verifica el equipo en Laravel, pega su credencial vigente y pulsa Guardar token y conectar.';
    } else if (message.contains('session_superseded')) {
      error =
          'Otra instancia abrió una sesión para este equipo. Cierra la otra instancia antes de conectar.';
    }
  }

  void _log(String message) {
    if (message.isEmpty ||
        (activity.isNotEmpty && activity.last.message == message)) {
      return;
    }
    activity.add(ActivityEntry(message));
    if (activity.length > 300) activity.removeRange(0, activity.length - 300);
  }

  void _fail(Object value) {
    error = value.toString().replaceFirst('Bad state: ', '');
    _log(error);
    notifyListeners();
  }

  Future<void> close() async {
    await _bridge.stop();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelPlayback();
    _timer.cancel();
    unawaited(_subscription.cancel());
    unawaited(_bridge.dispose().catchError((Object _) {}));
    super.dispose();
  }
}
