import 'engine_api_catalog.dart';

/// The single place that validates and serializes local command payloads.
class EngineApiRequest {
  const EngineApiRequest({
    required this.operation,
    required this.zoneId,
    this.songId,
    this.playlistId,
    this.preference,
    this.volume,
    this.positionMs,
    this.shuffle,
    this.repeatMode,
    this.continuousPlayback,
  });
  final EngineOperation operation;
  final String zoneId;
  final String? songId;
  final String? playlistId;
  final String? preference;
  final int? volume;
  final int? positionMs;
  final bool? shuffle, continuousPlayback;
  final String? repeatMode;

  String? validate() {
    if (operation.isPlaylistDownload) {
      if (zoneId.isNotEmpty) return 'La descarga no modifica una zona.';
    } else if (zoneId.isEmpty) {
      return 'Selecciona una zona.';
    }
    if (operation == EngineOperation.songPreference) {
      if (songId == null ||
          songId!.isEmpty ||
          !['like', 'dislike', 'neutral'].contains(preference)) {
        return 'Indica una canción y una preferencia válida.';
      }
    } else if (preference != null) {
      return 'Esta operación no admite preferencias.';
    }
    if (operation == EngineOperation.playPlaylist ||
        operation.isPlaylistDownload) {
      if (playlistId == null || playlistId!.isEmpty) {
        return 'Selecciona una playlist.';
      }
    } else if (playlistId != null) {
      return 'Esta operación no admite playlist.';
    }
    if (operation == EngineOperation.seek) {
      if (positionMs == null || positionMs! < 0) {
        return 'Indica una posición válida.';
      }
    } else if (positionMs != null) {
      return 'Solo seek admite posición.';
    }
    final hasModes =
        shuffle != null || repeatMode != null || continuousPlayback != null;
    if (operation == EngineOperation.playbackModes) {
      if (!hasModes) return 'Indica un modo de reproducción.';
      if (repeatMode != null &&
          !['off', 'track', 'playlist'].contains(repeatMode)) {
        return 'Repetición inválida.';
      }
    } else if (hasModes) {
      return 'Esta operación no admite modos.';
    }
    if (songId != null && (!operation.acceptsSong || songId!.isEmpty)) {
      return 'Solo reproducir admite una canción asignada.';
    }
    if (operation.requiresVolume) {
      if (volume == null || volume! < 0 || volume! > 100) {
        return 'El volumen debe estar entre 0 y 100.';
      }
    } else if (volume != null) {
      return 'Esta operación no admite volumen.';
    }
    return null;
  }

  Map<String, dynamic> toJson({
    required String requestId,
    required int revision,
  }) {
    final error = validate();
    if (error != null) throw ArgumentError(error);
    return {
      'request_id': requestId,
      'zone_id': zoneId,
      'config_revision': revision,
      'action': operation.wireName,
      'song_id': ?songId,
      'playlist_id': ?playlistId,
      'preference': ?preference,
      'volume': ?volume,
      'position_ms': ?positionMs,
      'shuffle': ?shuffle,
      'repeat_mode': ?repeatMode,
      'continuous_playback': ?continuousPlayback,
    };
  }
}
