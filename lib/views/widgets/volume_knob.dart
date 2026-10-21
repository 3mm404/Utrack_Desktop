import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/ui_tokens.dart';
import '../design/ui_palette.dart';

/// Drag vertically or use arrow keys to adjust a value from 0 to 100.
class VolumeKnob extends StatelessWidget {
  const VolumeKnob({
    super.key,
    required this.value,
    required this.onChanged,
    this.diameter = 208,
    this.showValue = true,
  });
  final bool showValue;
  final double diameter;
  final double value;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final volume = value.clamp(0, 100).toDouble();
    void change(double next) => onChanged?.call(next.clamp(0, 100).toDouble());
    return Semantics(
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
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 120),
                        builder: (context, animated, _) => CustomPaint(
                          painter: _VolumeArc(animated, UiPalette.of(context)),
                        ),
                      ),
                    ),
                    Container(
                      width: diameter * .77,
                      height: diameter * .77,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: UiDecor.of(context).metalGradient,
                        border: Border.all(
                          color: Focus.of(context).hasFocus
                              ? UiPalette.of(context).accent
                              : UiPalette.of(context).border,
                          width: 2,
                        ),
                        boxShadow: UiDecor.of(context).controlShadow,
                      ),
                      child: Transform.rotate(
                        angle: (-135 + volume * 2.7) * math.pi / 180,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: UiSpace.md),
                            child: SizedBox(
                              width: 3,
                              height: 36,
                              child: ColoredBox(
                                color: UiPalette.of(context).blue,
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
                          style: UiText.of(context).heading,
                        ),
                      ),
                  ],
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
  _VolumeArc(this.value, this.palette);
  final UiPalette palette;
  final double value;
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
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
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
      oldDelegate.value != value || oldDelegate.palette != palette;
}
