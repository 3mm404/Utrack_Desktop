abstract interface class AppearanceStore {
  Future<String?> read();
  Future<void> write(String theme);
}
