import 'dart:async';
import 'dart:ui' show AppExitResponse;
import 'package:flutter/material.dart';
import '../controllers/engine_controller.dart';
import 'activity_view.dart';
import 'configuration_view.dart';
import 'overview_view.dart';

class EngineDashboard extends StatefulWidget {
  const EngineDashboard({super.key, required this.controller});
  final EngineController controller;
  @override
  State<EngineDashboard> createState() => _EngineDashboardState();
}

class _EngineDashboardState extends State<EngineDashboard> {
  int _page = 0;
  late final AppLifecycleListener _lifecycle;
  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.initialize());
    _lifecycle = AppLifecycleListener(
      onExitRequested: () async {
        try {
          await widget.controller.close();
          return AppExitResponse.exit;
        } catch (_) {
          return AppExitResponse.cancel;
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final c = widget.controller;
      final wide = MediaQuery.sizeOf(context).width >= 950;
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                extended: wide,
                minExtendedWidth: 220,
                backgroundColor: const Color(0xff101a28),
                selectedIndex: _page,
                onDestinationSelected: (index) => setState(() => _page = index),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.multitrack_audio,
                        size: 32,
                        color: Color(0xff57d5be),
                      ),
                      if (wide)
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Text(
                            'utrack',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.space_dashboard_outlined),
                    selectedIcon: Icon(Icons.space_dashboard),
                    label: Text('Resumen'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.tune),
                    label: Text('Configuración'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.terminal),
                    label: Text('Actividad'),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 22,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  [
                                    'Centro de audio',
                                    'Configuración del equipo',
                                    'Diagnóstico',
                                  ][_page],
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'UTRACK ENGINE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 2.3,
                                    color: Color(0xff8ca2b9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (c.busy)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.circle,
                            size: 9,
                            color: c.connected
                                ? const Color(0xff57d5be)
                                : Colors.blueGrey,
                          ),
                          const SizedBox(width: 8),
                          if (wide) Text(c.statusLabel),
                          IconButton(
                            tooltip: 'Actualizar configuración y drivers',
                            onPressed: !c.busy && !c.running && !c.dirty
                                ? c.refresh
                                : null,
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                    if (c.error.isNotEmpty || c.externalRunning)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(28, 0, 28, 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff382b20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SelectableText(
                          c.error.isNotEmpty
                              ? c.error
                              : 'Ya hay un Engine abierto fuera de esta aplicación. Ciérralo y pulsa Actualizar para administrarlo aquí.',
                          style: const TextStyle(color: Color(0xffffd6a5)),
                        ),
                      ),
                    Expanded(
                      child: IndexedStack(
                        index: _page,
                        children:
                            <Widget>[
                                  OverviewView(
                                    controller: c,
                                    onConfigure: () =>
                                        setState(() => _page = 1),
                                  ),
                                  ConfigurationView(controller: c),
                                  ActivityView(controller: c),
                                ]
                                .map(
                                  (page) => SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(
                                      28,
                                      0,
                                      28,
                                      28,
                                    ),
                                    child: page,
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
