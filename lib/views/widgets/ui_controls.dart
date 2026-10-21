import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';
import '../design/ui_palette.dart';

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
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      shape: circular ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circular ? null : UiRadii.control,
      gradient: circular || selected ? UiDecor.of(context).panelGradient : null,
      boxShadow: (circular || selected) && onPressed != null
          ? UiDecor.of(context).controlShadow
          : null,
    ),
    child: IconButton(
      tooltip: label,
      onPressed: onPressed,
      isSelected: selected,
      icon: Icon(icon),
      selectedIcon: Icon(icon, color: UiPalette.of(context).accent),
      style: IconButton.styleFrom(
        foregroundColor: UiPalette.of(context).muted,
        disabledForegroundColor: UiPalette.of(
          context,
        ).muted.withValues(alpha: 0.38),
        backgroundColor: selected
            ? UiPalette.of(context).elevated
            : Colors.transparent,
        side: circular ? UiDecor.of(context).border : BorderSide.none,
        shape: circular
            ? const CircleBorder()
            : const RoundedRectangleBorder(borderRadius: UiRadii.control),
      ),
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
            Expanded(child: Text(label, style: UiText.of(context).body)),
            const SizedBox(width: UiSpace.sm),
            Text(valueLabel, style: UiText.of(context).caption),
          ],
        ),
        Semantics(
          label: label,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: UiPalette.of(context).accent,
              inactiveTrackColor: UiPalette.of(context).border,
              thumbColor: UiPalette.of(context).accent,
              overlayColor: UiPalette.of(
                context,
              ).accent.withValues(alpha: 0.12),
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
