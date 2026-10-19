import 'package:flutter/foundation.dart';

/// Proposed presentation boundary. No transport or adapter is implemented here.
abstract interface class AudioUiPort {
  ValueListenable<AudioUiSnapshot> get snapshot;
  Future<UiCommandResult> dispatch(AudioUiCommand command);

  /// Owned by the composition root, never by an individual widget.
  Future<void> dispose();
}

enum UiDataOrigin { simulated, engine }

enum UiConnection { disconnected, connecting, connected, stale, failed }

enum UiEnginePhase { stopped, starting, running, stopping, failed }

enum UiPlaybackPhase { idle, buffering, playing, paused, failed }

enum UiChannelMode { mono, stereo }

enum UiRepeatMode { off, track }

enum UiAction {
  startEngine,
  stopEngine,
  setVolume,
  setEnabled,
  setPlayback,
  selectTrack,
  seek,
  setChannels,
  selectOutput,
  setPlaybackMode,
}

@immutable
class AudioUiSnapshot {
  AudioUiSnapshot({
    required this.origin,
    required this.connection,
    required this.engine,
    required this.revision,
    required this.observedAt,
    required Iterable<UiZoneSnapshot> zones,
    required Iterable<UiOutputSnapshot> outputs,
    required Iterable<UiAction> capabilities,
    this.outputId,
    this.cpuPercent,
    this.latencyMs,
    this.message,
    Iterable<String> pendingRequestIds = const [],
  }) : zones = List.unmodifiable(zones),
       outputs = List.unmodifiable(outputs),
       capabilities = Set.unmodifiable(capabilities),
       pendingRequestIds = Set.unmodifiable(pendingRequestIds);

  /// Snapshot revision; not the engine protocol or app version.
  final int revision;
  final DateTime observedAt;
  final UiDataOrigin origin;
  final UiConnection connection;
  final UiEnginePhase engine;
  final List<UiZoneSnapshot> zones;
  final List<UiOutputSnapshot> outputs;

  /// The UI must disable unsupported actions. Empty means read-only.
  final Set<UiAction> capabilities;
  final Set<String> pendingRequestIds;
  final String? outputId, message;

  /// Null means unknown, never a measured zero.
  final double? cpuPercent, latencyMs;
}

@immutable
class UiZoneSnapshot {
  const UiZoneSnapshot({
    required this.id,
    required this.name,
    required this.volume,
    required this.enabled,
    required this.playback,
    required this.channels,
    this.track,
    this.sourceName,
    this.position = Duration.zero,
    this.shuffle = false,
    this.repeat = UiRepeatMode.off,
  });
  final String id, name;
  final double volume;
  final bool enabled, shuffle;
  final UiPlaybackPhase playback;
  final UiChannelMode channels;
  final UiRepeatMode repeat;
  final UiTrackSnapshot? track;
  final String? sourceName;
  final Duration position;
}

@immutable
class UiTrackSnapshot {
  const UiTrackSnapshot({
    required this.id,
    required this.title,
    this.artist,
    this.duration,
    this.artwork,
  });
  final String id, title;
  final String? artist;
  final Duration? duration;
  final Uri? artwork;
}

@immutable
class UiOutputSnapshot {
  const UiOutputSnapshot({
    required this.id,
    required this.name,
    required this.available,
    this.driver,
    this.sampleRate,
    this.bufferFrames,
  });
  final String id, name;
  final bool available;
  final String? driver;
  final int? sampleRate, bufferFrames;
}

/// Explicit desired values avoid ambiguous retryable toggle commands.
@immutable
sealed class AudioUiCommand {
  const AudioUiCommand({required this.requestId, this.expectedRevision});
  final String requestId;
  final int? expectedRevision;
  UiAction get action;
}

final class UiSetEngine extends AudioUiCommand {
  const UiSetEngine({
    required super.requestId,
    super.expectedRevision,
    required this.running,
  });
  final bool running;
  @override
  UiAction get action => running ? UiAction.startEngine : UiAction.stopEngine;
}

final class UiSetVolume extends AudioUiCommand {
  const UiSetVolume({
    required super.requestId,
    super.expectedRevision,
    required this.zoneId,
    required this.volume,
  });
  final String zoneId;

  /// Normalized UI scale: 0–100. The future adapter validates finite values.
  final double volume;
  @override
  UiAction get action => UiAction.setVolume;
}

final class UiSetEnabled extends AudioUiCommand {
  const UiSetEnabled({
    required super.requestId,
    super.expectedRevision,
    required this.zoneId,
    required this.enabled,
  });
  final String zoneId;
  final bool enabled;
  @override
  UiAction get action => UiAction.setEnabled;
}

final class UiSetPlayback extends AudioUiCommand {
  const UiSetPlayback({
    required super.requestId,
    super.expectedRevision,
    required this.zoneId,
    required this.playing,
  });
  final String zoneId;
  final bool playing;
  @override
  UiAction get action => UiAction.setPlayback;
}

final class UiSelectTrack extends AudioUiCommand {
  const UiSelectTrack({
    required super.requestId,
    super.expectedRevision,
    required this.zoneId,
    required this.trackId,
  });
  final String zoneId, trackId;
  @override
  UiAction get action => UiAction.selectTrack;
}

final class UiSeek extends AudioUiCommand {
  const UiSeek({
    required super.requestId,
    super.expectedRevision,
    required this.zoneId,
    required this.position,
  });
  final String zoneId;
  final Duration position;
  @override
  UiAction get action => UiAction.seek;
}

final class UiSetChannels extends AudioUiCommand {
  const UiSetChannels({
    required super.requestId,
    super.expectedRevision,
    required this.zoneId,
    required this.channels,
  });
  final String zoneId;
  final UiChannelMode channels;
  @override
  UiAction get action => UiAction.setChannels;
}

final class UiSelectOutput extends AudioUiCommand {
  const UiSelectOutput({
    required super.requestId,
    super.expectedRevision,
    required this.outputId,
  });
  final String outputId;
  @override
  UiAction get action => UiAction.selectOutput;
}

final class UiSetPlaybackMode extends AudioUiCommand {
  const UiSetPlaybackMode({
    required super.requestId,
    super.expectedRevision,
    required this.zoneId,
    required this.shuffle,
    required this.repeat,
  });
  final String zoneId;
  final bool shuffle;
  final UiRepeatMode repeat;
  @override
  UiAction get action => UiAction.setPlaybackMode;
}

enum UiCommandError {
  unsupported,
  invalidInput,
  unavailable,
  busy,
  staleRevision,
  timeout,
  failed,
}

@immutable
class UiCommandResult {
  const UiCommandResult.accepted(this.requestId) : error = null, message = null;
  const UiCommandResult.rejected(
    this.requestId,
    UiCommandError reason,
    this.message,
  ) : error = reason;
  final String requestId;
  final UiCommandError? error;
  final String? message;

  /// Acceptance is not confirmation that the engine applied the command.
  bool get accepted => error == null;
}
