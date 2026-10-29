import 'package:flutter/material.dart';
import 'ui_tokens.dart';

/// Semantic colors resolved from the nearest Flutter theme.
class UiPalette {
  const UiPalette({
    required this.background,
    required this.surface,
    required this.elevated,
    required this.input,
    required this.border,
    required this.text,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.operational,
    required this.warning,
    required this.error,
    required this.blue,
  });
  final Color background,
      surface,
      elevated,
      input,
      border,
      text,
      muted,
      accent,
      onAccent,
      operational,
      warning,
      error,
      blue;

  static const dark = UiPalette(
    background: UiColors.background,
    surface: UiColors.surface,
    elevated: UiColors.elevated,
    input: UiColors.input,
    border: UiColors.border,
    text: UiColors.text,
    muted: UiColors.muted,
    accent: UiColors.accent,
    onAccent: UiColors.onAccent,
    operational: UiColors.operational,
    warning: UiColors.warning,
    error: UiColors.error,
    blue: Color(0xff69baff),
  );

  static const light = UiPalette(
    background: Color(0xffffffff),
    surface: Color(0xffffffff),
    elevated: Color(0xffedf1fa),
    input: Color(0xfff2f4f8),
    border: Color(0xffdce1eb),
    text: Color(0xff101828),
    muted: Color(0xff667084),
    accent: Color(0xffcf430b),
    onAccent: Color(0xffffffff),
    operational: Color(0xff09754b),
    warning: Color(0xff8a5700),
    error: Color(0xffba2638),
    blue: Color(0xff075dcc),
  );

  static UiPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? light : dark;
}

class UiText {
  const UiText(this.palette);
  final UiPalette palette;
  static UiText of(BuildContext context) => UiText(UiPalette.of(context));
  TextStyle get heading => UiType.heading.copyWith(color: palette.text);
  TextStyle get title => UiType.title.copyWith(color: palette.text);
  TextStyle get body => UiType.body.copyWith(color: palette.text);
  TextStyle get caption => UiType.caption.copyWith(color: palette.muted);
  TextStyle get label => UiType.label.copyWith(color: palette.text);
}

class UiDecor {
  const UiDecor(this.palette);
  final UiPalette palette;
  static UiDecor of(BuildContext context) => UiDecor(UiPalette.of(context));
  BorderSide get border => BorderSide(color: palette.border);
  bool get isLight => palette == UiPalette.light;
  LinearGradient get panelGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isLight
        ? const [Color(0xfffefefe), Color(0xfff4f6fa)]
        : const [Color(0xff252e35), Color(0xff151b23)],
  );
  SweepGradient get metalGradient => SweepGradient(
    colors: isLight
        ? const [
            Color(0xffa8adb2),
            Color(0xffffffff),
            Color(0xffd4d8dc),
            Color(0xff8c9399),
            Color(0xffeff1f3),
            Color(0xffa8adb2),
          ]
        : const [
            Color(0xff22272c),
            Color(0xff879197),
            Color(0xff454d53),
            Color(0xff191e24),
            Color(0xff707b82),
            Color(0xff22272c),
          ],
  );
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xff07152b).withValues(alpha: isLight ? .17 : .52),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xff07152b).withValues(alpha: isLight ? .09 : .32),
      blurRadius: 3,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: isLight ? .9 : .10),
      blurRadius: 1,
      offset: const Offset(-1, -1),
    ),
  ];
  List<BoxShadow> get controlShadow => [
    BoxShadow(
      color: const Color(0xff07152b).withValues(alpha: isLight ? .26 : .65),
      blurRadius: 7,
      offset: const Offset(2, 4),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: isLight ? .85 : .18),
      blurRadius: 1,
      offset: const Offset(-1, -1),
    ),
  ];
  BoxDecoration get cardDecoration => BoxDecoration(
    gradient: panelGradient,
    borderRadius: UiRadii.card,
    border: Border.all(color: palette.border),
    boxShadow: cardShadow,
  );
}
