import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/ui_palette.dart';

/// Drag vertically or use arrow keys to adjust a value from 0 to 100.
class VolumeKnob extends StatelessWidget {
  const VolumeKnob({
    super.key,
    required this.value,
    required this.onChanged,
    this.diameter = 208,
    this.showValue = true,
    this.vintage = false,
  });
  final bool showValue;
  final bool vintage;
  final double diameter;
  final double value;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final volume = value.clamp(0, 100).toDouble();
    void change(double next) => onChanged?.call(next.clamp(0, 100).toDouble());
    final lowEffects = MediaQuery.sizeOf(context).width < 700;
    return RepaintBoundary(
      child: Semantics(
        label: 'Volumen de zona',
        value: '${volume.round()}%',
        increasedValue: '${(volume + 1).clamp(0, 100).round()}%',
        decreasedValue: '${(volume - 1).clamp(0, 100).round()}%',
        onIncrease: onChanged == null ? null : () => change(volume + 1),
        onDecrease: onChanged == null ? null : () => change(volume - 1),
        child: FocusableActionDetector(
          enabled: onChanged != null,
          mouseCursor: onChanged == null
              ? SystemMouseCursors.basic
              : SystemMouseCursors.resizeUpDown,
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.arrowUp): _VolumeIntent(1),
            SingleActivator(LogicalKeyboardKey.arrowRight): _VolumeIntent(1),
            SingleActivator(LogicalKeyboardKey.arrowDown): _VolumeIntent(-1),
            SingleActivator(LogicalKeyboardKey.arrowLeft): _VolumeIntent(-1),
          },
          actions: {
            _VolumeIntent: CallbackAction<_VolumeIntent>(
              onInvoke: (intent) {
                change(volume + intent.delta);
                return null;
              },
            ),
          },
          child: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Focus.of(context).requestFocus(),
              onVerticalDragStart: (_) => Focus.of(context).requestFocus(),
              onVerticalDragUpdate: (details) =>
                  change(volume - details.delta.dy / 2),
              child: Tooltip(
                message: onChanged == null
                    ? 'Volumen reportado por el motor · control desde el servidor'
                    : 'Arrastra arriba/abajo o usa las flechas',
                child: SizedBox(
                  width: diameter,
                  height: diameter,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: volume),
                          duration:
                              MediaQuery.disableAnimationsOf(context) ||
                                  lowEffects
                              ? Duration.zero
                              : const Duration(milliseconds: 120),
                          builder: (context, animated, _) => CustomPaint(
                            painter: _VolumeArc(
                              animated,
                              UiPalette.of(context),
                              lowEffects,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: diameter * .77,
                        height: diameter * .77,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: vintage
                              ? const SweepGradient(
                                  colors: [
                                    Color(0xff443b30),
                                    Color(0xffa39880),
                                    Color(0xff292a29),
                                    Color(0xffd7c7a3),
                                    Color(0xff514838),
                                    Color(0xff443b30),
                                  ],
                                )
                              : UiDecor.of(context).metalGradient,
                          border: Border.all(
                            color: Focus.of(context).hasFocus
                                ? UiPalette.of(context).accent
                                : UiPalette.of(context).border,
                            width: 2,
                          ),
                          boxShadow: lowEffects
                              ? null
                              : UiDecor.of(context).controlShadow,
                        ),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            end: (-135 + volume * 2.7) * math.pi / 180,
                          ),
                          duration:
                              MediaQuery.disableAnimationsOf(context) ||
                                  lowEffects
                              ? Duration.zero
                              : const Duration(milliseconds: 120),
                          builder: (context, angle, child) =>
                              Transform.rotate(angle: angle, child: child),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(top: diameter * .08),
                              child: SizedBox(
                                width: 3,
                                height: diameter * .16,
                                child: ColoredBox(
                                  color: vintage
                                      ? const Color(0xffffca76)
                                      : UiPalette.of(context).accent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (showValue)
                        IgnorePointer(
                          child: Text(
                            '${volume.round()}%',
                            style: UiText.of(context).heading.copyWith(
                              fontSize: (diameter * .14).clamp(14, 24),
                              color: vintage ? const Color(0xffffedc6) : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VolumeIntent extends Intent {
  const _VolumeIntent(this.delta);
  final double delta;
}

class _VolumeArc extends CustomPainter {
  _VolumeArc(this.value, this.palette, this.lowEffects);
  final UiPalette palette;
  final double value;
  final bool lowEffects;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final tick = Paint()
      ..strokeWidth = 1
      ..color = palette.muted.withValues(alpha: .5);
    for (var i = 0; i <= 50; i++) {
      final angle = .75 * math.pi + i / 50 * 1.5 * math.pi;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (radius - 1),
        center + direction * (radius - (i % 5 == 0 ? 11 : 6)),
        tick,
      );
    }
    final rect = (Offset.zero & size).deflate(17);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      .75 * math.pi,
      1.5 * math.pi,
      false,
      paint..color = palette.border,
    );
    canvas.drawArc(
      rect,
      .75 * math.pi,
      1.5 * math.pi * value / 100,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = palette.accent.withValues(alpha: .32)
        ..maskFilter = lowEffects
            ? null
            : const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawArc(
      rect,
      .75 * math.pi,
      1.5 * math.pi * value / 100,
      false,
      paint..color = palette.accent,
    );
  }

  @override
  bool shouldRepaint(_VolumeArc oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.palette != palette ||
      oldDelegate.lowEffects != lowEffects;
}
