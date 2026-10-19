import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/ui_tokens.dart';

/// Drag vertically or use arrow keys to adjust a value from 0 to 100.
class VolumeKnob extends StatelessWidget {
  const VolumeKnob({
    super.key,
    required this.value,
    required this.onChanged,
    this.diameter = 208,
  });
  final double diameter;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final volume = value.clamp(0, 100).toDouble();
    void change(double next) => onChanged(next.clamp(0, 100).toDouble());
    return Semantics(
      label: 'Volumen de zona',
      value: '${volume.round()}%',
      increasedValue: '${(volume + 1).clamp(0, 100).round()}%',
      decreasedValue: '${(volume - 1).clamp(0, 100).round()}%',
      onIncrease: () => change(volume + 1),
      onDecrease: () => change(volume - 1),
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.resizeUpDown,
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
              message: 'Arrastra arriba/abajo o usa las flechas',
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
                        builder: (context, animated, _) =>
                            CustomPaint(painter: _VolumeArc(animated)),
                      ),
                    ),
                    Container(
                      width: diameter * .77,
                      height: diameter * .77,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [UiColors.border, UiColors.input],
                        ),
                        border: Border.all(
                          color: Focus.of(context).hasFocus
                              ? UiColors.accent
                              : UiColors.border,
                          width: 2,
                        ),
                        boxShadow: UiEffects.cardShadow,
                      ),
                      child: Transform.rotate(
                        angle: (-135 + volume * 2.7) * math.pi / 180,
                        child: const Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: UiSpace.md),
                            child: SizedBox(
                              width: 3,
                              height: 20,
                              child: ColoredBox(color: UiColors.accent),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: Text('${volume.round()}%', style: UiType.heading),
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
  _VolumeArc(this.value);
  final double value;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(9);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      .75 * math.pi,
      1.5 * math.pi,
      false,
      paint..color = UiColors.border,
    );
    canvas.drawArc(
      rect,
      .75 * math.pi,
      1.5 * math.pi * value / 100,
      false,
      paint..color = UiColors.accent,
    );
  }

  @override
  bool shouldRepaint(_VolumeArc oldDelegate) => oldDelegate.value != value;
}
