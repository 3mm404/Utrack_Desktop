import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Keep overlay anchors separate when a scrollable merges row semantics.
/// Flutter's Windows bridge cannot recover from an orphaned overlay node.
class AccessibleTooltip extends StatelessWidget {
  const AccessibleTooltip({
    super.key,
    required this.message,
    required this.child,
  });
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: Tooltip(message: message, child: child),
  );
}

class AccessibleIconButton extends StatelessWidget {
  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.style,
    this.isSelected,
    this.selectedIcon,
  });
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final ButtonStyle? style;
  final bool? isSelected;
  final Widget? selectedIcon;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: IconButton(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip,
      style: style,
      isSelected: isSelected,
      selectedIcon: selectedIcon,
    ),
  );
}

class AccessibleSlider extends StatelessWidget {
  const AccessibleSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.semanticFormatterCallback,
    this.onChangeEnd,
  });
  final double value, min, max;
  final int? divisions;
  final String? label;
  final SemanticFormatterCallback? semanticFormatterCallback;
  final ValueChanged<double>? onChanged, onChangeEnd;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: defaultTargetPlatform == TargetPlatform.windows
        ? _WindowsSlider(control: this)
        : Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: label,
            semanticFormatterCallback: semanticFormatterCallback,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
  );
}

/// Material Slider creates an OverlayPortal even without a value indicator.
/// Keep the Windows control in one semantics subtree until Flutter fixes that path.
class _WindowsSlider extends StatefulWidget {
  const _WindowsSlider({required this.control});
  final AccessibleSlider control;
  @override
  State<_WindowsSlider> createState() => _WindowsSliderState();
}

class _WindowsSliderState extends State<_WindowsSlider> {
  final _focus = FocusNode();
  double? _draft;
  bool _focused = false;
  AccessibleSlider get control => widget.control;
  bool get enabled => control.onChanged != null;
  double get value => (_draft ?? control.value).clamp(control.min, control.max);
  double get step => (control.max - control.min) / (control.divisions ?? 100);
  String describe(double next) =>
      control.semanticFormatterCallback?.call(next) ??
      '${((next - control.min) / (control.max - control.min) * 100).round()}%';

  double normalize(double next) {
    var result = next.clamp(control.min, control.max).toDouble();
    if (control.divisions case final divisions?) {
      final unit = (control.max - control.min) / divisions;
      result = control.min + ((result - control.min) / unit).round() * unit;
    }
    return result;
  }

  void change(double next, {bool complete = false}) {
    if (!enabled) return;
    final result = normalize(next);
    control.onChanged!(result);
    if (complete) control.onChangeEnd?.call(result);
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      slider: true,
      enabled: enabled,
      value: describe(value),
      increasedValue: enabled ? describe(normalize(value + step)) : null,
      decreasedValue: enabled ? describe(normalize(value - step)) : null,
      onIncrease: enabled ? () => change(value + step, complete: true) : null,
      onDecrease: enabled ? () => change(value - step, complete: true) : null,
      child: Focus(
        focusNode: _focus,
        canRequestFocus: enabled,
        onFocusChange: (focused) => setState(() => _focused = focused),
        onKeyEvent: (_, event) {
          if (!enabled ||
              (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
            return KeyEventResult.ignored;
          }
          final direction = Directionality.of(context) == TextDirection.rtl
              ? -1
              : 1;
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowRight ||
              key == LogicalKeyboardKey.arrowLeft) {
            change(
              value +
                  step *
                      direction *
                      (key == LogicalKeyboardKey.arrowRight ? 1 : -1),
              complete: true,
            );
          } else if (key == LogicalKeyboardKey.arrowUp ||
              key == LogicalKeyboardKey.arrowDown) {
            change(
              value + step * (key == LogicalKeyboardKey.arrowUp ? 1 : -1),
              complete: true,
            );
          } else if (key == LogicalKeyboardKey.home ||
              key == LogicalKeyboardKey.end) {
            change(
              key == LogicalKeyboardKey.home ? control.min : control.max,
              complete: true,
            );
          } else {
            return KeyEventResult.ignored;
          }
          return KeyEventResult.handled;
        },
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final rtl = Directionality.of(context) == TextDirection.rtl;
              double at(double x) {
                var fraction =
                    ((x - 16) / (width - 32).clamp(1, double.infinity)).clamp(
                      0.0,
                      1.0,
                    );
                if (rtl) fraction = 1 - fraction;
                return normalize(
                  control.min + fraction * (control.max - control.min),
                );
              }

              void drag(double x) {
                _focus.requestFocus();
                final next = at(x);
                setState(() => _draft = next);
                change(next);
              }

              final fraction =
                  (value - control.min) / (control.max - control.min);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onTapDown: enabled
                    ? (details) {
                        _focus.requestFocus();
                        change(at(details.localPosition.dx), complete: true);
                      }
                    : null,
                onHorizontalDragStart: enabled
                    ? (details) => drag(details.localPosition.dx)
                    : null,
                onHorizontalDragUpdate: enabled
                    ? (details) => drag(details.localPosition.dx)
                    : null,
                onHorizontalDragEnd: enabled
                    ? (_) {
                        final next = value;
                        setState(() => _draft = null);
                        control.onChangeEnd?.call(next);
                      }
                    : null,
                onHorizontalDragCancel: () => setState(() => _draft = null),
                child: SizedBox(
                  height: 44,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.onSurface.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Align(
                          alignment: rtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: fraction,
                            child: Container(
                              height: 4,
                              color: enabled
                                  ? colors.primary
                                  : colors.onSurface.withValues(alpha: .25),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment(
                            (rtl ? 1 - fraction : fraction) * 2 - 1,
                            0,
                          ),
                          child: Container(
                            width: _focused ? 22 : 18,
                            height: _focused ? 22 : 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: enabled
                                  ? colors.primary
                                  : colors.onSurface.withValues(alpha: .35),
                              border: _focused
                                  ? Border.all(
                                      color: colors.onSurface,
                                      width: 2,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AccessiblePopupMenuButton<T> extends StatelessWidget {
  const AccessiblePopupMenuButton({
    super.key,
    required this.itemBuilder,
    this.tooltip,
    this.icon,
    this.initialValue,
    this.onSelected,
    this.enabled = true,
  });
  final PopupMenuItemBuilder<T> itemBuilder;
  final String? tooltip;
  final Widget? icon;
  final T? initialValue;
  final PopupMenuItemSelected<T>? onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: PopupMenuButton<T>(
      itemBuilder: itemBuilder,
      tooltip: tooltip,
      icon: icon,
      initialValue: initialValue,
      onSelected: onSelected,
      enabled: enabled,
    ),
  );
}
