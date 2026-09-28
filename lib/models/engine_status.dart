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
    this.error,
  });

  final String id, name, state, playlist, mode;
  final int volume;
  final List<int> channels;
  final String? songId, error;

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
      songId: json['song_id'] as String?,
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

class ActivityEntry {
  ActivityEntry(this.message) : time = DateTime.now();
  final String message;
  final DateTime time;
}
