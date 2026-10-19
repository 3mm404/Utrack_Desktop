import 'package:flutter/material.dart';

abstract final class UiColors {
  static const background = Color(0xff070a0d);
  static const surface = Color(0xff0c1014);
  static const elevated = Color(0xff181e25);
  static const input = Color(0xff090d12);
  static const border = Color(0xff2b333d);
  static const text = Color(0xfff0eeeb);
  static const muted = Color(0xffabb0b8);
  static const accent = Color(0xffdfc1a0);
  static const onAccent = Color(0xff211a13);
  static const operational = Color(0xff68e4c3);
  static const warning = Color(0xffe1b870);
  static const error = Color(0xffef9c98);
}

abstract final class UiSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class UiRadii {
  static const control = BorderRadius.all(Radius.circular(10));
  static const card = BorderRadius.all(Radius.circular(16));
}

abstract final class UiType {
  static const heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.4,
    color: UiColors.text,
  );
  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: UiColors.text,
  );
  static const body = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: UiColors.text,
  );
  static const caption = TextStyle(
    fontSize: 12,
    height: 1.5,
    color: UiColors.muted,
  );
  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}

abstract final class UiEffects {
  static const border = BorderSide(color: UiColors.border);
  static const cardShadow = [
    BoxShadow(color: Color(0x20000000), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const cardDecoration = BoxDecoration(
    color: UiColors.surface,
    borderRadius: UiRadii.card,
    border: Border.fromBorderSide(border),
    boxShadow: cardShadow,
  );
}
