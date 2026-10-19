import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';

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
      UiStatus.inactive => UiColors.muted,
      UiStatus.operational => UiColors.operational,
      UiStatus.warning => UiColors.warning,
      UiStatus.error => UiColors.error,
    };
    return Semantics(
      label: label,
      child: Tooltip(
        message: label,
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: UiSpace.sm, color: color),
              if (showLabel) ...[
                const SizedBox(width: UiSpace.sm),
                Flexible(child: Text(label, style: UiType.caption)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
