import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/views/design/ui_appearance.dart';
import 'package:utrack_v1/views/design/ui_palette.dart';
import 'package:utrack_v1/views/design/ui_theme.dart';
import 'package:utrack_v1/views/layout/utrack_shell.dart';

void main() {
  testWidgets('Theme switch preserves navigation and resolves both palettes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => UiAppearance.mode.value = ThemeMode.dark);
    UiAppearance.mode.value = ThemeMode.dark;
    await tester.pumpWidget(
      ValueListenableBuilder<ThemeMode>(
        valueListenable: UiAppearance.mode,
        builder: (context, mode, _) => MaterialApp(
          theme: UiTheme.light,
          darkTheme: UiTheme.dark,
          themeMode: mode,
          home: const UtrackShell(
            status: 'Prueba',
            connected: false,
            settings: SizedBox(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Abrir navegación'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Biblioteca'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cambiar a tema claro'));
    await tester.pumpAndSettle();
    expect(UiAppearance.mode.value, ThemeMode.light);
    final context = tester.element(find.byType(ThemeToggle));
    expect(UiPalette.of(context).background, Colors.white);
    expect(Theme.of(context).brightness, Brightness.light);
    expect(find.text('Biblioteca').last, findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Cambiar a tema oscuro'));
    await tester.pumpAndSettle();
    expect(UiAppearance.mode.value, ThemeMode.dark);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
