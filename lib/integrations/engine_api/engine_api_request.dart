import 'engine_api_catalog.dart';

/// The single place that validates and serializes local command payloads.
class EngineApiRequest {
  const EngineApiRequest({
    required this.operation,
    required this.zoneId,
    this.songId,
    this.volume,
  });
  final EngineOperation operation;
  final String zoneId;
  final String? songId;
  final int? volume;

  String? validate() {
    if (zoneId.isEmpty) return 'Selecciona una zona.';
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
      'volume': ?volume,
    };
  }
}
