import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../controllers/engine_controller.dart';
import '../../models/engine_status.dart';
import '../design/ui_tokens.dart';
import 'audio_view_state.dart';

/// Maps only values reported by the existing desktop protocol; never simulates.
class EngineViewState extends AudioViewState {
  EngineViewState(this.controller) {
    controller.addListener(_update);
    _update();
  }
  final EngineController controller;
  List<ZoneViewData> _zones = [];
  String? _selectedId;
  final Map<String, ({int volume, int revision})> _volumeDrafts = {};
  ({String id, int volume, int revision})? _volumeSending;
  Timer? _volumeTimer;
  bool _disposed = false;
  static const _positions = [
    Offset(.30, .30),
    Offset(.68, .30),
    Offset(.32, .65),
    Offset(.67, .64),
  ];
  final _empty = ZoneViewData(
    'Sin zona seleccionada',
    Offset.zero,
    0,
    false,
    'Sin playlist reportada',
    0,
    'No reportado',
  );
  void _update() {
    _volumeDrafts.removeWhere(
      (id, draft) =>
          draft.revision != controller.revision ||
          !controller.running ||
          !controller.zones.any((zone) => zone.id == id),
    );
    _zones = [for (var i = 0; i < controller.zones.length; i++) _mapZone(i)];
    if (!_zones.any((zone) => zone.id == _selectedId)) {
      _selectedId = _zones.isEmpty ? null : _zones.first.id;
    }
    notifyListeners();
  }

  ZoneViewData _mapZone(int index) {
    final zone = controller.zones[index];
    final position = controller.zones.length <= 4
        ? _positions[index]
        : Offset(
            .18 + (index % 3) * .29,
            .16 + (index ~/ 3) / ((controller.zones.length + 2) ~/ 3) * .68,
          );
    return ZoneViewData(
        zone.name,
        position,
        (_volumeDrafts[zone.id]?.volume ??
                (_volumeSending?.id == zone.id &&
                        _volumeSending?.revision == controller.revision
                    ? _volumeSending?.volume
                    : null) ??
                zone.volume)
            .toDouble(),
        zone.state == 'playing',
        zone.playlist.isEmpty ? 'Sin playlist asignada' : zone.playlist,
        0,
        zone.mode == 'mono'
            ? 'Mono'
            : zone.mode == 'stereo'
            ? 'Estéreo'
            : 'No reportado',
        id: zone.id,
      )
      ..playing =
          controller.running && controller.fresh && zone.state == 'playing'
      ..positionMs = zone.positionMs
      ..durationMs = zone.durationMs
      ..progress = (zone.positionMs ?? 0) / 1000
      ..observedState = zone.label
      ..failure = zone.error
      ..songs = zone.songs
      ..coverPath = zone.coverPath
      ..backgroundPath = zone.backgroundPath
      ..playlistId = zone.playlistId
      ..songPreferences = zone.songPreferences
      ..songId = zone.songId
      ..shuffle = zone.shuffle
      ..repeat = zone.repeatMode == 'track' || zone.repeatMode == 'playlist'
      ..repeatMode = zone.repeatMode
      ..continuousPlayback = zone.continuousPlayback
      ..songMetadata = {
        for (final entry in zone.songMetadata.entries)
          entry.key: TrackViewData(
            entry.value.title.isEmpty
                ? 'Canción ${entry.key}'
                : entry.value.title,
            entry.value.artist ?? 'Artista no reportado',
            0,
            UiColors.muted,
            coverPath: entry.value.coverPath ?? zone.coverPath,
          ),
      }
      ..track = zone.songId == null
          ? null
          : TrackViewData(
              zone.songMetadata[zone.songId]?.title.isNotEmpty == true
                  ? zone.songMetadata[zone.songId]!.title
                  : 'Canción ${zone.songId}',
              zone.songMetadata[zone.songId]?.artist ?? 'Artista no reportado',
              zone.durationMs == null || zone.durationMs! <= 0
                  ? 0
                  : (zone.durationMs! / 1000).ceil(),
              UiColors.muted,
              coverPath:
                  zone.songMetadata[zone.songId]?.coverPath ?? zone.coverPath,
            );
  }

  @override
  List<ZoneViewData> get zones => List.unmodifiable(_zones);
  @override
  int get selectedIndex => _zones.indexWhere((zone) => zone.id == _selectedId);
  @override
  ZoneViewData get selected =>
      selectedIndex < 0 ? _empty : _zones[selectedIndex];
  @override
  TrackViewData get track =>
      selected.track ??
      const TrackViewData('Sin canción reportada', '', 0, UiColors.muted);
  @override
  bool get isSimulated => false;
  @override
  bool get engineRunning => controller.running || controller.externalRunning;
  @override
  bool get connected => controller.connected;
  @override
  bool get fresh => controller.running && controller.fresh;
  @override
  bool get busy => controller.busy;
  @override
  bool get playbackPending => controller.playbackPending;
  @override
  bool get volumePending => _volumeDrafts.isNotEmpty || _volumeSending != null;
  @override
  bool get canSetVolume =>
      hasSelection &&
      fresh &&
      !controller.busy &&
      controller.configurationError.isEmpty &&
      controller.supportsPlayback('volume');
  @override
  void setVolume(int index, double value) {
    if (!canSetVolume ||
        index < 0 ||
        index >= _zones.length ||
        !value.isFinite) {
      return;
    }
    final id = _zones[index].id;
    _volumeDrafts[id] = (
      volume: value.clamp(0, 100).round(),
      revision: controller.revision,
    );
    _update();
    _scheduleVolume();
  }

  void _scheduleVolume() {
    _volumeTimer?.cancel();
    _volumeTimer = Timer(
      const Duration(milliseconds: 200),
      () => unawaited(_sendVolume()),
    );
  }

  Future<void> _sendVolume() async {
    if (_disposed || _volumeDrafts.isEmpty) return;
    if (!canSetVolume) {
      _volumeDrafts.clear();
      _update();
      return;
    }
    if (_volumeSending != null || controller.playbackPending) {
      _scheduleVolume();
      return;
    }
    final entry = _volumeDrafts.entries.first;
    _volumeDrafts.remove(entry.key);
    if (entry.value.revision != controller.revision) {
      _update();
      return;
    }
    _volumeSending = (
      id: entry.key,
      volume: entry.value.volume,
      revision: entry.value.revision,
    );
    _update();
    await controller.playback(entry.key, 'volume', volume: entry.value.volume);
    if (_disposed) return;
    _volumeSending = null;
    _update();
    if (_volumeDrafts.isNotEmpty) _scheduleVolume();
  }

  @override
  bool canPlayback(String action) =>
      hasSelection &&
      fresh &&
      (!playbackPending || (action == 'stop' && !controller.stopPending)) &&
      controller.configurationError.isEmpty &&
      controller.supportsPlayback(action);
  @override
  bool get canSeek =>
      canPlayback('seek') &&
      track.seconds > 0 &&
      (selected.observedState == 'Reproduciendo' ||
          selected.observedState == 'En pausa');
  @override
  bool get canSetPlaybackModes => canPlayback('playback_modes');
  @override
  void seek(double seconds) {
    if (!canSeek || !seconds.isFinite) return;
    unawaited(
      controller.playback(
        selected.id,
        'seek',
        positionMs: (seconds * 1000).round().clamp(
          0,
          selected.durationMs ?? track.seconds * 1000,
        ),
      ),
    );
  }

  @override
  void toggleShuffle() {
    if (canSetPlaybackModes) {
      unawaited(
        controller.playback(
          selected.id,
          'playback_modes',
          shuffle: !selected.shuffle,
        ),
      );
    }
  }

  @override
  void toggleRepeat() {
    if (!canSetPlaybackModes) return;
    final next = switch (selected.repeatMode) {
      'off' => 'track',
      'track' => 'playlist',
      _ => 'off',
    };
    unawaited(
      controller.playback(selected.id, 'playback_modes', repeatMode: next),
    );
  }

  @override
  void toggleAutoAdvance() {
    if (canSetPlaybackModes) {
      unawaited(
        controller.playback(
          selected.id,
          'playback_modes',
          continuousPlayback: !selected.continuousPlayback,
        ),
      );
    }
  }

  void _playback(String action, {String? songId}) {
    if (!canPlayback(action)) return;
    unawaited(controller.playback(selected.id, action, songId: songId));
  }

  @override
  void togglePlayback() => _playback(
    selected.playing
        ? 'pause'
        : selected.observedState == 'En pausa'
        ? 'resume'
        : 'play',
  );
  @override
  void skip(int direction) => _playback(direction < 0 ? 'previous' : 'next');
  @override
  void stopPlayback() => _playback('stop');
  @override
  void playSong(String songId) => _playback('play', songId: songId);
  @override
  void playAssignedPlaylist() => _playback('play');
  @override
  List<PlaylistInfo> get playlists => controller.playlists;
  @override
  bool get canPlayPlaylist => canPlayback('play_playlist');
  @override
  bool get canSetSongPreference =>
      controller.serverControl && canPlayback('song_preference');
  @override
  void setSongPreference(String zoneId, String songId, String preference) {
    if (!canSetSongPreference || !zones.any((zone) => zone.id == zoneId)) {
      return;
    }
    unawaited(
      controller.playback(
        zoneId,
        'song_preference',
        songId: songId,
        preference: preference,
      ),
    );
  }

  @override
  void playPlaylist(String playlistId, {String? songId}) {
    if (!canPlayPlaylist ||
        !playlists.any(
          (playlist) =>
              playlist.id == playlistId &&
              playlist.songs.isNotEmpty &&
              (songId == null || playlist.songs.containsKey(songId)),
        )) {
      return;
    }
    unawaited(
      controller.playback(
        selected.id,
        'play_playlist',
        playlistId: playlistId,
        songId: songId,
      ),
    );
  }

  @override
  VoidCallback? get refreshAction =>
      !controller.running && !controller.busy ? controller.refresh : null;
  @override
  bool get needsConfiguration => !controller.configured;
  @override
  String get status => controller.statusLabel;
  @override
  String get error => controller.error.isNotEmpty
      ? controller.error
      : controller.configurationError;
  @override
  String get server => controller.settings.server;
  @override
  String get version => controller.version;
  @override
  bool get canToggleEngine =>
      controller.canStart || (controller.running && !controller.busy);
  @override
  double? get cpu => fresh ? controller.cpuPercent : null;
  @override
  int? get heapBytes => fresh ? controller.heapBytes : null;
  @override
  int? get uptimeSeconds => fresh ? controller.uptimeSeconds : null;
  @override
  int get configurationRevision => controller.revision;
  @override
  DateTime? get lastHeartbeat => controller.lastHeartbeat;
  @override
  DateTime? get lastSnapshot => controller.lastSnapshot;
  @override
  bool get serverSynced => fresh && controller.serverSynced;
  @override
  bool get heartbeatHealthy => fresh && controller.heartbeatHealthy;
  @override
  double? get latencyMs => null;
  @override
  int get activeZones =>
      fresh ? _zones.where((zone) => zone.playing).length : 0;
  @override
  bool isActive(int index) =>
      fresh && index >= 0 && index < _zones.length && _zones[index].playing;
  @override
  List<OutputViewData> get outputs => controller.configured
      ? [
          OutputViewData(
            controller.settings.backend == 'asio'
                ? controller.settings.driver
                : 'Salida del sistema',
            controller.settings.backend == 'asio'
                ? controller.settings.driver
                : 'Audio del sistema (Oto)',
            controller.settings.backend == 'asio' ? 'ASIO' : 'Oto',
            null,
            sampleRate: controller.settings.backend == 'asio'
                ? controller.settings.sampleRate
                : null,
            bufferFrames: controller.settings.backend == 'asio'
                ? controller.settings.bufferSize
                : null,
            mode: controller.settings.mode,
          ),
        ]
      : [];
  @override
  int get deviceIndex => outputs.isEmpty ? -1 : 0;
  @override
  OutputViewData get device => outputs.isEmpty
      ? const OutputViewData(
          'Sin salida configurada',
          'No reportado',
          'No configurado',
          null,
        )
      : outputs.first;
  @override
  void select(int index) {
    if (index < 0 || index >= _zones.length) return;
    _selectedId = _zones[index].id;
    notifyListeners();
  }

  @override
  void toggleEngine() {
    if (!canToggleEngine) return;
    unawaited(controller.running ? controller.stop() : controller.start());
  }

  @override
  void dispose() {
    _disposed = true;
    _volumeTimer?.cancel();
    controller.removeListener(_update);
    super.dispose();
  }
}
