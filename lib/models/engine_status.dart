import 'schedule_info.dart';

class ZoneStatus {
  const ZoneStatus({
    required this.id,
    required this.name,
    required this.state,
    required this.volume,
    required this.playlist,
    required this.mode,
    required this.channels,
    this.songId,
    this.positionMs,
    this.durationMs,
    this.error,
    this.songs = const [],
    this.songMetadata = const {},
    this.shuffle = false,
    this.repeatMode = '',
    this.continuousPlayback = false,
    this.schedule,
  });

  final String id, name, state, playlist, mode;
  final int volume;
  final int? positionMs;
  final int? durationMs;
  final List<int> channels;
  final String? songId, error;
  final List<String> songs;
  final Map<String, SongMetadata> songMetadata;
  final bool shuffle, continuousPlayback;
  final String repeatMode;
  final ScheduleInfo? schedule;

  factory ZoneStatus.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> info,
  ) {
    final output = json['output'] as Map<String, dynamic>?;
    return ZoneStatus(
      id: json['zone_id'] as String,
      name: info['name'] as String? ?? 'Zona ${json['zone_id']}',
      state: json['state'] as String? ?? 'unknown',
      volume: json['volume'] as int? ?? 0,
      playlist: info['playlist'] as String? ?? '',
      mode: json['channel_mode'] as String? ?? '',
      channels: (output?['channels'] as List? ?? []).cast<int>(),
      songId: json['song_id']?.toString(),
      songMetadata: {
        for (final song
            in (info['song_metadata'] as List? ?? []).whereType<Map>())
          if (song['song_id'] is String)
            song['song_id'] as String: SongMetadata(
              title: song['title'] as String? ?? '',
              artist: song['artist'] as String?,
            ),
      },
      shuffle: info['shuffle'] as bool? ?? false,
      repeatMode: info['repeat_mode'] as String? ?? '',
      continuousPlayback: info['continuous_playback'] as bool? ?? false,
      schedule: info['schedule'] is Map
          ? ScheduleInfo.fromJson(
              Map<String, dynamic>.from(info['schedule'] as Map),
            )
          : null,
      songs: (info['songs'] as List? ?? []).whereType<String>().toList(
        growable: false,
      ),
      positionMs: ((info['position_ms'] ?? json['position_ms']) as num?)
          ?.toInt(),
      durationMs: (info['duration_ms'] as num?)?.toInt(),
      error: (json['error'] as Map<String, dynamic>?)?['message'] as String?,
    );
  }

  String get label => switch (state) {
    'playing' => 'Reproduciendo',
    'paused' => 'En pausa',
    'loading' => 'Cargando',
    'recovering' => 'Recuperando',
    'stopped' => 'Detenida',
    'error' => 'Error',
    _ => 'Sin estado',
  };
}

class SongMetadata {
  const SongMetadata({required this.title, this.artist});
  final String title;
  final String? artist;
}

class ActivityEntry {
  ActivityEntry(this.message) : time = DateTime.now();
  final String message;
  final DateTime time;
}
