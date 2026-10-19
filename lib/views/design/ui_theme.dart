import 'package:flutter/material.dart';
import 'ui_tokens.dart';

abstract final class UiTheme {
  static ThemeData get dark {
    const shape = RoundedRectangleBorder(borderRadius: UiRadii.control);
    const inputBorder = OutlineInputBorder(
      borderRadius: UiRadii.control,
      borderSide: UiEffects.border,
    );
    final colors =
        ColorScheme.fromSeed(
          seedColor: UiColors.accent,
          brightness: Brightness.dark,
        ).copyWith(
          primary: UiColors.accent,
          onPrimary: UiColors.onAccent,
          secondary: UiColors.accent,
          onSecondary: UiColors.onAccent,
          surface: UiColors.surface,
          onSurface: UiColors.text,
          onSurfaceVariant: UiColors.muted,
          outline: UiColors.border,
          error: UiColors.error,
        );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colors,
      scaffoldBackgroundColor: UiColors.background,
      textTheme: const TextTheme(
        headlineSmall: UiType.heading,
        titleLarge: UiType.title,
        bodyLarge: UiType.body,
        bodyMedium: UiType.body,
        bodySmall: UiType.caption,
        labelLarge: UiType.label,
      ),
      dividerTheme: const DividerThemeData(
        color: UiColors.border,
        thickness: 1,
      ),
      cardTheme: const CardThemeData(
        color: UiColors.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: UiRadii.card,
          side: UiEffects.border,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: UiColors.input,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: UiColors.accent, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: UiColors.error),
        ),
        contentPadding: const EdgeInsets.all(UiSpace.lg),
        labelStyle: UiType.body.copyWith(color: UiColors.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
          padding: const EdgeInsets.symmetric(
            horizontal: UiSpace.xl,
            vertical: UiSpace.md,
          ),
          textStyle: UiType.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
          side: UiEffects.border,
          textStyle: UiType.label,
          padding: const EdgeInsets.symmetric(
            horizontal: UiSpace.xl,
            vertical: UiSpace.md,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
          textStyle: UiType.label,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: UiType.caption.copyWith(color: UiColors.text),
        decoration: const BoxDecoration(
          color: UiColors.elevated,
          borderRadius: UiRadii.control,
          border: Border.fromBorderSide(UiEffects.border),
        ),
      ),
    );
  }
}
