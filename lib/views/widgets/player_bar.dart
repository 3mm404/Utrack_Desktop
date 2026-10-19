import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import 'ui_controls.dart';
import '../state/zone_preview_state.dart';

/// Simulated player driven by presentation state; never plays audio.
class PlayerBar extends StatefulWidget {
  const PlayerBar({super.key, this.state});
  final ZonePreviewState? state;
  @override
  State<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar> {
  late final ZonePreviewState _state;
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

  PreviewTrack get _track => _state.track;
  double get _position => _state.selected.progress;
  double get _volume => _state.selected.volume;
  bool get _playing => _state.selected.playing;
  bool get _shuffle => _state.selected.shuffle;
  bool get _repeat => _state.selected.repeat;

  String _time(double seconds) {
    final total = seconds.floor();
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }

  void _skip(int direction) => _state.skip(direction);

  Widget _metadata() => Row(
    children: [
      _Cover(color: _track.color),
      const SizedBox(width: UiSpace.lg),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _track.title,
              style: UiType.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_state.selected.name} · ${_track.artist}',
              style: UiType.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: UiSpace.xs),
            Text(
              !_state.engineRunning
                  ? 'Motor detenido · simulado'
                  : _playing
                  ? 'Reproduciendo · simulado'
                  : 'En pausa · simulado',
              style: UiType.caption,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _transport() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      UiIconControl(
        icon: Icons.shuffle,
        label: 'Aleatorio',
        selected: _shuffle,
        onPressed: () => _state.toggleShuffle(),
      ),
      UiIconControl(
        icon: Icons.skip_previous,
        label: 'Canción anterior',
        onPressed: () => _skip(-1),
      ),
      CircularControl(
        icon: _playing ? Icons.pause : Icons.play_arrow,
        label: _playing ? 'Pausar vista previa' : 'Reproducir vista previa',
        selected: _playing,
        onPressed: _state.engineRunning ? _state.togglePlayback : null,
      ),
      UiIconControl(
        icon: Icons.skip_next,
        label: 'Canción siguiente',
        onPressed: () => _skip(1),
      ),
      UiIconControl(
        icon: Icons.repeat,
        label: 'Repetir',
        selected: _repeat,
        onPressed: () => _state.toggleRepeat(),
      ),
    ],
  );

  Widget _volumeControl() => Row(
    children: [
      UiIconControl(
        icon: _volume == 0 ? Icons.volume_off : Icons.volume_up,
        label: _volume == 0
            ? 'Restaurar volumen del reproductor'
            : 'Silenciar reproductor',
        onPressed: _state.toggleMute,
      ),
      Expanded(
        child: Slider(
          value: _volume,
          max: 100,
          label: '${_volume.round()}%',
          semanticFormatterCallback: (value) =>
              'Volumen del reproductor: ${value.round()}%',
          onChanged: (value) => _state.setVolume(_state.selectedIndex, value),
        ),
      ),
      SizedBox(
        width: 36,
        child: Text('${_volume.round()}%', style: UiType.caption),
      ),
    ],
  );

  Widget _progress() => Row(
    children: [
      Text(_time(_position), style: UiType.caption),
      Expanded(
        child: Slider(
          value: _position,
          max: _track.seconds.toDouble(),
          label: _time(_position),
          semanticFormatterCallback: (value) =>
              'Posición simulada: ${_time(value)} de ${_time(_track.seconds.toDouble())}',
          onChanged: _state.seek,
        ),
      ),
      Text(_time(_track.seconds.toDouble()), style: UiType.caption),
    ],
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _state,
    builder: (context, _) => DecoratedBox(
      decoration: const BoxDecoration(
        color: UiColors.surface,
        border: Border(top: UiEffects.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UiSpace.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1000;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (wide)
                  Row(
                    children: [
                      Expanded(child: _metadata()),
                      const SizedBox(width: UiSpace.xl),
                      _transport(),
                      const SizedBox(width: UiSpace.xl),
                      SizedBox(width: 240, child: _volumeControl()),
                    ],
                  )
                else ...[
                  if (constraints.maxWidth >= 600)
                    Row(
                      children: [
                        Expanded(child: _metadata()),
                        const SizedBox(width: UiSpace.lg),
                        _transport(),
                      ],
                    )
                  else ...[
                    _metadata(),
                    const SizedBox(height: UiSpace.sm),
                    _transport(),
                  ],
                  SizedBox(width: 300, child: _volumeControl()),
                ],
                _progress(),
                const Text(
                  'VISTA PREVIA · Sin audio real. Reloj simulado; controles aplicados a la zona seleccionada.',
                  style: UiType.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

/// Code-native album artwork, independent of external image assets.
class _Cover extends StatelessWidget {
  const _Cover({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Carátula ilustrada de muestra',
    image: true,
    child: Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: UiColors.input,
        borderRadius: UiRadii.control,
        border: Border.all(color: color),
      ),
      child: Center(
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: UiColors.elevated,
            border: Border.all(color: color.withValues(alpha: .5), width: 3),
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    ),
  );
}
