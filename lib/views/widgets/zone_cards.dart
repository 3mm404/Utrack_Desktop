import 'accessible_controls.dart';
import 'package:flutter/material.dart';
import '../state/audio_view_state.dart';
import '../design/ui_palette.dart';
import 'zone_artwork.dart';
import 'app_surface.dart';
import 'song_preference_controls.dart';

/// One space, one set of actions. Selection never starts playback.
class ZoneCards extends StatelessWidget {
  const ZoneCards({
    super.key,
    required this.state,
    required this.onLibrary,
    required this.onConfigure,
    this.showOverview = false,
  });
  final AudioViewState state;
  final VoidCallback onLibrary, onConfigure;
  final bool showOverview;

  IconData _icon(String name) {
    final text = name.toLowerCase();
    if (text.contains('caf') || text.contains('bar')) {
      return Icons.local_cafe_outlined;
    }
    if (text.contains('hab') || text.contains('dorm')) {
      return Icons.bed_outlined;
    }
    if (text.contains('terra') || text.contains('jard')) {
      return Icons.yard_outlined;
    }
    return Icons.speaker_group_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final palette = UiPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showOverview)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Todo bajo control',
                  style: UiText.of(context).heading.copyWith(
                    fontSize: MediaQuery.sizeOf(context).width >= 900 ? 38 : 30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Crea el ambiente perfecto en cada espacio.',
                  style: UiText.of(context).body.copyWith(color: palette.muted),
                ),
              ],
            ),
          ),
        if (state.zones.isNotEmpty) ...[
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth < 600
                  ? 226.0
                  : ((constraints.maxWidth - 48) / 4).clamp(220.0, 340.0);
              return SizedBox(
                height: 172,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.zones.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final zone = state.zones[index];
                    final selected = index == state.selectedIndex;
                    return SizedBox(
                      width: width,
                      child: Semantics(
                        selected: selected,
                        button: true,
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => state.select(index),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ZoneArtwork(
                                  path: zone.backgroundPath,
                                  label: zone.name,
                                  width: width,
                                  height: 172,
                                ),
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Color(0xcc17202b),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Icon(
                                          selected
                                              ? Icons.check_circle_rounded
                                              : Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          Icon(
                                            _icon(zone.name),
                                            size: 23,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              zone.name,
                                              style: UiText.of(context).title
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        zone.source,
                                        style: UiText.of(context).caption
                                            .copyWith(
                                              color: Colors.white.withValues(
                                                alpha: .85,
                                              ),
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
        Text(
          'Tus zonas',
          style: UiText.of(context).heading.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 6),
        Text(
          'Selecciona un espacio para controlar su música.',
          style: UiText.of(context).caption,
        ),
        const SizedBox(height: 18),
        if (state.zones.isEmpty)
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Icon(
                    Icons.speaker_group_outlined,
                    size: 40,
                    color: palette.muted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.needsConfiguration
                        ? 'Conecta tu equipo'
                        : 'Esperando tus zonas',
                    style: UiText.of(context).title,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.needsConfiguration
                        ? 'Guarda la configuración una vez. La próxima conexión será automática.'
                        : state.status,
                    style: UiText.of(context).caption,
                    textAlign: TextAlign.center,
                  ),
                  if (state.needsConfiguration || !state.engineRunning)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: OutlinedButton.icon(
                        onPressed: onConfigure,
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('Abrir ajustes'),
                      ),
                    ),
                ],
              ),
            ),
          )
        else
          _detail(context),
      ],
    );
  }

  Widget _detail(BuildContext context) {
    final palette = UiPalette.of(context);
    final zone = state.selected;
    final action = zone.playing
        ? 'pause'
        : zone.observedState == 'En pausa'
        ? 'resume'
        : 'play';
    final canPlay =
        state.fresh &&
        state.engineRunning &&
        !state.playbackPending &&
        (state.isSimulated || state.canPlayback(action));
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final artwork = ZoneArtwork(
              path: zone.backgroundPath,
              label: zone.name,
              width: wide ? 320 : constraints.maxWidth,
              height: wide ? 250 : 160,
            );
            final information = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        zone.name,
                        style: UiText.of(
                          context,
                        ).heading.copyWith(fontSize: 28),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: zone.playing ? palette.operational : palette.muted,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  zone.source,
                  style: UiText.of(context).body.copyWith(color: palette.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Text(
                  zone.song,
                  style: UiText.of(context).label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  zone.observedState ??
                      (zone.playing ? 'Reproduciendo' : 'En pausa'),
                  style: UiText.of(context).caption,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AccessibleTooltip(
                      message:
                          '${zone.playing ? 'Pausar' : 'Reproducir'} ${zone.name}',
                      child: FilledButton.icon(
                        onPressed: canPlay ? state.togglePlayback : null,
                        icon: Icon(
                          zone.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          zone.playing ? 'Pausar' : 'Reproducir',
                          style: const TextStyle(fontFamily: 'Roboto'),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onLibrary,
                      icon: const Icon(Icons.library_music_outlined, size: 20),
                      label: const Text(
                        'Elegir música',
                        style: TextStyle(fontFamily: 'Roboto'),
                      ),
                    ),
                    if (zone.songId != null)
                      SongPreferenceControls(
                        state: state,
                        zoneId: zone.id,
                        songId: zone.songId!,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.volume_up_outlined,
                      size: 20,
                      color: palette.muted,
                    ),
                    Expanded(
                      child: AccessibleSlider(
                        value: zone.volume.clamp(0, 100),
                        max: 100,
                        label: '${zone.volume.round()}%',
                        semanticFormatterCallback: (value) =>
                            'Volumen de ${zone.name}: ${value.round()}%',
                        onChanged: state.canSetVolume
                            ? (value) =>
                                  state.setVolume(state.selectedIndex, value)
                            : null,
                      ),
                    ),
                    Text(
                      '${zone.volume.round()}%',
                      style: UiText.of(context).caption,
                    ),
                  ],
                ),
              ],
            );
            return wide
                ? Row(
                    children: [
                      artwork,
                      const SizedBox(width: 30),
                      Expanded(child: information),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      artwork,
                      const SizedBox(height: 20),
                      information,
                    ],
                  );
          },
        ),
      ),
    );
  }
}
