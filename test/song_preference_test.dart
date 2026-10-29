import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/views/state/engine_view_state.dart';
import 'package:utrack_v1/views/widgets/song_preference_controls.dart';
import 'fake_engine_bridge.dart';

void main() {
  for (final width in [390.0, 1000.0]) {
    testWidgets(
      'Likes and exclusions are server-confirmed and scoped at $width px',
      (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final bridge = FakeEngineBridge()..playbackEnabled = true;
        final controller = EngineController(bridge);
        final state = EngineViewState(controller);
        await controller.initialize();
        await controller.start();
        bridge.connected();
        final event = <String, dynamic>{
          'type': 'status',
          'server_control': true,
          'report': {
            'applied_config_revision': 3,
            'zones': [
              {'zone_id': '1', 'state': 'playing', 'volume': 60},
              {'zone_id': '2', 'state': 'stopped', 'volume': 50},
            ],
          },
          'zones': [
            {'zone_id': '1', 'name': 'Terraza', 'playlist': 'Ambient'},
            {
              'zone_id': '2',
              'name': 'Barra',
              'playlist': 'Lounge',
              'song_preferences': <String, String>{},
            },
          ],
        };
        bridge.stream.add(event);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListenableBuilder(
                listenable: state,
                builder: (_, _) => SongPreferenceControls(
                  state: state,
                  zoneId: '2',
                  songId: '8',
                  compact: true,
                ),
              ),
            ),
          ),
        );
        Future<void> choose(String tooltip, String menuText) async {
          if (width < 600) {
            await tester.tap(find.byTooltip('Preferencias de esta canción'));
            await tester.pumpAndSettle();
            await tester.tap(find.text(menuText));
          } else {
            await tester.tap(find.byTooltip(tooltip));
          }
        }

        await choose(
          'Me gusta: +20 % en aleatorio continuo',
          'Me gusta · +20 % en aleatorio continuo',
        );
        await tester.pump();
        expect(bridge.playbackRequests.last['action'], 'song_preference');
        expect(bridge.playbackRequests.last['zone_id'], '2');
        expect(bridge.playbackRequests.last['song_id'], '8');
        expect(bridge.playbackRequests.last['preference'], 'like');
        expect(state.zones[1].songPreferences, isEmpty);
        bridge.playbackResult('succeeded');
        (event['zones'] as List)[1]['song_preferences'] = {'8': 'like'};
        bridge.stream.add(event);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
        expect(state.zones.first.songPreferences, isEmpty);
        await choose(
          'No me gusta: excluir en esta zona',
          'No me gusta · excluir en esta zona',
        );
        await tester.pump();
        expect(bridge.playbackRequests.last['preference'], 'dislike');
        bridge.playbackResult('succeeded');
        (event['zones'] as List)[1]['song_preferences'] = {'8': 'dislike'};
        bridge.stream.add(event);
        await tester.pumpAndSettle();
        await choose('Volver a permitir esta canción', 'Volver a permitir');
        await tester.pump();
        expect(bridge.playbackRequests.last['preference'], 'neutral');
        bridge.playbackResult('succeeded');
        await tester.pumpWidget(const SizedBox());
        state.dispose();
        controller.dispose();
      },
    );
  }
}
