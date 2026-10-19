import 'package:flutter/material.dart';
import '../design/ui_tokens.dart';

/// Small code-native metallic dial, also used as the brand mark.
class MetalDial extends StatelessWidget {
  const MetalDial({
    super.key,
    this.size = 52,
    this.selected = false,
    this.brand = false,
    this.onTap,
  });
  final double size;
  final bool selected, brand;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: brand
              ? [
                  const Color(0xff282521),
                  UiColors.accent,
                  const Color(0xff665445),
                  const Color(0xfff8e7d1),
                  const Color(0xff282521),
                ]
              : [
                  const Color(0xff85898c),
                  const Color(0xff20252a),
                  const Color(0xffc1c4c4),
                  const Color(0xff20252a),
                  const Color(0xff85898c),
                ],
        ),
        border: Border.all(
          color: selected || brand ? UiColors.accent : UiColors.border,
          width: 1.2,
        ),
        boxShadow: [
          const BoxShadow(
            color: Colors.black87,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
          if (selected)
            BoxShadow(
              color: UiColors.accent.withValues(alpha: .22),
              blurRadius: 14,
            ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(brand ? 7 : 3),
        child: Material(
          color: UiColors.background,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Center(
              child: Container(
                width: brand ? size * .44 : size * .21,
                height: brand ? size * .44 : size * .21,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xffeeeeea), Color(0xff7c8185)],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black87, blurRadius: 4),
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
