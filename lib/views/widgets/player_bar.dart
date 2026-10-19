import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import 'ui_controls.dart';
import '../state/zone_preview_state.dart';

/// Displays observed playback; enables transport only when supported.
class PlayerBar extends StatefulWidget {
  const PlayerBar({super.key, this.state});
  final AudioViewState? state;
  @override
  State<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar> {
  late final AudioViewState _state;
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

  TrackViewData get _track => _state.track;
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
              !_state.isSimulated
                  ? (!_state.hasSelection
                        ? 'Sin zona seleccionada'
                        : !_state.fresh
                        ? 'Sin actualización'
                        : (_state.selected.observedState ?? 'No reportado'))
                  : !_state.engineRunning
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
        onPressed: _state.canControlZones ? _state.toggleShuffle : null,
      ),
      UiIconControl(
        icon: Icons.skip_previous,
        label: 'Canción anterior',
        onPressed: _state.canPlayback('previous') ? () => _skip(-1) : null,
      ),
      CircularControl(
        icon: _playing ? Icons.pause : Icons.play_arrow,
        label: !_state.isSimulated
            ? (_playing
                  ? 'Pausar'
                  : _state.selected.observedState == 'En pausa'
                  ? 'Reanudar'
                  : 'Reproducir')
            : _playing
            ? 'Pausar vista previa'
            : 'Reproducir vista previa',
        selected: _playing,
        onPressed:
            _state.canPlayback(
                  _playing
                      ? 'pause'
                      : _state.selected.observedState == 'En pausa'
                      ? 'resume'
                      : 'play',
                ) &&
                _state.engineRunning
            ? _state.togglePlayback
            : null,
      ),
      UiIconControl(
        icon: Icons.skip_next,
        label: 'Canción siguiente',
        onPressed: _state.canPlayback('next') ? () => _skip(1) : null,
      ),
      UiIconControl(
        icon: Icons.repeat,
        label: 'Repetir',
        selected: _repeat,
        onPressed: _state.canControlZones ? _state.toggleRepeat : null,
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
        onPressed: _state.canControlZones ? _state.toggleMute : null,
      ),
      Expanded(
        child: Slider(
          value: _volume,
          max: 100,
          label: '${_volume.round()}%',
          semanticFormatterCallback: (value) =>
              'Volumen del reproductor: ${value.round()}%',
          onChanged: _state.canSetVolume
              ? (value) => _state.setVolume(_state.selectedIndex, value)
              : null,
        ),
      ),
      SizedBox(
        width: 36,
        child: Text(
          _state.hasSelection ? '${_volume.round()}%' : '—',
          style: UiType.caption,
        ),
      ),
    ],
  );

  Widget _progress() => Row(
    children: [
      Text(
        !_state.isSimulated && _state.selected.positionMs == null
            ? '—'
            : _time(_position),
        style: UiType.caption,
      ),
      Expanded(
        child: Slider(
          value: _track.seconds <= 0
              ? 0
              : _position.clamp(0, _track.seconds).toDouble(),
          max: _track.seconds > 0 ? _track.seconds.toDouble() : 1,
          label: _time(_position),
          semanticFormatterCallback: (value) => _state.isSimulated
              ? 'Posición simulada: ${_time(value)} de ${_time(_track.seconds.toDouble())}'
              : 'Posición reportada; duración no disponible',
          onChanged: _state.canControlZones ? _state.seek : null,
        ),
      ),
      Text(
        _track.seconds == 0 ? '—' : _time(_track.seconds.toDouble()),
        style: UiType.caption,
      ),
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
                if (!_state.isSimulated)
                  Text(
                    _state.playbackPending || _state.volumePending
                        ? 'Esperando confirmación del motor…'
                        : 'Reproducción y volumen por zona desde Desktop · Asignaciones desde el servidor.',
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
