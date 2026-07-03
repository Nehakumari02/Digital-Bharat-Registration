import 'platform_storage_stub.dart'
    if (dart.library.html) 'platform_storage_web.dart' as impl;

/// Key/value storage: localStorage on web, SharedPreferences elsewhere.
abstract final class PlatformStorage {
  static Future<void> write(String key, String value) => impl.write(key, value);

  static Future<String?> read(String key) => impl.read(key);

  static Future<void> delete(String key) => impl.delete(key);
}
