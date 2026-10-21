import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_v1/views/design/appearance_storage_io.dart';
import 'package:utrack_v1/views/design/ui_appearance.dart';

void main() {
  late Directory directory;
  late AppearanceStorage storage;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('utrack-appearance-');
    storage = AppearanceStorage(directory: directory);
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test(
    'Restores light and dark from disk across new storage instances',
    () async {
      await UiAppearance.initialize(storage: storage);
      expect(UiAppearance.mode.value, ThemeMode.dark);
      await UiAppearance.toggle();
      expect(await storage.read(), 'light');
      UiAppearance.mode.value = ThemeMode.dark;
      await UiAppearance.initialize(
        storage: AppearanceStorage(directory: directory),
      );
      expect(UiAppearance.mode.value, ThemeMode.light);
      await UiAppearance.toggle();
      UiAppearance.mode.value = ThemeMode.light;
      await UiAppearance.initialize(
        storage: AppearanceStorage(directory: directory),
      );
      expect(UiAppearance.mode.value, ThemeMode.dark);
    },
  );

  test('Rapid toggles persist the last choice without racing writes', () async {
    await UiAppearance.initialize(storage: storage);
    await Future.wait([
      UiAppearance.toggle(),
      UiAppearance.toggle(),
      UiAppearance.toggle(),
    ]);
    expect(UiAppearance.mode.value, ThemeMode.light);
    expect(await storage.read(), 'light');
    expect(await File('${storage.file.path}.tmp').exists(), isFalse);
  });

  test(
    'Missing, malformed and unsupported preferences use the default',
    () async {
      for (final content in ['not json', '[]', '{"theme":"unknown"}']) {
        await storage.file.writeAsString(content);
        await UiAppearance.initialize(storage: storage);
        expect(UiAppearance.mode.value, ThemeMode.dark);
      }
    },
  );

  test(
    'Write errors propagate while the selected theme stays usable',
    () async {
      final blocker = File('${directory.path}/blocked');
      await blocker.writeAsString('file in place of a directory');
      await UiAppearance.initialize(
        storage: AppearanceStorage(directory: Directory(blocker.path)),
      );
      await expectLater(
        UiAppearance.toggle(),
        throwsA(isA<FileSystemException>()),
      );
      expect(UiAppearance.mode.value, ThemeMode.light);
      await UiAppearance.initialize(storage: storage);
      await UiAppearance.toggle();
      expect(await storage.read(), 'light');
    },
  );
}
