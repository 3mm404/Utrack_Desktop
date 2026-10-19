import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import '../state/zone_preview_state.dart';
import 'section_card.dart';
import 'status_indicator.dart';
import 'configuration_row.dart';
import 'ui_controls.dart';
import 'volume_knob.dart';

class SelectedZonePanel extends StatelessWidget {
  const SelectedZonePanel({
    super.key,
    required this.state,
    this.compact = false,
  });
  final bool compact;
  final ZonePreviewState state;
  Widget _detail({required String label, required Widget control}) => compact
      ? Padding(
          padding: const EdgeInsets.symmetric(vertical: UiSpace.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label, style: UiType.caption),
              const SizedBox(height: UiSpace.xs),
              control,
            ],
          ),
        )
      : ConfigurationRow(label: label, control: control);
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) {
      final zone = state.selected;
      return SectionCard(
        title: 'Zona seleccionada',
        compact: compact,
        subtitle: compact ? null : 'Vista de prueba · sin audio real',
        trailing: Text(
          '${state.selectedIndex + 1}/${state.zones.length}',
          style: UiType.caption,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircularControl(
                  icon: Icons.chevron_left,
                  label: 'Zona anterior',
                  onPressed: () => state.select(
                    (state.selectedIndex - 1 + state.zones.length) %
                        state.zones.length,
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 160),
                    child: Text(
                      zone.name,
                      key: ValueKey(zone.name),
                      textAlign: TextAlign.center,
                      style: UiType.title,
                    ),
                  ),
                ),
                CircularControl(
                  icon: Icons.chevron_right,
                  label: 'Zona siguiente',
                  onPressed: () => state.select(
                    (state.selectedIndex + 1) % state.zones.length,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UiSpace.md),
            Center(
              child: StatusIndicator(
                label: state.isActive(state.selectedIndex)
                    ? (zone.playing
                          ? 'Reproduciendo · simulada'
                          : 'Activa · simulada')
                    : 'Inactiva · simulada',
                status: state.isActive(state.selectedIndex)
                    ? UiStatus.operational
                    : UiStatus.inactive,
              ),
            ),
            const SizedBox(height: UiSpace.xl),
            Center(
              child: VolumeKnob(
                value: zone.volume,
                diameter: compact ? 168 : 208,
                onChanged: (value) =>
                    state.setVolume(state.selectedIndex, value),
              ),
            ),
            const Center(
              child: Text(
                'Volumen · arrastra o usa las flechas',
                textAlign: TextAlign.center,
                style: UiType.caption,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UiIconControl(
                  icon: Icons.remove,
                  label: 'Bajar volumen',
                  onPressed: () =>
                      state.setVolume(state.selectedIndex, zone.volume - 1),
                ),
                UiIconControl(
                  icon: Icons.add,
                  label: 'Subir volumen',
                  onPressed: () =>
                      state.setVolume(state.selectedIndex, zone.volume + 1),
                ),
                UiIconControl(
                  icon: zone.active ? Icons.volume_up : Icons.volume_off,
                  label: 'Alternar estado de zona (simulado)',
                  onPressed: state.engineRunning
                      ? () => state.toggle(state.selectedIndex)
                      : null,
                ),
              ],
            ),
            const Divider(),
            if (!compact)
              ConfigurationRow(
                label: 'Salida',
                control: Text(state.device.name, style: UiType.caption),
              ),
            _detail(
              label: 'Fuente',
              control: Text('Playlist · ${zone.source}', style: UiType.caption),
            ),
            _detail(
              label: 'Canales',
              control: DropdownButtonFormField<String>(
                key: ValueKey('${zone.name}-${zone.channels}'),
                initialValue: zone.channels,
                decoration: const InputDecoration(labelText: 'Modo de canales'),
                items: const [
                  DropdownMenuItem(value: 'Mono', child: Text('Mono')),
                  DropdownMenuItem(value: 'Estéreo', child: Text('Estéreo')),
                ],
                onChanged: (value) {
                  if (value != null) state.setChannels(value);
                },
              ),
            ),
            _detail(
              label: 'Canción actual',
              control: Text(
                zone.playing ? zone.song : 'En pausa · ${zone.song}',
                style: UiType.caption,
              ),
            ),
          ],
        ),
      );
    },
  );
}
