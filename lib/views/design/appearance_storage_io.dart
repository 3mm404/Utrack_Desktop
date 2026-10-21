import 'appearance_store.dart';
import 'dart:convert';
import 'dart:io';

/// Per-user preferences, independent of the installation and audio engine.
class AppearanceStorage implements AppearanceStore {
  AppearanceStorage({Directory? directory})
    : directory = directory ?? _userDirectory();
  final Directory directory;
  static Directory _userDirectory() {
    final env = Platform.environment;
    final base = Platform.isWindows
        ? (env['APPDATA'] ?? env['USERPROFILE'])
        : Platform.isMacOS
        ? '${env['HOME']}/Library/Application Support'
        : (env['XDG_CONFIG_HOME'] ?? '${env['HOME']}/.config');
    if (base == null || base.isEmpty) {
      throw StateError(
        'No se encuentra la carpeta de preferencias del usuario.',
      );
    }
    return Directory('$base${Platform.pathSeparator}Utrack');
  }

  File get file =>
      File('${directory.path}${Platform.pathSeparator}appearance.json');
  @override
  Future<String?> read() async {
    try {
      final data = jsonDecode(await file.readAsString());
      if (data is! Map<String, dynamic>) return null;
      final theme = data['theme'];
      return theme == 'light' || theme == 'dark' ? theme as String : null;
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(String theme) async {
    await directory.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode({'theme': theme}), flush: true);
    await temporary.rename(file.path);
  }
}
