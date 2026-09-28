import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/engine_settings.dart';
import '../models/engine_status.dart';
import '../services/engine_bridge.dart';

class EngineController extends ChangeNotifier {
  EngineController(this._bridge) {
    _subscription = _bridge.events.listen(
      _onEvent,
      onError: (Object error) => _fail(error),
    );
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (running) notifyListeners();
    });
  }

  final EngineBridge _bridge;
  late final StreamSubscription<Map<String, dynamic>> _subscription;
  late final Timer _timer;
  EngineSettings settings = const EngineSettings();
  List<String> drivers = [];
  List<ZoneStatus> zones = [];
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

  Future<void> initialize() => refresh();

  Future<void> _inspect() async {
    final info = await _bridge.inspect();
    if (info['protocol'] != 1) {
      throw StateError('El ejecutable no es compatible con esta interfaz.');
    }
    version = info['version'] as String? ?? '—';
    dataDirectory = info['data_directory'] as String? ?? '';
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
    if (!canConfigure) return false;
    final validation = value.validate();
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
      _log(
        'Configuración guardada. La credencial permanece cifrada en Windows.',
      );
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
    switch (event['type']) {
      case 'log':
        _log(event['message'] as String? ?? '');
      case 'connection':
        final ok = event['connected'] == true;
        if (event['channel'] == 'sync') _sync = ok;
        if (event['channel'] == 'heartbeat') {
          _heartbeat = ok;
          if (ok) lastHeartbeat = DateTime.now();
        }
        if (!ok) _log(event['message'] as String? ?? 'Conexión pendiente.');
      case 'status':
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
        running = false;
        _sync = false;
        _heartbeat = false;
        if (event['code'] != 0) {
          error =
              'El motor terminó con un error. Revisa el registro de actividad.';
        }
        _log('Motor cerrado (código ${event['code']}).');
    }
    notifyListeners();
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
  void dispose() {
    _timer.cancel();
    unawaited(_subscription.cancel());
    unawaited(_bridge.dispose());
    super.dispose();
  }
}
