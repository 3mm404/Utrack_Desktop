import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import '../design/ui_palette.dart';

class ConfigurationRow extends StatelessWidget {
  const ConfigurationRow({
    super.key,
    required this.label,
    required this.control,
    this.description,
  });
  final String label;
  final String? description;
  final Widget control;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: UiSpace.md),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: UiText.of(context).body),
            if (description != null) ...[
              const SizedBox(height: UiSpace.xs),
              Text(description!, style: UiText.of(context).caption),
            ],
          ],
        );
        if (constraints.maxWidth < 480) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              text,
              const SizedBox(height: UiSpace.md),
              control,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: text),
            const SizedBox(width: UiSpace.xl),
            Expanded(child: control),
          ],
        );
      },
    ),
  );
}
