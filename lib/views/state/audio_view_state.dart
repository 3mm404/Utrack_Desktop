import 'package:flutter/widgets.dart';

class TrackViewData {
  const TrackViewData(this.title, this.artist, this.seconds, this.color);
  final String title, artist;
  final int seconds;
  final Color color;
}

class ZoneViewData {
  ZoneViewData(
    this.name,
    this.position,
    this.volume,
    this.active,
    this.source,
    this.trackIndex,
    this.channels, {
    this.id = '',
  });
  final String id, name, source;
  final Offset position;
  double volume;
  bool active;
  String channels;
  int trackIndex;
  double progress = 0, previousVolume = 65;
  bool playing = false, shuffle = false, repeat = false;
  TrackViewData? track;
  List<String> songs = const [];
  int? positionMs;
  String? observedState, failure;
  String get song => track?.title ?? 'Sin canción reportada';
}

class OutputViewData {
  const OutputViewData(
    this.name,
    this.driver,
    this.backend,
    this.latencyMs, {
    this.sampleRate,
    this.bufferFrames,
    this.mode,
  });
  final String name, driver, backend;
  final double? latencyMs;
  final int? sampleRate, bufferFrames;
  final String? mode;
}

/// Shared presentation boundary. Real state never inherits the preview's data.
abstract class AudioViewState extends ChangeNotifier {
  List<ZoneViewData> get zones;
  List<OutputViewData> get outputs;
  int get selectedIndex;
  ZoneViewData get selected;
  TrackViewData get track;
  int get deviceIndex;
  OutputViewData get device;
  bool get isSimulated;
  bool get engineRunning;
  bool get connected;
  bool get fresh;
  String get status;
  String get error => '';
  String get server => '';
  String get version => '';
  bool get needsConfiguration => false;
  bool get busy => false;
  VoidCallback? get refreshAction => null;
  bool get canControlZones => isSimulated;
  bool get canSetVolume => canControlZones;
  bool get volumePending => false;
  bool canPlayback(String action) => canControlZones;
  bool get playbackPending => false;
  void playSong(String songId) => _unsupported();
  bool get canToggleEngine => true;
  bool get hasSelection => zones.isNotEmpty;
  double? get cpu;
  double? get latencyMs;
  int get activeZones;
  bool isActive(int index);
  void select(int index);
  void toggleEngine();
  Never _unsupported() => throw UnsupportedError(
    'Esta operación se administra desde el servidor; el puente desktop no la admite.',
  );
  void setVolume(int index, double value) => _unsupported();
  void toggle(int index) => _unsupported();
  void setChannels(String value) => _unsupported();
  void togglePlayback() => _unsupported();
  void stopPlayback() => _unsupported();
  void seek(double seconds) => _unsupported();
  void skip(int direction) => _unsupported();
  void toggleShuffle() => _unsupported();
  void toggleRepeat() => _unsupported();
  void toggleMute() => _unsupported();
  void selectDevice(int index) => _unsupported();
}
