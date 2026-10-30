import 'package:flutter/material.dart';

import '../design/ui_tokens.dart';
import '../design/ui_palette.dart';
import '../widgets/section_card.dart';
import '../widgets/zone_cards.dart';
import '../widgets/home_overview.dart';
import '../widgets/player_bar.dart';
import '../widgets/audio_output_panel.dart';
import '../widgets/engine_status_panel.dart';
import '../widgets/assigned_playlist_panel.dart';
import '../widgets/app_surface.dart';
import '../widgets/audio_state_builder.dart';

import '../state/zone_preview_state.dart';
import 'utrack_header.dart';

/// Shared shell with an explicitly injected production or preview state.
class UtrackShell extends StatefulWidget {
  const UtrackShell({
    super.key,
    required this.status,
    required this.connected,
    required this.settings,
    this.testMode = true,
    this.state,
  });
  final AudioViewState? state;
  final bool testMode;
  final String status;
  final bool connected;
  final Widget settings;
  @override
  State<UtrackShell> createState() => _UtrackShellState();
}

class _UtrackShellState extends State<UtrackShell> {
  late final AudioViewState _zoneState;
  @override
  void initState() {
    super.initState();
    if (widget.state == null && !widget.testMode) {
      throw StateError('Producción requiere un estado conectado al motor.');
    }
    _zoneState = widget.state ?? ZonePreviewState();
    if (_zoneState.needsConfiguration) _selected = 4;
  }

  @override
  void dispose() {
    if (widget.state == null) _zoneState.dispose();
    super.dispose();
  }

  int _selected = 0;

  List<Object?> _contentValues() => [
    _zoneState.configurationRevision,
    _zoneState.selectedIndex,
    _zoneState.fresh,
    _zoneState.engineRunning,
    _zoneState.busy,
    _zoneState.error,
    _zoneState.playbackPending,
    _zoneState.volumePending,
    _zoneState.canSetVolume,
    _zoneState.canSetSongPreference,
    _zoneState.canPlayPlaylist,
    if (_selected == 2) _zoneState.playlists,
    if (_selected == 3) ...[
      _zoneState.cpu,
      _zoneState.heapBytes,
      _zoneState.uptimeSeconds,
    ],
    for (final zone in _zoneState.zones) ...[
      zone.id,
      zone.name,
      zone.source,
      zone.volume,
      zone.playing,
      zone.observedState,
      zone.failure,
      zone.songId,
      zone.song,
      zone.coverPath,
      zone.backgroundPath,
      zone.playlistId,
      zone.shuffle,
      zone.repeatMode,
      zone.continuousPlayback,
      zone.channels,
      zone.songPreferences.toString(),
      Object.hashAll(
        zone.songMetadata.entries.map(
          (entry) => Object.hash(
            entry.key,
            entry.value.title,
            entry.value.artist,
            entry.value.coverPath,
          ),
        ),
      ),
    ],
  ];
  void _select(int index) => setState(() => _selected = index);
  Widget _placeholder(String title, String detail, {double height = 200}) =>
      SectionCard(
        title: title,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Center(
            child: Text(
              detail,
              textAlign: TextAlign.center,
              style: UiText.of(context).caption,
            ),
          ),
        ),
      );

  Widget _home(double width, double height) => ZoneCards(
    state: _zoneState,
    onLibrary: () => _select(2),
    onConfigure: () => _select(4),
    showOverview: _selected == 0,
  );

  Widget _enginePanel({bool compact = false}) => EngineStatusPanel(
    compact: compact,
    running: _zoneState.engineRunning,
    simulated: _zoneState.isSimulated,
    statusLabel: _zoneState.status,
    activeZones: _zoneState.activeZones,
    totalZones: _zoneState.zones.length,
    cpu: _zoneState.cpu,
    latencyMs: _zoneState.latencyMs,
    onToggleEngine: _zoneState.canToggleEngine ? _zoneState.toggleEngine : null,
  );

  Widget _devices(double width) => Column(
    children: [
      HomeOverview(state: _zoneState),
      const SizedBox(height: 20),
      _deviceDetails(width),
    ],
  );

  Widget _deviceDetails(double width) {
    if (width >= 900) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AudioOutputPanel(
              state: _zoneState,
              onConfigure: () => _select(4),
            ),
          ),
          SizedBox(width: UiSpace.xl),
          Expanded(child: _enginePanel()),
        ],
      );
    }
    return Column(
      children: [
        AudioOutputPanel(state: _zoneState, onConfigure: () => _select(4)),
        SizedBox(height: UiSpace.lg),
        _enginePanel(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      return Scaffold(
        body: SafeArea(
          child: AppFrame(
            child: AppSurface(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        if (widget.testMode)
                          Container(
                            width: double.infinity,
                            color: UiPalette.of(context).elevated,
                            padding: const EdgeInsets.all(UiSpace.sm),
                            child: Text(
                              'MODO TEST · Datos simulados, sin audio real',
                              style: UiText.of(context).caption,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        AudioStateBuilder(
                          listenable: _zoneState,
                          select: () => [
                            _zoneState.status,
                            _zoneState.connected,
                          ],
                          builder: (context) => UtrackHeader(
                            selected: _selected,
                            onSelected: _select,
                            title: shellLabels[_selected],
                            status: _zoneState.status,
                            connected: _zoneState.connected,
                          ),
                        ),
                        ListenableBuilder(
                          listenable: _zoneState,
                          builder: (context, _) => _zoneState.error.isEmpty
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: UiSpace.lg,
                                  ),
                                  child: Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      _zoneState.error,
                                      style: UiText.of(context).body.copyWith(
                                        color: UiPalette.of(context).error,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: AudioStateBuilder(
                            listenable: _zoneState,
                            select: _contentValues,
                            builder: (context) => LayoutBuilder(
                              builder: (context, content) =>
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.all(UiSpace.lg),
                                    child: _selected == 0
                                        ? _home(
                                            content.maxWidth,
                                            content.maxHeight,
                                          )
                                        : _selected == 1
                                        ? _home(
                                            content.maxWidth,
                                            content.maxHeight,
                                          )
                                        : _selected == 3
                                        ? _devices(content.maxWidth)
                                        : _selected == 4
                                        ? widget.settings
                                        : _selected == 2 &&
                                              !_zoneState.isSimulated
                                        ? AssignedPlaylistPanel(
                                            state: _zoneState,
                                          )
                                        : _placeholder(
                                            shellLabels[_selected],
                                            'Sección pendiente de desarrollo en próximas etapas.',
                                          ),
                                  ),
                            ),
                          ),
                        ),
                        PlayerBar(state: _zoneState),
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
  );
}
