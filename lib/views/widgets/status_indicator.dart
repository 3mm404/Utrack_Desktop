import 'accessible_controls.dart';
import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import '../design/ui_palette.dart';

enum UiStatus { inactive, operational, warning, error }

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({
    super.key,
    required this.label,
    required this.status,
    this.showLabel = true,
  });
  final String label;
  final UiStatus status;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      UiStatus.inactive => UiPalette.of(context).muted,
      UiStatus.operational => UiPalette.of(context).operational,
      UiStatus.warning => UiPalette.of(context).warning,
      UiStatus.error => UiPalette.of(context).error,
    };
    return Semantics(
      label: label,
      child: AccessibleTooltip(
        message: label,
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: UiSpace.sm, color: color),
              if (showLabel) ...[
                const SizedBox(width: UiSpace.sm),
                Flexible(child: Text(label, style: UiText.of(context).caption)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
