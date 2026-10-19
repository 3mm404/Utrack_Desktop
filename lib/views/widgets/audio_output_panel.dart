import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import 'section_card.dart';
import 'status_indicator.dart';
import '../state/zone_preview_state.dart';

/// Visual sample only; does not enumerate or configure system audio devices.
class AudioOutputPanel extends StatelessWidget {
  const AudioOutputPanel({
    super.key,
    required this.state,
    this.compact = false,
  });
  final bool compact;
  final ZonePreviewState state;

  Widget _compactPanel(BuildContext context) => SectionCard(
    title: 'Salida de audio',
    compact: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DeviceImage(compact: true),
        const SizedBox(height: UiSpace.sm),
        Text(
          '${state.device.backend} · ${state.selected.channels}',
          style: UiType.body,
        ),
        const SizedBox(height: UiSpace.sm),
        Text(state.device.driver, style: UiType.caption),
        const SizedBox(height: UiSpace.md),
        DropdownButtonFormField<int>(
          key: ValueKey(state.deviceIndex),
          initialValue: state.deviceIndex,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Salida simulada'),
          items: [
            for (var i = 0; i < ZonePreviewState.devices.length; i++)
              DropdownMenuItem(
                value: i,
                child: Text(
                  ZonePreviewState.devices[i].name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null) state.selectDevice(value);
          },
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => compact
        ? _compactPanel(context)
        : SectionCard(
            title: 'Salida de audio',
            compact: compact,
            subtitle: compact ? null : 'Dispositivo de ejemplo · simulado',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DeviceImage(),
                SizedBox(height: UiSpace.lg),
                Text(state.device.name, style: UiType.title),
                SizedBox(height: UiSpace.sm),
                Text(
                  '${state.device.backend} · ${state.selected.channels}',
                  style: UiType.body,
                ),
                SizedBox(height: UiSpace.lg),
                StatusIndicator(
                  label: state.engineRunning
                      ? 'Disponible · simulado'
                      : 'Motor detenido · simulado',
                  status: state.engineRunning
                      ? UiStatus.operational
                      : UiStatus.inactive,
                ),
                SizedBox(height: UiSpace.lg),
                _OutputDetail(
                  label: 'Driver de ejemplo',
                  value: state.device.driver,
                ),
                if (!compact)
                  _OutputDetail(label: 'Frecuencia', value: '48 000 Hz'),
                if (!compact)
                  _OutputDetail(label: 'Buffer', value: '256 frames'),
                if (!compact)
                  _OutputDetail(
                    label: 'Canales de salida',
                    value: state.selected.channels == 'Mono' ? '1' : '1–2',
                  ),
                DropdownButtonFormField<int>(
                  key: ValueKey(state.deviceIndex),
                  initialValue: state.deviceIndex,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Salida simulada',
                  ),
                  items: [
                    for (var i = 0; i < ZonePreviewState.devices.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(
                          ZonePreviewState.devices[i].name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) state.selectDevice(value);
                  },
                ),
                SizedBox(height: UiSpace.sm),
                if (!compact)
                  Text(
                    'Vista de prueba. No detecta ni modifica el hardware del equipo.',
                    style: UiType.caption,
                  ),
              ],
            ),
          ),
  );
}

class _DeviceImage extends StatelessWidget {
  const _DeviceImage({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: UiColors.input,
      borderRadius: UiRadii.control,
      border: Border.fromBorderSide(UiEffects.border),
    ),
    child: ClipRRect(
      borderRadius: UiRadii.control,
      child: AspectRatio(
        aspectRatio: compact ? 2.4 : 1.6,
        child: Image.asset(
          'assets/images/audio_interface.png',
          fit: BoxFit.contain,
          semanticLabel: 'Ilustración de una interfaz de audio USB de ejemplo',
          errorBuilder: (context, error, stack) => const Center(
            child: Text(
              'Imagen del dispositivo no disponible',
              style: UiType.caption,
            ),
          ),
        ),
      ),
    ),
  );
}

class _OutputDetail extends StatelessWidget {
  const _OutputDetail({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: UiSpace.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: UiType.caption),
        const SizedBox(height: UiSpace.xs),
        Text(value, style: UiType.body),
      ],
    ),
  );
}
