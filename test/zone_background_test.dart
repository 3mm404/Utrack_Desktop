import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/controllers/engine_controller.dart';
import 'package:utrack_v1/views/state/engine_view_state.dart';
import 'fake_engine_bridge.dart';

void main() {
  test(
    'Zone background remains separate from playlist and song artwork',
    () async {
      final bridge = FakeEngineBridge();
      final controller = EngineController(bridge);
      await controller.initialize();
      await controller.start();
      final state = EngineViewState(controller);
      bridge.stream.add({
        'type': 'status',
        'report': {
          'applied_config_revision': 3,
          'zones': [
            {'zone_id': '1', 'state': 'playing', 'volume': 60},
          ],
        },
        'zones': [
          {
            'zone_id': '1',
            'name': 'Cafe',
            'playlist': 'Ambient',
            'cover_path': 'playlist.jpg',
            'background_path': 'room.jpg',
          },
        ],
      });
      await Future<void>.delayed(Duration.zero);
      expect(state.selected.backgroundPath, 'room.jpg');
      expect(state.selected.coverPath, 'playlist.jpg');
      bridge.stream.add({
        'type': 'status',
        'report': {
          'applied_config_revision': 3,
          'zones': [
            {'zone_id': '1', 'state': 'playing', 'volume': 60},
          ],
        },
        'zones': [
          {
            'zone_id': '1',
            'name': 'Cafe',
            'playlist': 'Ambient',
            'cover_path': 'playlist.jpg',
          },
        ],
      });
      await Future<void>.delayed(Duration.zero);
      expect(state.selected.backgroundPath, isNull);
      expect(state.selected.coverPath, 'playlist.jpg');
      state.dispose();
      controller.dispose();
    },
  );
}
