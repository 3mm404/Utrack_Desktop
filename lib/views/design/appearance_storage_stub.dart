import 'appearance_store.dart';

/// Browser previews keep appearance in memory; desktop uses per-user storage.
class AppearanceStorage implements AppearanceStore {
  String? _theme;
  @override
  Future<String?> read() async => _theme;
  @override
  Future<void> write(String theme) async {
    _theme = theme;
  }
}
