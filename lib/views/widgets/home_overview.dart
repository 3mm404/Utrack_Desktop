import 'package:flutter/material.dart';
import '../state/audio_view_state.dart';
import '../design/ui_palette.dart';
import '../design/ui_theme.dart';
import 'app_surface.dart';

class HomeOverview extends StatelessWidget {
  const HomeOverview({super.key, required this.state});
  final AudioViewState state;

  String _age(DateTime? time) {
    if (time == null) return 'Sin señal recibida';
    final seconds = DateTime.now().difference(time).inSeconds.clamp(0, 999999);
    return seconds < 2
        ? 'Hace un instante'
        : seconds < 60
        ? 'Hace $seconds s'
        : 'Hace ${seconds ~/ 60} min';
  }

  @override
  Widget build(BuildContext context) {
    final palette = UiPalette.of(context);
    final output = state.device;
    final bufferMs =
        output.bufferFrames != null &&
            output.sampleRate != null &&
            output.sampleRate! > 0
        ? output.bufferFrames! * 1000 / output.sampleRate!
        : null;
    final errors = state.zones.where((zone) => zone.failure != null).length;
    final uptime = state.uptimeSeconds;
    final host = Uri.tryParse(state.server)?.host;
    var panelIndex = 0;
    final light = Theme.of(context).brightness == Brightness.light;
    final finishes = light
        ? const [
            [Color(0xfffafffc), Color(0xffedf9f3)],
            [Color(0xfffffaf6), Color(0xffffefe5)],
            [Color(0xfff8faff), Color(0xffedf2ff)],
            [Color(0xfffcfaff), Color(0xfff1edfc)],
          ]
        : const [
            [Color(0xff1d3431), Color(0xff18282a)],
            [Color(0xff342b29), Color(0xff29232a)],
            [Color(0xff242f45), Color(0xff1c2537)],
            [Color(0xff302b44), Color(0xff252135)],
          ];
    Widget metric(
      IconData icon,
      String label,
      String value,
      String detail,
      String footer,
      Color tint, {
      double? progress,
    }) {
      final index = panelIndex++;
      tint = switch (index) {
        0 => const Color(0xff0c9e79),
        1 => const Color(0xffff641d),
        2 => const Color(0xff3976f6),
        _ => const Color(0xff8353e9),
      };
      return Theme(
        data: light ? UiTheme.light : UiTheme.dark,
        child: Builder(
          builder: (context) => AppCard(
            finish: finishes[index],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: tint.withValues(alpha: .14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: tint, size: 26),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(label, style: UiText.of(context).label),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    value,
                    style: UiText.of(context).heading.copyWith(fontSize: 25),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail,
                    style: UiText.of(context).caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  if (progress != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0, 1),
                        color: tint,
                        backgroundColor: tint.withValues(alpha: .12),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  else
                    const SizedBox(height: 16),
                  Text(
                    footer,
                    style: UiText.of(context).caption.copyWith(color: tint),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final metrics = [
      metric(
        Icons.wifi_rounded,
        'Conectividad',
        state.connected
            ? 'Conectado'
            : state.engineRunning
            ? 'Reconectando'
            : 'Desconectado',
        host == null || host.isEmpty ? 'Servidor no configurado' : host,
        'Heartbeat · ${_age(state.lastHeartbeat)}',
        state.connected ? palette.operational : palette.warning,
      ),
      metric(
        Icons.equalizer_rounded,
        'Reproducción',
        '${state.activeZones} / ${state.zones.length} zonas',
        errors > 0
            ? '$errors zonas necesitan atención'
            : 'Sin errores de reproducción reportados',
        state.isSimulated
            ? 'Estado simulado'
            : 'Configuración · revisión ${state.configurationRevision}',
        errors > 0 ? palette.warning : palette.accent,
        progress: state.zones.isEmpty
            ? 0
            : state.activeZones / state.zones.length,
      ),
      metric(
        Icons.speed_rounded,
        'Rendimiento del engine',
        state.cpu == null
            ? 'Sin lectura'
            : '${state.cpu!.toStringAsFixed(1)}% CPU',
        state.heapBytes == null
            ? 'Memoria Go · sin lectura'
            : 'Memoria Go · ${(state.heapBytes! / 1048576).toStringAsFixed(1)} MB',
        state.isSimulated
            ? 'Métricas simuladas'
            : uptime == null
            ? 'Esperando telemetría del equipo'
            : 'Activo · ${uptime ~/ 3600} h ${(uptime % 3600) ~/ 60} min',
        palette.blue,
        progress: state.cpu == null ? null : state.cpu! / 100,
      ),
      metric(
        Icons.speaker_group_outlined,
        'Salida configurada',
        output.sampleRate == null
            ? (state.needsConfiguration ? 'Sin configurar' : output.backend)
            : '${(output.sampleRate! / 1000).toStringAsFixed(1)} kHz',
        output.bufferFrames == null
            ? output.name
            : '${output.bufferFrames} frames · ${output.mode ?? 'Audio'}',
        bufferMs == null
            ? output.backend
            : 'Búfer configurado · ${bufferMs.toStringAsFixed(1)} ms',
        palette.accent,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 28),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado del equipo',
                    style: UiText.of(context).heading.copyWith(
                      fontSize: constraints.maxWidth >= 900 ? 38 : 30,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Conexión, rendimiento y música en tiempo real.',
                    style: UiText.of(
                      context,
                    ).body.copyWith(color: palette.muted),
                  ),
                ],
              );
              return title;
            },
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1150
                ? 4
                : constraints.maxWidth >= 620
                ? 2
                : 1;
            final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final card in metrics) SizedBox(width: width, child: card),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              Text(
                'Sincronización: ${state.serverSynced ? 'al día' : 'pendiente'}',
                style: UiText.of(context).caption,
              ),
              Text(
                'Estado local: ${_age(state.lastSnapshot)}',
                style: UiText.of(context).caption,
              ),
              Text(
                'Engine ${state.version.isEmpty ? '—' : state.version}',
                style: UiText.of(context).caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
