import 'accessible_controls.dart';
import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import '../design/ui_palette.dart';
import 'ui_controls.dart';
import 'cover_artwork.dart';

import '../state/zone_preview_state.dart';

/// Displays observed playback; enables transport only when supported.
class PlayerBar extends StatefulWidget {
  const PlayerBar({super.key, this.state});
  final AudioViewState? state;
  @override
  State<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar> {
  double? _seekDraft;
  String? _seekZone;
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
  double get _position => _seekDraft ?? _state.selected.progress;
  double get _duration =>
      (_state.selected.durationMs ?? _track.seconds * 1000) / 1000;
  double get _volume => _state.selected.volume;
  bool get _playing => _state.selected.playing;
  bool get _shuffle => _state.selected.shuffle;
  bool get _repeat => _state.selected.repeat;

  String _time(double seconds) {
    final total = seconds.floor();
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }

  void _skip(int direction) => _state.skip(direction);

  Widget _metadata({bool compact = false}) => Row(
    children: [
      CoverArtwork(
        path: _track.coverPath,
        label: _track.title,
        size: compact ? 44 : 64,
      ),
      const SizedBox(width: UiSpace.lg),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _track.title,
              style: UiText.of(context).title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_state.selected.name} · ${_track.artist}',
              style: UiText.of(context).caption,
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
              style: UiText.of(context).caption,
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
        onPressed: _state.canSetPlaybackModes ? _state.toggleShuffle : null,
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
      if (!_state.isSimulated)
        UiIconControl(
          icon: Icons.stop,
          label: 'Detener zona',
          onPressed: _state.canPlayback('stop') ? _state.stopPlayback : null,
        ),
      UiIconControl(
        icon: Icons.repeat,
        label: _state.isSimulated
            ? 'Repetir'
            : 'Repetir: ${switch (_state.selected.repeatMode) {
                'track' => 'una canción',
                'playlist' => 'playlist',
                _ => 'desactivado',
              }}',
        selected: _repeat,
        onPressed: _state.canSetPlaybackModes ? _state.toggleRepeat : null,
      ),
      if (!_state.isSimulated)
        UiIconControl(
          icon: Icons.playlist_play,
          label: 'Avance automático',
          selected: _state.selected.continuousPlayback,
          onPressed: _state.canSetPlaybackModes
              ? _state.toggleAutoAdvance
              : null,
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
        child: AccessibleSlider(
          value: _volume.clamp(0, 100),
          max: 100,
          label: '${_volume.round()}%',
          semanticFormatterCallback: (value) => 'Volumen: ${value.round()}%',
          onChanged: _state.canSetVolume
              ? (value) => _state.setVolume(_state.selectedIndex, value)
              : null,
        ),
      ),
      SizedBox(
        width: 36,
        child: Text(
          _state.hasSelection ? '${_volume.round()}%' : '—',
          style: UiText.of(context).caption,
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
        style: UiText.of(context).caption,
      ),
      Expanded(
        child: AccessibleSlider(
          value: _duration <= 0 ? 0 : _position.clamp(0, _duration).toDouble(),
          max: _duration > 0 ? _duration : 1,
          label: _time(_position),
          semanticFormatterCallback: (value) => _state.isSimulated
              ? 'Posición simulada: ${_time(value)} de ${_time(_track.seconds.toDouble())}'
              : _track.seconds > 0
              ? 'Posición reportada: ${_time(value)} de ${_time(_track.seconds.toDouble())}'
              : 'Posición reportada; duración no disponible',
          onChanged: _state.canSeek
              ? (value) {
                  if (_state.isSimulated) {
                    _state.seek(value);
                    return;
                  }
                  setState(() {
                    _seekZone ??= _state.selected.id;
                    _seekDraft = value;
                  });
                }
              : null,
          onChangeEnd: !_state.isSimulated && _state.canSeek
              ? (value) {
                  if (_seekZone == _state.selected.id) _state.seek(value);
                  setState(() {
                    _seekDraft = null;
                    _seekZone = null;
                  });
                }
              : null,
        ),
      ),
      Text(
        _track.seconds == 0 ? '—' : _time(_track.seconds.toDouble()),
        style: UiText.of(context).caption,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _state,
    builder: (context, _) => DecoratedBox(
      decoration: BoxDecoration(
        gradient: UiDecor.of(context).panelGradient,
        boxShadow: UiDecor.of(context).cardShadow,
        border: Border(top: UiDecor.of(context).border),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
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
                    _metadata(compact: true),
                    const SizedBox(height: UiSpace.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _transport(),
                    ),
                  ],
                  if (constraints.maxWidth >= 600)
                    SizedBox(width: 300, child: _volumeControl()),
                ],
                if (constraints.maxWidth < 600)
                  Row(
                    children: [
                      Expanded(child: _progress()),
                      const SizedBox(width: 8),
                      UiIconControl(
                        icon: _volume == 0 ? Icons.volume_off : Icons.volume_up,
                        label: _volume == 0
                            ? 'Restaurar volumen del reproductor'
                            : 'Silenciar reproductor',
                        onPressed: _state.canControlZones
                            ? _state.toggleMute
                            : null,
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${_volume.round()}%',
                          style: UiText.of(context).caption,
                        ),
                      ),
                    ],
                  )
                else
                  _progress(),
                if (!_state.isSimulated &&
                    (_state.playbackPending || _state.volumePending))
                  Text(
                    'Esperando confirmación del equipo…',
                    style: UiText.of(context).caption,
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
