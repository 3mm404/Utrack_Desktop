import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import 'section_card.dart';
import 'status_indicator.dart';
import 'ui_controls.dart';
import '../state/zone_preview_state.dart';

/// Local presentation state only: no audio, persistence, or engine commands.
class ZoneMap extends StatefulWidget {
  const ZoneMap({super.key, this.state, this.showControls = true});
  final bool showControls;
  final ZonePreviewState? state;
  @override
  State<ZoneMap> createState() => _ZoneMapState();
}

class _ZoneMapState extends State<ZoneMap> {
  late final ZonePreviewState _state;
  List<PreviewZone> get _zones => _state.zones;
  int get _selected => _state.selectedIndex;
  @override
  void initState() {
    super.initState();
    _state = widget.state ?? ZonePreviewState();
  }

  @override
  void dispose() {
    if (widget.state == null) _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _state,
    builder: (context, _) => SectionCard(
      title: 'Zonas de audio',
      compact: !widget.showControls,
      subtitle: 'Selecciona una habitación · datos simulados',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: widget.showControls ? 520 : 440,
              ),
              child: RepaintBoundary(
                child: LayoutBuilder(
                  builder: (context, constraints) => AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: UiRadii.control,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/zone_floor_plan.png',
                              fit: BoxFit.contain,
                              excludeFromSemantics: true,
                              errorBuilder: (context, error, stack) =>
                                  const Center(
                                    child: Text(
                                      'Plano no disponible',
                                      style: UiType.caption,
                                    ),
                                  ),
                            ),
                          ),
                          for (var i = 0; i < _zones.length; i++)
                            Positioned(
                              left:
                                  _zones[i].position.dx * constraints.maxWidth -
                                  24,
                              top:
                                  _zones[i].position.dy * constraints.maxWidth -
                                  24,
                              child: Semantics(
                                label: 'Seleccionar ${_zones[i].name}',
                                selected: _selected == i,
                                child: Tooltip(
                                  message:
                                      '${_zones[i].name} · ${_zones[i].volume.round()}% · ${_state.isActive(i) ? 'Activa' : 'Inactiva'}',
                                  child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Material(
                                      color: UiColors.input,
                                      shape: CircleBorder(
                                        side: BorderSide(
                                          color: _selected == i
                                              ? UiColors.accent
                                              : UiColors.border,
                                          width: _selected == i ? 2 : 1,
                                        ),
                                      ),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () => _state.select(i),
                                        child: Icon(
                                          Icons.speaker,
                                          size: 20,
                                          color: _state.isActive(i)
                                              ? UiColors.operational
                                              : UiColors.muted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: UiSpace.lg),
          if (widget.showControls)
            Text(
              'Zona seleccionada: ${_zones[_selected].name}',
              style: UiType.title,
            ),
          const SizedBox(height: UiSpace.sm),
          if (widget.showControls)
            const Text(
              'Controles de prueba · cambios solo en esta vista',
              style: UiType.caption,
            ),
          const SizedBox(height: UiSpace.lg),
          if (!widget.showControls)
            Wrap(
              spacing: UiSpace.sm,
              runSpacing: UiSpace.sm,
              children: [
                for (var i = 0; i < _zones.length; i++)
                  ChoiceChip(
                    label: Text(
                      '${_zones[i].name} · ${_zones[i].volume.round()}%',
                    ),
                    selected: _selected == i,
                    onSelected: (_) => _state.select(i),
                  ),
              ],
            ),
          if (widget.showControls)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth >= 550
                    ? (constraints.maxWidth - UiSpace.lg) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: UiSpace.lg,
                  runSpacing: UiSpace.lg,
                  children: [
                    for (var i = 0; i < _zones.length; i++)
                      SizedBox(width: width, child: _zoneControl(i)),
                  ],
                );
              },
            ),
        ],
      ),
    ),
  );

  Widget _zoneControl(int index) {
    final zone = _zones[index];
    final selected = index == _selected;
    return Container(
      padding: const EdgeInsets.all(UiSpace.md),
      decoration: BoxDecoration(
        color: UiColors.input,
        borderRadius: UiRadii.control,
        border: Border.all(color: selected ? UiColors.accent : UiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _state.select(index),
                  child: Text(zone.name),
                ),
              ),
              UiIconControl(
                icon: _state.isActive(index)
                    ? Icons.volume_up
                    : Icons.volume_off,
                label:
                    '${_state.isActive(index) ? 'Desactivar' : 'Activar'} ${zone.name} (simulado)',
                selected: zone.active,
                onPressed: _state.engineRunning
                    ? () => _state.toggle(index)
                    : null,
              ),
            ],
          ),
          StatusIndicator(
            label: _state.isActive(index)
                ? 'Activa · simulada'
                : 'Inactiva · simulada',
            status: _state.isActive(index)
                ? UiStatus.operational
                : UiStatus.inactive,
          ),
          const SizedBox(height: UiSpace.md),
          UiSlider(
            label: 'Volumen ${zone.name}',
            value: zone.volume,
            onChanged: (value) => _state.setVolume(index, value),
          ),
        ],
      ),
    );
  }
}
