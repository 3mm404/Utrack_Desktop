import 'package:flutter/material.dart';
import '../../controllers/engine_controller.dart';
import 'section_card.dart';

class ZoneConsole extends StatefulWidget {
  const ZoneConsole({
    super.key,
    required this.controller,
    required this.onConfigure,
  });
  final EngineController controller;
  final VoidCallback onConfigure;
  @override
  State<ZoneConsole> createState() => _ZoneConsoleState();
}

class _ZoneConsoleState extends State<ZoneConsole> {
  String? selectedId;
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final zone =
        c.zones.where((z) => z.id == selectedId).firstOrNull ??
        c.zones.firstOrNull;
    final current = c.running && c.fresh;
    final selection = SectionCard(
      title: 'Zona seleccionada',
      trailing: const Icon(Icons.speaker_outlined, color: Color(0xffd14f20)),
      child: zone == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('Esperando zonas del motor.'),
            )
          : Column(
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey(zone.id),
                  initialValue: zone.id,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Zona'),
                  items: c.zones
                      .map(
                        (z) =>
                            DropdownMenuItem(value: z.id, child: Text(z.name)),
                      )
                      .toList(),
                  onChanged: (id) => setState(() => selectedId = id),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: zone.volume.clamp(0, 100) / 100,
                          strokeWidth: 6,
                          color: const Color(0xffd14f20),
                          backgroundColor: const Color(0xff30353b),
                        ),
                      ),
                      Container(
                        width: 128,
                        height: 128,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xff66676a)),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xff3a3d42), Color(0xff101216)],
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, blurRadius: 12),
                          ],
                        ),
                        child: Text(
                          '${zone.volume}%',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Volumen observado',
                  style: TextStyle(color: Color(0xffb4bac5)),
                ),
                const Divider(height: 30),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.queue_music),
                  title: const Text('Fuente'),
                  subtitle: Text(
                    zone.playlist.isEmpty ? 'Sin playlist' : zone.playlist,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.settings_input_component),
                  title: const Text('Canales'),
                  subtitle: Text(
                    c.settings.backend == 'oto'
                        ? 'Salida compartida'
                        : zone.channels.join(' · '),
                  ),
                ),
                if (!current)
                  const Text(
                    'Datos anteriores · sin estado actual',
                    style: TextStyle(color: Colors.amber),
                  ),
              ],
            ),
    );
    final output = SectionCard(
      title: 'Salida de audio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.speaker_group_outlined,
            size: 64,
            color: Color(0xffd14f20),
          ),
          const SizedBox(height: 20),
          Text(
            '${c.settings.backend == 'asio' ? 'ASIO' : 'Windows Audio'} · ${c.settings.mode}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: widget.onConfigure,
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Cambiar salida'),
          ),
          const Divider(height: 36),
          const Text('Estado general', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 18),
          Text('Motor: ${c.statusLabel}'),
          const SizedBox(height: 12),
          Text('Zonas recibidas: ${c.zones.length}'),
          const SizedBox(height: 12),
          Text(
            current ? 'Estado actualizado' : 'Esperando estado del motor',
            style: const TextStyle(color: Color(0xffb4bac5)),
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, size) => size.maxWidth >= 700
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: selection),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: output),
              ],
            )
          : Column(children: [selection, const SizedBox(height: 20), output]),
    );
  }
}
