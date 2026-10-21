import 'package:flutter/material.dart';
import 'ui_tokens.dart';
import 'ui_palette.dart';

abstract final class UiTheme {
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);
  static ThemeData _build(Brightness brightness) {
    final palette = brightness == Brightness.light
        ? UiPalette.light
        : UiPalette.dark;
    final typography = UiText(palette);
    final effects = UiDecor(palette);
    final shape = RoundedRectangleBorder(borderRadius: UiRadii.control);
    final inputBorder = OutlineInputBorder(
      borderRadius: UiRadii.control,
      borderSide: effects.border,
    );
    final colors =
        ColorScheme.fromSeed(
          seedColor: palette.accent,
          brightness: brightness,
        ).copyWith(
          primary: palette.accent,
          onPrimary: palette.onAccent,
          secondary: palette.blue,
          onSecondary: palette.onAccent,
          surface: palette.surface,
          onSurface: palette.text,
          onSurfaceVariant: palette.muted,
          outline: palette.border,
          error: palette.error,
        );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: palette.background,
      textTheme: TextTheme(
        headlineSmall: typography.heading,
        titleLarge: typography.title,
        bodyLarge: typography.body,
        bodyMedium: typography.body,
        bodySmall: typography.caption,
        labelLarge: typography.label,
      ),
      dividerTheme: DividerThemeData(color: palette.border, thickness: 1),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: UiRadii.card,
          side: effects.border,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.input,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: palette.accent, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: palette.error),
        ),
        contentPadding: EdgeInsets.all(UiSpace.lg),
        labelStyle: typography.body.copyWith(color: palette.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 5,
          shadowColor: palette.accent.withValues(alpha: .4),
          minimumSize: Size(48, 48),
          shape: shape,
          padding: EdgeInsets.symmetric(
            horizontal: UiSpace.xl,
            vertical: UiSpace.md,
          ),
          textStyle: typography.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(48, 48),
          shape: shape,
          side: effects.border,
          textStyle: typography.label,
          padding: EdgeInsets.symmetric(
            horizontal: UiSpace.xl,
            vertical: UiSpace.md,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size(48, 48),
          shape: shape,
          textStyle: typography.label,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: Size(48, 48), shape: shape),
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: typography.caption.copyWith(color: palette.text),
        decoration: BoxDecoration(
          color: palette.elevated,
          borderRadius: UiRadii.control,
          border: Border.fromBorderSide(effects.border),
        ),
      ),
    );
  }
}
