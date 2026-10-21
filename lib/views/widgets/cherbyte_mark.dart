import 'package:flutter/material.dart';
import '../design/ui_palette.dart';

/// The same vector geometry as the Cherbyte website brand mark.
class CherbyteMark extends StatelessWidget {
  const CherbyteMark({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Cherbyte',
    image: true,
    child: SizedBox(
      width: size * 1040 / 1100,
      height: size,
      child: CustomPaint(painter: _CherbytePainter(UiPalette.of(context))),
    ),
  );
}

class _CherbytePainter extends CustomPainter {
  final UiPalette palette;
  const _CherbytePainter(this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 1040, size.height / 1100);
    canvas.translate(-185, -40);
    final c = Path()
      ..moveTo(850, 40)
      ..lineTo(470, 40)
      ..lineTo(185, 320)
      ..lineTo(185, 858)
      ..lineTo(460, 1140)
      ..lineTo(850, 1140)
      ..lineTo(850, 950)
      ..lineTo(575, 950)
      ..lineTo(395, 770)
      ..lineTo(395, 395)
      ..lineTo(555, 235)
      ..lineTo(850, 235)
      ..close();
    final bracket = Path()
      ..moveTo(848, 235)
      ..lineTo(1010, 235)
      ..lineTo(1225, 450)
      ..lineTo(1225, 755)
      ..lineTo(1030, 950)
      ..lineTo(848, 950)
      ..lineTo(848, 760)
      ..lineTo(930, 760)
      ..lineTo(1022, 668)
      ..lineTo(1022, 525)
      ..lineTo(930, 435)
      ..lineTo(848, 435)
      ..close();
    canvas.drawPath(c, Paint()..color = palette.text);
    canvas.drawPath(bracket, Paint()..color = palette.accent);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CherbytePainter oldDelegate) =>
      oldDelegate.palette != palette;
}
