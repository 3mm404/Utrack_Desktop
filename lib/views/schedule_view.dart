import 'package:flutter/material.dart';
import 'state/audio_view_state.dart';
import 'widgets/section_card.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key, required this.state});
  final AudioViewState state;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionCard(
          title: 'Programación',
          subtitle: 'Solo lectura · administrada desde Laravel',
          child: Text(
            'Consulta los horarios asignados a cada zona. Los cambios y la ejecución de la programación se gestionan en el servidor.',
          ),
        ),
        const SizedBox(height: 16),
        if (!state.fresh)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Sin actualización del engine. Los horarios mostrados corresponden al último estado recibido.',
            ),
          ),
        if (state.zones.isEmpty)
          const SectionCard(
            title: 'Sin zonas recibidas',
            child: Text(
              'Conecta el engine para consultar la programación asignada.',
            ),
          ),
        for (final zone in state.zones) ...[
          SectionCard(
            title: zone.name,
            subtitle: zone.schedule?.name ?? 'Sin programación asignada',
            trailing: const Icon(
              Icons.lock_outline,
              semanticLabel: 'Solo lectura',
            ),
            child: zone.schedule == null
                ? const Text(
                    'Esta zona no reporta una programación. Se administra desde Laravel; se requiere engine 0.8.7 o posterior para recibir horarios.',
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Zona horaria: ${zone.schedule!.timezone}'),
                      const SizedBox(height: 8),
                      Text(
                        zone.schedule!.stopOutsideSlots
                            ? 'Fuera de horario: detener música'
                            : 'Fuera de horario: conservar la reproducción',
                      ),
                      const SizedBox(height: 16),
                      if (zone.schedule!.slots.isEmpty)
                        const Text('Sin franjas configuradas.'),
                      for (final slot in zone.schedule!.slots)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slot.dayLabel,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${slot.startsAt}–${slot.endsAt}${slot.crossesMidnight ? ' · termina al día siguiente' : ''}',
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Playlist: ${slot.playlistName.isEmpty ? 'Sin nombre reportado' : slot.playlistName}',
                                ),
                                Text(
                                  slot.volume == null
                                      ? 'Volumen: sin cambio'
                                      : 'Volumen: ${slot.volume}%',
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    ),
  );
}
