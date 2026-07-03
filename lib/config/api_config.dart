import 'package:flutter/foundation.dart';

/// Resolves the Laravel API base URL for the current run target.
///
/// - **Web / desktop (macOS, Windows, Linux, iOS simulator):** `127.0.0.1`
/// - **Android emulator:** `10.0.2.2` (host loopback from the emulator)
///
/// On a **physical phone**, replace with your machine's LAN IP (e.g. `192.168.1.5`)
/// or run the backend on a reachable host.
abstract final class ApiConfig {
  static const String _hostLoopback = 'https://orchid-dunlin-775683.hostingersite.com/router/api/public/api';
  static const String _androidEmulator = 'http://10.0.2.2:8000/api';
  static const String _localWebBackend = 'http://127.0.0.1:8000/api';

  static String get baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        return _localWebBackend;
      }
      return _hostLoopback;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidEmulator;
      default:
        return _hostLoopback;
    }
  }
}
