import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/engine_settings.dart';
import 'engine_bridge.dart';

class ProcessEngineBridge implements EngineBridge {
  ProcessEngineBridge({String? executable, this.environment})
    : executable =
          executable ??
          '${File(Platform.resolvedExecutable).parent.path}${Platform.pathSeparator}engine.exe';

  final String executable;
  final Map<String, String>? environment;
  final _events = StreamController<Map<String, dynamic>>.broadcast();
  Process? _process;
  Future<void>? _completion;

  @override
  Stream<Map<String, dynamic>> get events => _events.stream;

  Future<Process> _spawn(List<String> arguments) async {
    if (!await File(executable).exists()) {
      throw StateError(
        'No se encontró engine.exe junto a la aplicación. Extrae el paquete completo.',
      );
    }
    return Process.start(
      executable,
      arguments,
      runInShell: false,
      environment: environment,
    );
  }

  Future<Map<String, dynamic>> _request(
    String command, [
    Map<String, dynamic>? input,
  ]) async {
    final child = await _spawn([command]);
    final output = child.stdout.transform(utf8.decoder).join();
    final errors = child.stderr.transform(utf8.decoder).join();
    try {
      if (input != null) child.stdin.write(jsonEncode(input));
      await child.stdin.close();
      final exit = await child.exitCode.timeout(const Duration(seconds: 15));
      final text = await output;
      final error = await errors;
      if (exit != 0) {
        throw StateError(
          error.trim().isEmpty
              ? 'El motor devolvió un error ($exit).'
              : error.trim(),
        );
      }
      return jsonDecode(text) as Map<String, dynamic>;
    } on TimeoutException {
      child.kill();
      await child.exitCode;
      await Future.wait([output, errors]);
      throw StateError('El motor no respondió a tiempo.');
    }
  }

  @override
  Future<Map<String, dynamic>> inspect() => _request('desktop-info');

  @override
  Future<void> configure(EngineSettings settings, String token) async {
    await _request('desktop-configure', {
      'settings': settings.toJson(),
      'token': token,
    });
  }

  @override
  Future<void> start() async {
    if (_process != null) throw StateError('El motor ya está iniciado.');
    final child = await _spawn(['run', '--desktop']);
    _process = child;
    _completion = _observe(child);
  }

  Future<void> _observe(Process child) async {
    final stdoutDone = child.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
          try {
            _emit(jsonDecode(line) as Map<String, dynamic>);
          } on FormatException {
            _emit({
              'type': 'log',
              'message': 'Respuesta del motor no reconocida.',
            });
          }
        });
    final stderrDone = child.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
          _emit({'type': 'log', 'message': line});
        });
    final exit = await child.exitCode;
    await Future.wait([stdoutDone, stderrDone]);
    if (identical(_process, child)) _process = null;
    _emit({'type': 'exit', 'code': exit});
  }

  void _emit(Map<String, dynamic> event) {
    if (!_events.isClosed) _events.add(event);
  }

  @override
  Future<void> stop() async {
    final child = _process;
    if (child == null) return;
    try {
      child.stdin.writeln('stop');
      await child.stdin.flush();
      await child.stdin.close();
    } on Exception {
      // A process that already exited may have closed its input pipe.
    }
    try {
      await _completion?.timeout(const Duration(seconds: 15));
    } on TimeoutException {
      child.kill();
      await _completion;
      throw StateError(
        'El motor no respondió a la parada y fue cerrado. Revisa el registro.',
      );
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _events.close();
  }
}
