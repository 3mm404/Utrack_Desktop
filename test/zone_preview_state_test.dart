import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/views/state/zone_preview_state.dart';

void main() {
  late ZonePreviewState state;
  setUp(() => state = ZonePreviewState(autoAdvance: false));
  tearDown(() => state.dispose());

  test('Cada zona conserva pista, progreso, volumen y modo de canales', () {
    state.setVolume(2, 23);
    state.setChannels('Mono');
    state.skip(1);
    state.seek(20);
    state.select(0);
    expect(state.selected.volume, 72);
    state.select(2);
    expect(state.selected.volume, 23);
    expect(state.selected.channels, 'Mono');
    expect(state.track.title, 'Brisa');
    expect(state.selected.progress, 20);
  });
  test('El reloj avanza zonas en reproducción aunque cambie la selección', () {
    state.togglePlayback();
    state.select(0);
    state.advance(3);
    expect(state.zones[2].progress, 87);
    expect(state.selected.progress, 0);
    state.togglePlayback();
    state.advance(2);
    expect(state.zones[2].progress, 89);
    expect(state.selected.progress, 2);
    state.togglePlayback();
    state.advance(2);
    expect(state.selected.progress, 2);
  });
  test('Fin de pista respeta repetición y el orden alternativo simulado', () {
    state.togglePlayback();
    state.seek(377);
    state.advance(2);
    expect(state.track.title, 'Brisa');
    expect(state.selected.progress, 1);
    state.toggleRepeat();
    state.seek(244);
    state.advance(2);
    expect(state.track.title, 'Brisa');
    expect(state.selected.progress, 1);
    state.toggleRepeat();
    state.toggleShuffle();
    state.seek(244);
    state.advance(2);
    expect(state.track.title, 'Hotel Valhalla');
  });
  test('Detener motor pausa todo, bloquea play y pone métricas en cero', () {
    state.togglePlayback();
    state.toggleEngine();
    final progress = state.selected.progress;
    state.togglePlayback();
    state.advance(10);
    expect(state.selected.playing, isFalse);
    expect(state.selected.progress, progress);
    expect(state.activeZones, 0);
    expect(state.cpu, 0);
    expect(state.latencyMs, 0);
    state.toggleEngine();
    expect(state.selected.playing, isFalse);
    expect(state.activeZones, 2);
  });
  test(
    'Cambiar dispositivo pausa las zonas y actualiza la latencia simulada',
    () {
      state.togglePlayback();
      state.select(0);
      state.togglePlayback();
      state.selectDevice(1);
      expect(state.zones.every((zone) => !zone.playing), isTrue);
      expect(state.device.name, 'Salida del sistema · Demo');
      expect(state.latencyMs, 24);
      state.toggle(0);
      expect(state.activeZones, 1);
    },
  );
  test('Silencio restaura el volumen de cada zona sin afectar las demás', () {
    state.toggleMute();
    expect(state.selected.volume, 0);
    state.select(0);
    expect(state.selected.volume, 72);
    state.toggleMute();
    state.select(2);
    state.toggleMute();
    expect(state.selected.volume, 65);
    expect(state.zones[0].volume, 0);
  });
}
