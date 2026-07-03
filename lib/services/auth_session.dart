import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/user_profile_helpers.dart';
import 'platform_storage.dart';

/// Persists the logged-in user so browser refresh does not return to login.
abstract final class AuthSession {
  static const _userKey = 'logged_in_user_v1';

  /// Returns false if the user map has nothing we can restore later.
  static Future<bool> save(Map<String, dynamic> user) async {
    final normalized = UserProfileHelpers.normalize(
      Map<String, dynamic>.from(user),
    );
    if (!_hasIdentity(normalized)) return false;

    await PlatformStorage.write(_userKey, jsonEncode(normalized));
    return true;
  }

  static Future<Map<String, dynamic>?> load() async {
    var raw = await PlatformStorage.read(_userKey);
    if (raw == null || raw.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      raw = prefs.getString(_userKey);
      if (raw != null && raw.isNotEmpty) {
        await PlatformStorage.write(_userKey, raw);
      }
    }
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final user = UserProfileHelpers.normalize(
        Map<String, dynamic>.from(decoded),
      );
      return _hasIdentity(user) ? user : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    await PlatformStorage.delete(_userKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static bool _hasIdentity(Map<String, dynamic> user) {
    final id = user['id']?.toString().trim();
    if (id != null && id.isNotEmpty) return true;
    final mobile = user['mobile']?.toString().trim();
    if (mobile != null && mobile.isNotEmpty) return true;
    final email = user['email']?.toString().trim();
    if (email != null && email.isNotEmpty) return true;
    final token = user['token']?.toString().trim();
    return token != null && token.isNotEmpty;
  }
}
