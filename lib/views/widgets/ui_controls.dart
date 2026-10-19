import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';

/// Standard keyboard-focusable icon action. A null callback disables the control.
class UiIconControl extends StatelessWidget {
  const UiIconControl({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.circular = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool selected, circular;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label,
    onPressed: onPressed,
    isSelected: selected,
    icon: Icon(icon),
    selectedIcon: Icon(icon, color: UiColors.accent),
    style: IconButton.styleFrom(
      foregroundColor: UiColors.muted,
      disabledForegroundColor: UiColors.muted.withValues(alpha: 0.38),
      backgroundColor: selected ? UiColors.elevated : Colors.transparent,
      side: circular ? UiEffects.border : BorderSide.none,
      shape: circular
          ? const CircleBorder()
          : const RoundedRectangleBorder(borderRadius: UiRadii.control),
    ),
  );
}

class CircularControl extends StatelessWidget {
  const CircularControl({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) => UiIconControl(
    icon: icon,
    label: label,
    onPressed: onPressed,
    selected: selected,
    circular: true,
  );
}

/// Controlled value: callers own state and decide whether changes are persisted.
class UiSlider extends StatelessWidget {
  const UiSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.unit = '%',
    this.onChangeEnd,
  }) : assert(min < max),
       assert(divisions == null || divisions > 0);
  final String label, unit;
  final double value, min, max;
  final int? divisions;
  final ValueChanged<double>? onChanged, onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final displayed = value.clamp(min, max).toDouble();
    final valueLabel = '${displayed.round()}$unit';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: UiType.body)),
            const SizedBox(width: UiSpace.sm),
            Text(valueLabel, style: UiType.caption),
          ],
        ),
        Semantics(
          label: label,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: UiColors.accent,
              inactiveTrackColor: UiColors.border,
              thumbColor: UiColors.accent,
              overlayColor: UiColors.accent.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: displayed,
              min: min,
              max: max,
              divisions: divisions,
              label: valueLabel,
              semanticFormatterCallback: (v) => '${v.round()}$unit',
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ),
      ],
    );
  }
}
