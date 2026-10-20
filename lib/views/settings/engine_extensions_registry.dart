import 'package:flutter/material.dart';
import '../../controllers/engine_controller.dart';
import '../../integrations/engine_api/engine_api_catalog.dart';
import '../widgets/section_card.dart';

/// Register future settings panels here, rather than growing EngineDashboard.
/// Panels receive the controller, never credentials or direct process access.
class EngineSettingsExtension {
  const EngineSettingsExtension({
    required this.id,
    required this.builder,
    this.requiredCapability,
  });
  final String id;
  final String? requiredCapability;
  final Widget Function(EngineController controller) builder;
}

final engineSettingsExtensions = <EngineSettingsExtension>[
  EngineSettingsExtension(
    id: 'engine_features',
    builder: (controller) => _EngineFeatures(controller: controller),
  ),
  // Add a real settings widget and its capability here when its API exists.
];

class EngineExtensionsView extends StatelessWidget {
  const EngineExtensionsView({super.key, required this.controller});
  final EngineController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Column(
      children: [
        for (final extension in engineSettingsExtensions)
          if (extension.requiredCapability == null ||
              controller.capabilities.contains(extension.requiredCapability))
            Padding(
              key: ValueKey(extension.id),
              padding: const EdgeInsets.only(bottom: 24),
              child: extension.builder(controller),
            ),
      ],
    ),
  );
}

class _EngineFeatures extends StatelessWidget {
  const _EngineFeatures({required this.controller});
  final EngineController controller;
  @override
  Widget build(BuildContext context) {
    final labels = [
      for (final operation in EngineOperation.values)
        if (controller.capabilities.contains(operation.wireName))
          operation.label,
      for (final entry in EngineReadCapabilities.labels.entries)
        if (controller.capabilities.contains(entry.key)) entry.value,
    ];
    return SectionCard(
      title: 'Funciones y ajustes adicionales',
      subtitle: 'Funciones admitidas por el motor instalado',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Versión del motor: ${controller.version}'),
          const SizedBox(height: 12),
          if (labels.isEmpty)
            const Text('No se han recibido capacidades adicionales del motor.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final label in labels) Chip(label: Text(label))],
            ),
          const SizedBox(height: 12),
          const Text(
            'Los ajustes adicionales aparecerán cuando el motor instalado los admita.',
          ),
        ],
      ),
    );
  }
}
