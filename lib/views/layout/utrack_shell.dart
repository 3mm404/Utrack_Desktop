import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import '../design/ui_palette.dart';
import '../widgets/section_card.dart';
import '../widgets/zone_map.dart';
import '../widgets/player_bar.dart';
import '../widgets/audio_output_panel.dart';
import '../widgets/engine_status_panel.dart';
import '../widgets/selected_zone_panel.dart';
import '../widgets/assigned_playlist_panel.dart';
import '../state/zone_preview_state.dart';
import 'utrack_header.dart';
import 'utrack_sidebar.dart';

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

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selected = 0;
  void _select(int index) => setState(() => _selected = index);
  void _search(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return;
    final index = shellLabels.indexWhere(
      (label) => label.toLowerCase().contains(value),
    );
    if (index >= 0) {
      _select(index);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró esa sección.')),
      );
    }
  }

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

  Widget _home(double width, double height) {
    final plan = ZoneMap(
      state: _zoneState,
      showControls: false,
      maxSceneWidth: width >= 1000
          ? (height - 120).clamp(300, 580).toDouble()
          : 580,
    );
    final selected = SelectedZonePanel(state: _zoneState, compact: true);
    final devices = Column(
      children: [
        AudioOutputPanel(
          state: _zoneState,
          compact: true,
          onConfigure: () => _select(4),
        ),
        const SizedBox(height: UiSpace.lg),
        _enginePanel(compact: true),
      ],
    );
    if (width >= 1000) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: plan),
          const SizedBox(width: UiSpace.lg),
          SizedBox(width: width >= 1400 ? 350 : 280, child: selected),
          const SizedBox(width: UiSpace.lg),
          SizedBox(width: width >= 1400 ? 270 : 240, child: devices),
        ],
      );
    }
    if (width >= 900) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: plan),
              const SizedBox(width: UiSpace.lg),
              SizedBox(width: 300, child: selected),
            ],
          ),
          const SizedBox(height: UiSpace.lg),
          _devices(width),
        ],
      );
    }
    return Column(
      children: [
        plan,
        const SizedBox(height: UiSpace.lg),
        selected,
        const SizedBox(height: UiSpace.lg),
        devices,
      ],
    );
  }

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

  Widget _devices(double width) {
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
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _zoneState,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: Drawer(
            width: 276,
            backgroundColor: UiPalette.of(context).surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Navegación',
                            style: UiText.of(context).title,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cerrar navegación',
                          onPressed: () =>
                              _scaffoldKey.currentState?.closeEndDrawer(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: UtrackSidebar(
                      selected: _selected,
                      onSelected: (index) {
                        _select(index);
                        _scaffoldKey.currentState?.closeEndDrawer();
                      },
                      status: _zoneState.status,
                      connected: _zoneState.connected,
                      expanded: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          drawerScrimColor: UiPalette.of(
            context,
          ).background.withValues(alpha: .42),
          body: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: UiPalette.of(context).elevated,
                        padding: const EdgeInsets.all(UiSpace.sm),
                        child: Text(
                          widget.testMode
                              ? 'MODO TEST · Datos simulados, sin audio real'
                              : 'MOTOR LOCAL · Zonas reales y reproducción desde Desktop.',
                          style: UiText.of(context).caption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      UtrackHeader(
                        title: shellLabels[_selected],
                        status: _zoneState.status,
                        connected: _zoneState.connected,
                        onSettings: () =>
                            _scaffoldKey.currentState?.openEndDrawer(),
                        onSearch: _search,
                      ),
                      if (_zoneState.error.isNotEmpty)
                        Padding(
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
                      if (!_zoneState.isSimulated && !_zoneState.busy)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UiSpace.lg,
                          ),
                          child: Wrap(
                            spacing: UiSpace.md,
                            children: [
                              FilledButton.icon(
                                onPressed: _zoneState.canToggleEngine
                                    ? _zoneState.toggleEngine
                                    : null,
                                icon: Icon(
                                  _zoneState.engineRunning
                                      ? Icons.stop
                                      : Icons.play_arrow,
                                ),
                                label: Text(
                                  _zoneState.engineRunning
                                      ? 'Detener motor'
                                      : 'Iniciar motor',
                                ),
                              ),
                              IconButton(
                                tooltip: 'Actualizar estado local',
                                onPressed: _zoneState.refreshAction,
                                icon: const Icon(Icons.refresh),
                              ),
                              TextButton.icon(
                                onPressed: () => _select(4),
                                icon: const Icon(Icons.settings),
                                label: const Text(
                                  'Configurar servidor y salida',
                                ),
                              ),
                              if (!_zoneState.fresh && _zoneState.hasSelection)
                                Text(
                                  'Último estado recibido · sin actualización',
                                  style: UiText.of(context).caption,
                                ),
                            ],
                          ),
                        ),
                      const Divider(height: 1),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, content) => SingleChildScrollView(
                            padding: const EdgeInsets.all(UiSpace.lg),
                            child: _selected == 0
                                ? _home(content.maxWidth, content.maxHeight)
                                : _selected == 1
                                ? _home(content.maxWidth, content.maxHeight)
                                : _selected == 3
                                ? _devices(content.maxWidth)
                                : _selected == 4
                                ? widget.settings
                                : _selected == 2 && !_zoneState.isSimulated
                                ? AssignedPlaylistPanel(state: _zoneState)
                                : _placeholder(
                                    shellLabels[_selected],
                                    'Sección pendiente de desarrollo en próximas etapas.',
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
        );
      },
    ),
  );
}
