import 'package:flutter/material.dart';
import '../controllers/engine_controller.dart';
import 'widgets/section_card.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({
    super.key,
    required this.controller,
    required this.onConfigure,
  });
  final EngineController controller;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          title: 'Tu equipo, conectado a la música',
          subtitle:
              'Configura la salida aquí. Controla canciones, playlists y volumen desde tu panel Laravel.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: c.canStart ? c.start : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar motor'),
              ),
              OutlinedButton.icon(
                onPressed: c.running && !c.busy ? c.stop : null,
                icon: const Icon(Icons.stop),
                label: const Text('Detener motor'),
              ),
              TextButton.icon(
                onPressed: onConfigure,
                icon: const Icon(Icons.tune),
                label: const Text('Configurar equipo'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth < 600
                ? constraints.maxWidth
                : (constraints.maxWidth - 32) / 3;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _metric(width, Icons.hub_outlined, 'Conexión', c.statusLabel),
                _metric(
                  width,
                  Icons.speaker_group_outlined,
                  'Salida configurada',
                  c.settings.backend == 'asio'
                      ? 'ASIO · ${c.settings.mode}'
                      : 'Windows · ${c.settings.mode}',
                ),
                _metric(
                  width,
                  Icons.graphic_eq,
                  'Zonas asignadas',
                  c.lastSnapshot == null ? '—' : '${c.zones.length}',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        if (c.configurationError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              c.configurationError,
              style: const TextStyle(color: Colors.amber, height: 1.5),
            ),
          ),
        SectionCard(
          title: 'Estado de las zonas',
          subtitle: c.running && c.fresh
              ? 'Estado observado en el motor · configuración ${c.revision}'
              : 'Inicia el motor para recibir estados actuales. Los datos anteriores no indican reproducción activa.',
          trailing: Icon(
            Icons.circle,
            size: 10,
            color: c.running && c.fresh
                ? const Color(0xff57d5be)
                : Colors.blueGrey,
          ),
          child: c.zones.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.queue_music,
                        color: Colors.blueGrey,
                        size: 38,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          c.connected
                              ? 'No hay zonas asignadas. Agrégalas a este equipo desde Laravel.'
                              : 'Las zonas aparecerán cuando el motor reciba su configuración.',
                          style: const TextStyle(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: c.zones
                      .map(
                        (zone) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xff0e1725),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.graphic_eq,
                                    color: Color(0xff57d5be),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      zone.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    c.running && c.fresh
                                        ? zone.label
                                        : 'Último: ${zone.label}',
                                    style: TextStyle(
                                      color: zone.error != null
                                          ? Colors.amber
                                          : const Color(0xffa9b9ca),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 24,
                                runSpacing: 8,
                                children: [
                                  Text(
                                    zone.playlist.isEmpty
                                        ? 'Sin playlist'
                                        : zone.playlist,
                                  ),
                                  Text('Volumen ${zone.volume}%'),
                                  Text(
                                    c.settings.backend == 'oto'
                                        ? 'Salida compartida'
                                        : 'Canales ${zone.channels.join(' · ')}',
                                  ),
                                  if (zone.songId != null)
                                    Text('Canción #${zone.songId}'),
                                ],
                              ),
                              if (zone.error != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    zone.error!,
                                    style: const TextStyle(color: Colors.amber),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Información del motor',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                'Servidor: ${c.settings.server.isEmpty ? 'Sin configurar' : c.settings.server}',
              ),
              const SizedBox(height: 10),
              Text('Engine ${c.version} · Windows x64'),
              const SizedBox(height: 10),
              SelectableText(
                'Configuración y logs: ${c.dataDirectory.isEmpty ? '—' : c.dataDirectory}',
              ),
              const SizedBox(height: 10),
              const Text(
                'Al cerrar esta aplicación se detiene el motor que inició. No se ejecuta como servicio.',
                style: TextStyle(color: Color(0xffa9b9ca)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metric(double width, IconData icon, String label, String value) =>
      SizedBox(
        width: width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: const Color(0xff57d5be)),
                const SizedBox(height: 18),
                Text(label, style: const TextStyle(color: Color(0xffa9b9ca))),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
