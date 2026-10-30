import 'accessible_controls.dart';
import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import '../design/ui_palette.dart';
import 'section_card.dart';
import 'status_indicator.dart';
import 'ui_controls.dart';
import 'metal_dial.dart';
import '../state/zone_preview_state.dart';

/// Local presentation state only: no audio, persistence, or engine commands.
class ZoneMap extends StatefulWidget {
  const ZoneMap({
    super.key,
    this.state,
    this.showControls = true,
    this.maxSceneWidth = 620,
  });
  final double maxSceneWidth;
  final bool showControls;
  final AudioViewState? state;
  @override
  State<ZoneMap> createState() => _ZoneMapState();
}

class _ZoneMapState extends State<ZoneMap> {
  late final AudioViewState _state;
  List<ZoneViewData> get _zones => _state.zones;
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
      subtitle: _state.isSimulated
          ? 'Selecciona una habitación · datos simulados'
          : 'Zonas del servidor · plano y posiciones ilustrativos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _scene(),
          if (_zones.isEmpty)
            Padding(
              padding: EdgeInsets.all(UiSpace.lg),
              child: Text(
                'No hay zonas recibidas. Configura el servidor y token, inicia el motor y revisa la asignación de zonas en el servidor.',
                style: UiText.of(context).body,
              ),
            ),
          const SizedBox(height: UiSpace.lg),
          if (widget.showControls)
            Text(
              'Zona seleccionada: ${_state.selected.name}',
              style: UiText.of(context).title,
            ),
          const SizedBox(height: UiSpace.sm),
          if (widget.showControls)
            Text(
              'Volumen y reproducción de zona se administran desde el servidor',
              style: UiText.of(context).caption,
            ),
          const SizedBox(height: UiSpace.lg),
          if (!widget.showControls && MediaQuery.sizeOf(context).width < 900)
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

  Widget _scene() => LayoutBuilder(
    builder: (context, outer) {
      final sceneWidth = outer.maxWidth
          .clamp(0, widget.maxSceneWidth)
          .toDouble();
      return Center(
        child: SizedBox(
          width: sceneWidth,
          child: AspectRatio(
            aspectRatio: 1672 / 941,
            child: RepaintBoundary(
              child: LayoutBuilder(
                builder: (context, bounds) {
                  final side = bounds.maxWidth;
                  final height = bounds.maxHeight;
                  final callouts = side >= 430;
                  const labels = [
                    Offset(.01, .13),
                    Offset(.74, .06),
                    Offset(.08, .80),
                    Offset(.74, .71),
                  ];
                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/zone_floor_plan_v2.png',
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                          errorBuilder: (context, error, stack) => Center(
                            child: Text(
                              'Plano no disponible',
                              style: UiText.of(context).caption,
                            ),
                          ),
                        ),
                      ),
                      for (var i = 0; i < _zones.length; i++)
                        Positioned(
                          left: _zones[i].position.dx * side - 26,
                          top: _zones[i].position.dy * height - 26,
                          child: Semantics(
                            label: 'Seleccionar ${_zones[i].name}',
                            selected: _selected == i,
                            child: AccessibleTooltip(
                              message:
                                  '${_zones[i].name} · ${_zones[i].volume.round()}% · ${_state.isActive(i) ? 'Activa' : 'Inactiva'}',
                              child: MetalDial(
                                size: 52,
                                selected: _selected == i,
                                onTap: () => _state.select(i),
                              ),
                            ),
                          ),
                        ),
                      if (callouts)
                        for (var i = 0; i < _zones.length; i++)
                          Positioned(
                            left: labels[i].dx * side,
                            top: labels[i].dy * height,
                            width: side * .25,
                            child: _callout(i),
                          ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _callout(int index) {
    final zone = _zones[index];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: UiPalette.of(context).background.withValues(alpha: .94),
        borderRadius: UiRadii.card,
        border: Border.all(
          color: _selected == index
              ? UiPalette.of(context).accent.withValues(alpha: .8)
              : UiPalette.of(context).border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(zone.name, style: UiText.of(context).body),
          Row(
            children: [
              const Icon(Icons.volume_up, size: 15),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 3,
                    ),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: AccessibleSlider(
                    value: zone.volume,
                    max: 100,
                    onChanged: _state.canSetVolume
                        ? (value) => _state.setVolume(index, value)
                        : null,
                  ),
                ),
              ),
              Text(
                '${zone.volume.round()}%',
                style: UiText.of(context).caption.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _zoneControl(int index) {
    final zone = _zones[index];
    final selected = index == _selected;
    return Container(
      padding: const EdgeInsets.all(UiSpace.md),
      decoration: BoxDecoration(
        color: UiPalette.of(context).input,
        borderRadius: UiRadii.control,
        border: Border.all(
          color: selected
              ? UiPalette.of(context).accent
              : UiPalette.of(context).border,
        ),
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
                onPressed: _state.canControlZones && _state.engineRunning
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
            onChanged: _state.canSetVolume
                ? (value) => _state.setVolume(index, value)
                : null,
          ),
        ],
      ),
    );
  }
}
