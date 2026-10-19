import 'dart:async';
import 'package:flutter/widgets.dart';
import '../design/ui_tokens.dart';

class PreviewTrack {
  const PreviewTrack(this.title, this.artist, this.seconds, this.color);
  final String title, artist;
  final int seconds;
  final Color color;
}

class PreviewZone {
  PreviewZone(
    this.name,
    this.position,
    this.volume,
    this.active,
    this.source,
    this.trackIndex,
    this.channels,
  );
  final String name, source;
  final Offset position;
  double volume;
  bool active;
  String channels;
  int trackIndex;
  double progress = 0, previousVolume = 65;
  bool playing = false, shuffle = false, repeat = false;
  String get song => '${ZonePreviewState.tracks[trackIndex].title} · Demo';
}

class PreviewDevice {
  const PreviewDevice(this.name, this.driver, this.backend, this.latencyMs);
  final String name, driver, backend;
  final double latencyMs;
}

/// In-memory presentation simulation. No engine, system audio, or persistence.
class ZonePreviewState extends ChangeNotifier {
  ZonePreviewState({this.autoAdvance = true});
  final bool autoAdvance;
  Timer? _timer;
  static const tracks = [
    PreviewTrack(
      'Hotel Valhalla',
      'UTRACK · Ambient Sessions',
      378,
      UiColors.accent,
    ),
    PreviewTrack('Brisa', 'UTRACK · Terrace Sessions', 245, UiColors.muted),
    PreviewTrack('Noche', 'UTRACK · Dinner Jazz', 302, UiColors.warning),
  ];
  static const devices = [
    PreviewDevice(
      'Interfaz USB · Studio 2',
      'Studio USB ASIO (Windows)',
      'ASIO',
      12,
    ),
    PreviewDevice(
      'Salida del sistema · Demo',
      'Dispositivo virtual de prueba',
      'Sistema',
      24,
    ),
  ];
  final zones = [
    PreviewZone(
      'Terraza',
      const Offset(.30, .30),
      72,
      true,
      'Ambient',
      1,
      'Estéreo',
    ),
    PreviewZone(
      'Cocina',
      const Offset(.68, .30),
      48,
      false,
      'Lounge',
      0,
      'Mono',
    ),
    PreviewZone(
      'Sala',
      const Offset(.32, .65),
      65,
      true,
      'Hotel Valhalla',
      0,
      'Estéreo',
    )..progress = 84,
    PreviewZone(
      'Comedor',
      const Offset(.67, .64),
      62,
      false,
      'Dinner Jazz',
      2,
      'Estéreo',
    ),
  ];
  int _selected = 2, _deviceIndex = 0;
  bool engineRunning = true;
  int get selectedIndex => _selected;
  int get deviceIndex => _deviceIndex;
  PreviewZone get selected => zones[_selected];
  PreviewTrack get track => tracks[selected.trackIndex];
  PreviewDevice get device => devices[_deviceIndex];
  bool get connected => engineRunning;
  String get status =>
      engineRunning ? 'Motor listo · simulado' : 'Motor detenido · simulado';
  bool isActive(int index) => engineRunning && zones[index].active;
  int get activeZones =>
      engineRunning ? zones.where((zone) => zone.active).length : 0;
  double get cpu =>
      engineRunning ? 4 + zones.where((zone) => zone.playing).length * 2.0 : 0;
  double get latencyMs => engineRunning ? device.latencyMs : 0;

  void select(int index) {
    if (index < 0 || index >= zones.length || index == _selected) return;
    _selected = index;
    notifyListeners();
  }

  void setVolume(int index, double value) {
    zones[index].volume = value.clamp(0, 100).toDouble();
    _selected = index;
    notifyListeners();
  }

  void toggle(int index) {
    if (!engineRunning) return;
    final zone = zones[index];
    zone.active = !zone.active;
    if (!zone.active) zone.playing = false;
    _selected = index;
    _syncTimer();
    notifyListeners();
  }

  void setChannels(String value) {
    if (!['Mono', 'Estéreo'].contains(value)) return;
    selected.channels = value;
    notifyListeners();
  }

  void togglePlayback() {
    if (!engineRunning) return;
    selected.playing = !selected.playing;
    if (selected.playing) {
      selected.active = true;
      if (selected.progress >= track.seconds) selected.progress = 0;
    }
    _syncTimer();
    notifyListeners();
  }

  void seek(double seconds) {
    selected.progress = seconds.clamp(0, track.seconds).toDouble();
    notifyListeners();
  }

  void skip(int direction) {
    final step = selected.shuffle ? direction * 2 : direction;
    selected.trackIndex = (selected.trackIndex + step) % tracks.length;
    selected.progress = 0;
    notifyListeners();
  }

  void toggleShuffle() {
    selected.shuffle = !selected.shuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    selected.repeat = !selected.repeat;
    notifyListeners();
  }

  void toggleMute() {
    if (selected.volume > 0) {
      selected.previousVolume = selected.volume;
      selected.volume = 0;
    } else {
      selected.volume = selected.previousVolume;
    }
    notifyListeners();
  }

  void selectDevice(int index) {
    if (index < 0 || index >= devices.length || index == _deviceIndex) return;
    _deviceIndex = index;
    for (final zone in zones) {
      zone.playing = false;
    }
    _syncTimer();
    notifyListeners();
  }

  void toggleEngine() {
    engineRunning = !engineRunning;
    if (!engineRunning) {
      for (final zone in zones) {
        zone.playing = false;
      }
    }
    _syncTimer();
    notifyListeners();
  }

  /// Advances every playing zone, including zones not currently selected.
  void advance(double seconds) {
    if (!engineRunning || !seconds.isFinite || seconds <= 0) return;
    for (final zone in zones) {
      if (!zone.playing || !zone.active) continue;
      zone.progress += seconds;
      while (zone.progress >= tracks[zone.trackIndex].seconds) {
        zone.progress -= tracks[zone.trackIndex].seconds;
        if (!zone.repeat) {
          zone.trackIndex =
              (zone.trackIndex + (zone.shuffle ? 2 : 1)) % tracks.length;
        }
      }
    }
    notifyListeners();
  }

  void _syncTimer() {
    if (!engineRunning || !zones.any((zone) => zone.playing)) {
      _timer?.cancel();
      _timer = null;
    } else if (autoAdvance) {
      _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => advance(1));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
