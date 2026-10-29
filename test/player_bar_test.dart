import 'package:utrack_v1/views/state/zone_preview_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/views/design/ui_theme.dart';
import 'package:utrack_v1/views/widgets/player_bar.dart';
import 'package:utrack_v1/views/widgets/ui_controls.dart';

void main() {
  for (final width in [320.0, 360.0, 390.0, 1280.0]) {
    testWidgets(
      'Reproductor simulado: transporte, progreso y silencio a $width px',
      (tester) async {
        tester.view.physicalSize = Size(width, 850);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final preview = ZonePreviewState(autoAdvance: false);
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.dark,
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: PlayerBar(state: preview),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (width < 600) {
          expect(
            tester.getSize(find.byType(PlayerBar)).height,
            lessThanOrEqualTo(210),
          );
        }
        await tester.tap(find.byTooltip('Reproducir vista previa'));
        await tester.pump();
        expect(find.byTooltip('Pausar vista previa'), findsOneWidget);
        final progress = find.byType(Slider).last;
        await tester.tapAt(tester.getCenter(progress));
        await tester.pump();
        expect(tester.widget<Slider>(progress).value, greaterThan(84));
        await tester.tap(find.byTooltip('Canción siguiente'));
        await tester.pump();
        expect(find.text('Brisa'), findsOneWidget);
        expect(tester.widget<Slider>(progress).value, 0);
        await tester.tap(find.byTooltip('Silenciar reproductor'));
        await tester.pump();
        expect(find.text('0%'), findsOneWidget);
        await tester.tap(find.byTooltip('Restaurar volumen del reproductor'));
        await tester.pump();
        expect(find.text('65%'), findsOneWidget);
        await tester.tap(find.byTooltip('Aleatorio'));
        await tester.tap(find.byTooltip('Repetir'));
        await tester.pump();
        expect(
          tester
              .widget<UiIconControl>(
                find.byWidgetPredicate(
                  (w) => w is UiIconControl && w.label == 'Aleatorio',
                ),
              )
              .selected,
          isTrue,
        );
        expect(
          tester
              .widget<UiIconControl>(
                find.byWidgetPredicate(
                  (w) => w is UiIconControl && w.label == 'Repetir',
                ),
              )
              .selected,
          isTrue,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        preview.dispose();
      },
    );
  }
}
