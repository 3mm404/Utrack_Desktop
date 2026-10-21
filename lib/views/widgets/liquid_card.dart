import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../design/ui_palette.dart';

/// A bounded frosted surface; highlights never intercept pointer events.
class LiquidCard extends StatelessWidget {
  const LiquidCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final palette = UiPalette.of(context);
    final light = palette == UiPalette.light;
    const radius = BorderRadius.all(Radius.circular(22));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xff082348).withValues(alpha: light ? .13 : .38),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: palette.blue.withValues(alpha: light ? .07 : .10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: CustomPaint(
            foregroundPainter: _LiquidRim(palette),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0, .38, 1],
                  colors: light
                      ? [
                          Colors.white.withValues(alpha: .94),
                          palette.input.withValues(alpha: .76),
                          palette.elevated.withValues(alpha: .58),
                        ]
                      : [
                          palette.elevated.withValues(alpha: .84),
                          palette.surface.withValues(alpha: .76),
                          palette.input.withValues(alpha: .86),
                        ],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidRim extends CustomPainter {
  const _LiquidRim(this.palette);
  final UiPalette palette;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final light = palette == UiPalette.light;
    final bounds = Offset.zero & size;
    final rim = RRect.fromRectAndRadius(
      bounds.deflate(.75),
      const Radius.circular(21),
    );
    canvas.drawRRect(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: light ? .98 : .48),
            palette.blue.withValues(alpha: .18),
            Colors.white.withValues(alpha: light ? .65 : .12),
            palette.blue.withValues(alpha: .30),
          ],
          stops: const [0, .35, .7, 1],
        ).createShader(bounds),
    );
    // A narrow reflected highlight follows the upper curved edge.
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds.deflate(2.5), const Radius.circular(19)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: light ? .75 : .20),
            Colors.transparent,
          ],
          stops: const [0, .23],
        ).createShader(bounds),
    );
  }

  @override
  bool? hitTest(Offset position) => false;
  @override
  bool shouldRepaint(covariant _LiquidRim oldDelegate) =>
      oldDelegate.palette != palette;
}
