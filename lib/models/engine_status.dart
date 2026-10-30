import 'package:flutter/foundation.dart';

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
    this.coverPath,
    this.backgroundPath,
    this.playlistId,
    this.songPreferences = const {},
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
  final String? coverPath;
  final String? backgroundPath;
  final String? playlistId;
  final Map<String, String> songPreferences;

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
      coverPath: info['cover_path'] as String?,
      backgroundPath: info['background_path'] as String?,
      playlistId: info['playlist_id'] as String?,
      songPreferences: (info['song_preferences'] as Map? ?? {}).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
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
              coverPath: song['cover_path'] as String?,
            ),
      },
      shuffle: info['shuffle'] as bool? ?? false,
      repeatMode: info['repeat_mode'] as String? ?? '',
      continuousPlayback: info['continuous_playback'] as bool? ?? false,
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
  const SongMetadata({required this.title, this.artist, this.coverPath});
  final String title;
  final String? artist;
  final String? coverPath;

  @override
  bool operator ==(Object other) =>
      other is SongMetadata &&
      title == other.title &&
      artist == other.artist &&
      coverPath == other.coverPath;
  @override
  int get hashCode => Object.hash(title, artist, coverPath);
}

class ActivityEntry {
  ActivityEntry(this.message) : time = DateTime.now();
  final String message;
  final DateTime time;
}

class PlaylistInfo {
  const PlaylistInfo({
    required this.id,
    required this.name,
    this.coverPath,
    this.songs = const {},
  });
  final String id, name;
  final String? coverPath;
  final Map<String, SongMetadata> songs;

  @override
  bool operator ==(Object other) =>
      other is PlaylistInfo &&
      id == other.id &&
      name == other.name &&
      coverPath == other.coverPath &&
      listEquals(songs.keys.toList(), other.songs.keys.toList()) &&
      mapEquals(songs, other.songs);
  @override
  int get hashCode => Object.hash(
    id,
    name,
    coverPath,
    Object.hashAll(
      songs.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );

  factory PlaylistInfo.fromJson(Map<String, dynamic> json) => PlaylistInfo(
    id: json['playlist_id'].toString(),
    name: json['name'] as String? ?? 'Playlist',
    coverPath: json['cover_path'] as String?,
    songs: {
      for (final song in (json['songs'] as List? ?? []).whereType<Map>())
        song['song_id'].toString(): SongMetadata(
          title: song['title'] as String? ?? '',
          artist: song['artist'] as String?,
          coverPath: song['cover_path'] as String?,
        ),
    },
  );
}
