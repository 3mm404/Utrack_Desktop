/// Public operations of the existing local engine pipe. These are NOT HTTP URLs.
/// Add an operation here only after its Go handler and capability exist.
enum EngineOperation {
  play('play', 'Reproducir', acceptsSong: true),
  pause('pause', 'Pausar'),
  resume('resume', 'Reanudar'),
  stop('stop', 'Detener zona'),
  next('next', 'Siguiente canción'),
  previous('previous', 'Canción anterior'),
  volume('volume', 'Volumen por zona', requiresVolume: true);

  const EngineOperation(
    this.wireName,
    this.label, {
    this.acceptsSong = false,
    this.requiresVolume = false,
  });
  final String wireName;
  final String label;
  final bool acceptsSong;
  final bool requiresVolume;

  static EngineOperation? fromWire(String value) {
    for (final operation in values) {
      if (operation.wireName == value) return operation;
    }
    return null;
  }
}

/// Read capabilities are kept separate from commands, so they cannot be sent.
abstract final class EngineReadCapabilities {
  static const assignedPlaylist = 'playlist_read';
  static const labels = {assignedPlaylist: 'Playlist asignada'};
}
