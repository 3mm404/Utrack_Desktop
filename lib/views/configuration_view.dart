import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/engine_controller.dart';
import '../models/engine_settings.dart';
import 'widgets/section_card.dart';

class ConfigurationView extends StatefulWidget {
  const ConfigurationView({super.key, required this.controller});
  final EngineController controller;
  @override
  State<ConfigurationView> createState() => _ConfigurationViewState();
}

class _ConfigurationViewState extends State<ConfigurationView> {
  final _form = GlobalKey<FormState>();
  final _server = TextEditingController();
  final _token = TextEditingController();
  final _driver = TextEditingController();
  final _rate = TextEditingController();
  final _buffer = TextEditingController();
  final _channels = TextEditingController();
  String _backend = 'oto', _mode = 'stereo';
  bool _showToken = false;
  EngineSettings? _loaded;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ConfigurationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(_loaded, widget.controller.settings) &&
        !widget.controller.dirty) {
      _load();
    }
  }

  void _load() {
    final settings = widget.controller.settings;
    _loaded = settings;
    _server.text = settings.server;
    _driver.text = settings.driver;
    _rate.text = '${settings.sampleRate}';
    _buffer.text = '${settings.bufferSize}';
    _channels.text = '${settings.channels}';
    _backend = settings.backend;
    _mode = settings.mode;
  }

  @override
  void dispose() {
    for (final controller in [
      _server,
      _token,
      _driver,
      _rate,
      _buffer,
      _channels,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final saved = await widget.controller.save(
      EngineSettings(
        server: _server.text,
        backend: _backend,
        mode: _mode,
        driver: _driver.text,
        sampleRate: int.tryParse(_rate.text) ?? 48000,
        bufferSize: int.tryParse(_buffer.text) ?? 256,
        channels: int.tryParse(_channels.text) ?? 0,
      ),
      _token.text,
    );
    if (saved && mounted) {
      _token.clear();
      setState(_load);
    }
  }

  Widget _number(
    TextEditingController controller,
    String label,
    int min,
    int max,
  ) => TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    onChanged: (_) => widget.controller.markDirty(),
    validator: (value) {
      final n = int.tryParse(value ?? '');
      return n == null || n < min || n > max ? 'Rango: $min–$max' : null;
    },
  );

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c.running || c.externalRunning)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('Detén el motor antes de cambiar la configuración.'),
            ),
          AbsorbPointer(
            absorbing: !c.canConfigure,
            child: Opacity(
              opacity: c.canConfigure ? 1 : .6,
              child: Column(
                children: [
                  SectionCard(
                    title: 'Conecta tu equipo',
                    subtitle:
                        'Usa el dominio de tu servidor y el token del equipo creado en Laravel.',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _server,
                          decoration: const InputDecoration(
                            labelText: 'Servidor HTTPS',
                            hintText: 'https://musica.tudominio.com',
                            prefixIcon: Icon(Icons.link),
                          ),
                          onChanged: (_) => c.markDirty(),
                          validator: (value) =>
                              EngineSettings(server: value ?? '').validate(),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _token,
                          obscureText: !_showToken,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            labelText: c.configured
                                ? 'Nuevo token (opcional)'
                                : 'Token del equipo',
                            helperText: c.configured
                                ? 'Déjalo vacío para conservar la credencial guardada.'
                                : 'Se guardará cifrado para este usuario de Windows.',
                            prefixIcon: const Icon(Icons.key),
                            suffixIcon: IconButton(
                              tooltip: 'Mostrar u ocultar token',
                              onPressed: () =>
                                  setState(() => _showToken = !_showToken),
                              icon: Icon(
                                _showToken
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          onChanged: (_) => c.markDirty(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionCard(
                    title: 'Salida de audio',
                    subtitle:
                        'Selecciona cómo se reproducirá el audio en esta PC.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ChoiceChip(
                              label: const Text(
                                'Windows · salida predeterminada',
                              ),
                              selected: _backend == 'oto',
                              avatar: const Icon(Icons.speaker, size: 18),
                              onSelected: (_) {
                                setState(() => _backend = 'oto');
                                c.markDirty();
                              },
                            ),
                            ChoiceChip(
                              label: const Text(
                                'ASIO · canales independientes',
                              ),
                              selected: _backend == 'asio',
                              avatar: const Icon(
                                Icons.settings_input_component,
                                size: 18,
                              ),
                              onSelected: (_) {
                                setState(() => _backend = 'asio');
                                c.markDirty();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _backend == 'oto'
                              ? 'Todas las zonas se escuchan en la misma salida de Windows. Las rutas de Laravel deben ser compartidas: 1–2 en estéreo o 1 en mono.'
                              : 'Cada zona usa los canales asignados en Laravel. El driver debe estar instalado y admitir la frecuencia y el buffer seleccionados.',
                          style: const TextStyle(
                            height: 1.5,
                            color: Color(0xffa9b9ca),
                          ),
                        ),
                        const SizedBox(height: 22),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _mode,
                          key: ValueKey('mode-$_mode'),
                          decoration: const InputDecoration(
                            labelText: 'Modo de reproducción',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'stereo',
                              child: Text(
                                'Estéreo · conserva izquierda y derecha',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'mono',
                              child: Text('Mono · mezcla ambos canales'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _mode = value!);
                            c.markDirty();
                          },
                        ),
                        if (_backend == 'asio') ...[
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _driver,
                            decoration: const InputDecoration(
                              labelText: 'Nombre exacto del driver ASIO',
                              hintText: 'Dante Virtual Soundcard (x64)',
                            ),
                            onChanged: (_) => c.markDirty(),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Selecciona o escribe el driver.'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          if (c.drivers.isEmpty)
                            const Text(
                              'No se detectaron drivers ASIO x64. Instala el driver y pulsa Actualizar.',
                              style: TextStyle(color: Colors.amber),
                            ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: c.drivers
                                .map(
                                  (driver) => ActionChip(
                                    label: Text(driver),
                                    onPressed: () {
                                      _driver.text = driver;
                                      c.markDirty();
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                          if (c.driverWarning.isNotEmpty) Text(c.driverWarning),
                          const SizedBox(height: 18),
                          LayoutBuilder(
                            builder: (context, constraints) => Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: constraints.maxWidth < 500
                                      ? constraints.maxWidth
                                      : (constraints.maxWidth - 32) / 3,
                                  child: _number(
                                    _rate,
                                    'Frecuencia (Hz)',
                                    8000,
                                    384000,
                                  ),
                                ),
                                SizedBox(
                                  width: constraints.maxWidth < 500
                                      ? constraints.maxWidth
                                      : (constraints.maxWidth - 32) / 3,
                                  child: _number(
                                    _buffer,
                                    'Buffer (frames)',
                                    1,
                                    65536,
                                  ),
                                ),
                                SizedBox(
                                  width: constraints.maxWidth < 500
                                      ? constraints.maxWidth
                                      : (constraints.maxWidth - 32) / 3,
                                  child: _number(
                                    _channels,
                                    'Canales · 0 = auto',
                                    0,
                                    64,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: c.canConfigure ? _save : null,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar configuración'),
              ),
              if (c.dirty)
                const Text(
                  'Cambios sin guardar',
                  style: TextStyle(color: Colors.amber),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
