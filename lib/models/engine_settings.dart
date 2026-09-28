class EngineSettings {
  const EngineSettings({
    this.server = '',
    this.backend = 'oto',
    this.mode = 'stereo',
    this.driver = '',
    this.sampleRate = 48000,
    this.bufferSize = 256,
    this.channels = 0,
  });

  final String server;
  final String backend;
  final String mode;
  final String driver;
  final int sampleRate;
  final int bufferSize;
  final int channels;

  factory EngineSettings.fromJson(Map<String, dynamic> json) => EngineSettings(
    server: json['server'] as String? ?? '',
    backend: json['backend'] as String? ?? 'asio',
    mode: json['mode'] as String? ?? 'stereo',
    driver: json['asio_driver'] as String? ?? '',
    sampleRate: (json['sample_rate'] as int? ?? 0) > 0
        ? json['sample_rate'] as int
        : 48000,
    bufferSize: (json['buffer_size'] as int? ?? 0) > 0
        ? json['buffer_size'] as int
        : 256,
    channels: json['channels'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'server': server.trim(),
    'backend': backend,
    'mode': mode,
    'asio_driver': driver.trim(),
    'sample_rate': sampleRate,
    'buffer_size': bufferSize,
    'channels': channels,
  };

  String? validate() {
    final uri = Uri.tryParse(server.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      return 'Ingresa una dirección HTTPS sin credenciales ni parámetros.';
    }
    if (!['oto', 'asio'].contains(backend) ||
        !['mono', 'stereo'].contains(mode)) {
      return 'Selecciona una salida y un modo válidos.';
    }
    if (backend == 'asio') {
      if (driver.trim().isEmpty) return 'Selecciona un driver ASIO.';
      if (sampleRate < 8000 || sampleRate > 384000) {
        return 'La frecuencia debe estar entre 8000 y 384000 Hz.';
      }
      if (bufferSize < 1 || bufferSize > 65536) {
        return 'El buffer debe estar entre 1 y 65536 frames.';
      }
      if (channels < 0 || channels > 64) {
        return 'Usa entre 1 y 64 canales, o 0 para automático.';
      }
    }
    return null;
  }
}
