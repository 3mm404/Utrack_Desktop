import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import '../widgets/section_card.dart';
import '../widgets/zone_map.dart';
import '../widgets/player_bar.dart';
import '../widgets/audio_output_panel.dart';
import '../widgets/engine_status_panel.dart';
import '../widgets/selected_zone_panel.dart';
import '../state/zone_preview_state.dart';
import 'utrack_header.dart';
import 'utrack_sidebar.dart';

/// Presentation-only shell for the staged test interface.
class UtrackShell extends StatefulWidget {
  const UtrackShell({
    super.key,
    required this.status,
    required this.connected,
    required this.settings,
  });
  final String status;
  final bool connected;
  final Widget settings;
  @override
  State<UtrackShell> createState() => _UtrackShellState();
}

class _UtrackShellState extends State<UtrackShell> {
  final _zoneState = ZonePreviewState();
  @override
  void dispose() {
    _zoneState.dispose();
    super.dispose();
  }

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
              style: UiType.caption,
            ),
          ),
        ),
      );

  Widget _home(double width) {
    final plan = ZoneMap(state: _zoneState, showControls: false);
    final selected = SelectedZonePanel(state: _zoneState, compact: true);
    final devices = Column(
      children: [
        AudioOutputPanel(state: _zoneState, compact: true),
        const SizedBox(height: UiSpace.lg),
        _enginePanel(compact: true),
      ],
    );
    if (width >= 1300) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: plan),
          const SizedBox(width: UiSpace.lg),
          SizedBox(width: 312, child: selected),
          const SizedBox(width: UiSpace.lg),
          SizedBox(width: 280, child: devices),
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
    activeZones: _zoneState.activeZones,
    totalZones: _zoneState.zones.length,
    cpu: _zoneState.cpu,
    latencyMs: _zoneState.latencyMs,
    onToggleEngine: _zoneState.toggleEngine,
  );

  Widget _devices(double width) {
    if (width >= 900) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: AudioOutputPanel(state: _zoneState)),
          SizedBox(width: UiSpace.xl),
          Expanded(child: _enginePanel()),
        ],
      );
    }
    return Column(
      children: [
        AudioOutputPanel(state: _zoneState),
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
        final compact = constraints.maxWidth < 600;
        return Scaffold(
          bottomNavigationBar: compact
              ? NavigationBar(
                  selectedIndex: _selected,
                  onDestinationSelected: _select,
                  destinations: [
                    for (var i = 0; i < shellLabels.length; i++)
                      NavigationDestination(
                        icon: Icon(shellIcons[i]),
                        label: shellLabels[i],
                      ),
                  ],
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!compact)
                  UtrackSidebar(
                    selected: _selected,
                    onSelected: _select,
                    status: _zoneState.status,
                    connected: _zoneState.connected,
                    expanded: constraints.maxWidth >= 1000,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: UiColors.elevated,
                        padding: const EdgeInsets.all(UiSpace.sm),
                        child: const Text(
                          'MODO TEST · Vista de pruebas con datos simulados.',
                          style: UiType.caption,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      UtrackHeader(
                        title: shellLabels[_selected],
                        status: _zoneState.status,
                        connected: _zoneState.connected,
                        onSettings: () => _select(4),
                        onSearch: _search,
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, content) => SingleChildScrollView(
                            padding: const EdgeInsets.all(UiSpace.lg),
                            child: _selected == 0
                                ? _home(content.maxWidth)
                                : _selected == 1
                                ? _home(content.maxWidth)
                                : _selected == 3
                                ? _devices(content.maxWidth)
                                : _selected == 4
                                ? widget.settings
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
