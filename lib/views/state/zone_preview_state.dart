import 'dart:async';
import 'package:flutter/widgets.dart';
import '../design/ui_tokens.dart';
import 'audio_view_state.dart';
export 'audio_view_state.dart';

/// In-memory presentation simulation. No engine, system audio, or persistence.
class ZonePreviewState extends AudioViewState {
  ZonePreviewState({this.autoAdvance = true});
  final bool autoAdvance;
  @override
  bool get isSimulated => true;
  @override
  bool get fresh => true;
  @override
  List<OutputViewData> get outputs => devices;
  Timer? _timer;
  static const tracks = [
    TrackViewData(
      'Hotel Valhalla',
      'UTRACK · Ambient Sessions',
      378,
      UiColors.accent,
    ),
    TrackViewData('Brisa', 'UTRACK · Terrace Sessions', 245, UiColors.muted),
    TrackViewData('Noche', 'UTRACK · Dinner Jazz', 302, UiColors.warning),
  ];
  static const devices = [
    OutputViewData(
      'Interfaz USB · Studio 2',
      'Studio USB ASIO (Windows)',
      'ASIO',
      12,
    ),
    OutputViewData(
      'Salida del sistema · Demo',
      'Dispositivo virtual de prueba',
      'Sistema',
      24,
    ),
  ];
  @override
  final zones = [
    ZoneViewData(
      'Terraza',
      const Offset(.30, .30),
      72,
      true,
      'Ambient',
      1,
      'Estéreo',
    ),
    ZoneViewData(
      'Cocina',
      const Offset(.68, .30),
      48,
      false,
      'Lounge',
      0,
      'Mono',
    ),
    ZoneViewData(
      'Sala',
      const Offset(.32, .65),
      65,
      true,
      'Hotel Valhalla',
      0,
      'Estéreo',
    )..progress = 84,
    ZoneViewData(
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
  @override
  bool engineRunning = true;
  @override
  int get selectedIndex => _selected;
  @override
  int get deviceIndex => _deviceIndex;
  @override
  ZoneViewData get selected {
    final zone = zones[_selected];
    zone.track = tracks[zone.trackIndex];
    return zone;
  }

  @override
  TrackViewData get track => tracks[selected.trackIndex];
  @override
  OutputViewData get device => devices[_deviceIndex];
  @override
  bool get connected => engineRunning;
  @override
  String get status =>
      engineRunning ? 'Motor listo · simulado' : 'Motor detenido · simulado';
  @override
  bool isActive(int index) => engineRunning && zones[index].active;
  @override
  int get activeZones =>
      engineRunning ? zones.where((zone) => zone.active).length : 0;
  @override
  double get cpu =>
      engineRunning ? 4 + zones.where((zone) => zone.playing).length * 2.0 : 0;
  @override
  double get latencyMs => engineRunning ? device.latencyMs! : 0;

  @override
  void select(int index) {
    if (index < 0 || index >= zones.length || index == _selected) return;
    _selected = index;
    notifyListeners();
  }

  @override
  void setVolume(int index, double value) {
    zones[index].volume = value.clamp(0, 100).toDouble();
    _selected = index;
    notifyListeners();
  }

  @override
  void toggle(int index) {
    if (!engineRunning) return;
    final zone = zones[index];
    zone.active = !zone.active;
    if (!zone.active) zone.playing = false;
    _selected = index;
    _syncTimer();
    notifyListeners();
  }

  @override
  void setChannels(String value) {
    if (!['Mono', 'Estéreo'].contains(value)) return;
    selected.channels = value;
    notifyListeners();
  }

  @override
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

  @override
  void seek(double seconds) {
    selected.progress = seconds.clamp(0, track.seconds).toDouble();
    notifyListeners();
  }

  @override
  void skip(int direction) {
    final step = selected.shuffle ? direction * 2 : direction;
    selected.trackIndex = (selected.trackIndex + step) % tracks.length;
    selected.progress = 0;
    notifyListeners();
  }

  @override
  void toggleShuffle() {
    selected.shuffle = !selected.shuffle;
    notifyListeners();
  }

  @override
  void toggleRepeat() {
    selected.repeat = !selected.repeat;
    notifyListeners();
  }

  @override
  void toggleMute() {
    if (selected.volume > 0) {
      selected.previousVolume = selected.volume;
      selected.volume = 0;
    } else {
      selected.volume = selected.previousVolume;
    }
    notifyListeners();
  }

  @override
  void selectDevice(int index) {
    if (index < 0 || index >= devices.length || index == _deviceIndex) return;
    _deviceIndex = index;
    for (final zone in zones) {
      zone.playing = false;
    }
    _syncTimer();
    notifyListeners();
  }

  @override
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
