import 'package:flutter/material.dart';
import 'appearance_storage.dart';
import 'appearance_store.dart';

abstract final class UiAppearance {
  static final mode = ValueNotifier<ThemeMode>(ThemeMode.dark);
  static AppearanceStore? _storage;
  static Future<void> _pending = Future<void>.value();

  static Future<void> initialize({AppearanceStore? storage}) async {
    await _pending.catchError((Object _) {});
    _storage = storage ?? AppearanceStorage();
    final saved = await _storage!.read();
    mode.value = saved == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  static Future<void> toggle() {
    mode.value = mode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    final storage = _storage;
    final saved = mode.value == ThemeMode.light ? 'light' : 'dark';
    if (storage == null) return Future<void>.value();
    // Serialize writes so rapid toggles cannot overwrite a newer selection.
    _pending = _pending
        .catchError((Object _) {})
        .then((_) => storage.write(saved));
    return _pending;
  }
}

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});
  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return IconButton(
      tooltip: light ? 'Cambiar a tema oscuro' : 'Cambiar a tema claro',
      onPressed: () async {
        try {
          await UiAppearance.toggle();
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se pudo guardar el tema. Revisa los permisos de tu usuario.',
              ),
            ),
          );
        }
      },
      icon: Icon(light ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
    );
  }
}
