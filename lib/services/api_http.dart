import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// True when the browser blocked the request (CORS) or the API is unreachable.
bool isNetworkBlocked(Object error) {
  final s = error.toString().toLowerCase();
  return s.contains('failed to fetch') ||
      s.contains('connection refused') ||
      s.contains('network is unreachable') ||
      s.contains('xmlhttprequest error') ||
      s.contains('socketexception');
}

/// On Flutter web, GET to a separate origin often fails CORS; prefer POST only.
bool get preferPostOnlyOnWeb => kIsWeb;

Future<http.Response?> safeGet(Uri url, {Map<String, String>? headers}) async {
  if (preferPostOnlyOnWeb) return null;
  return tryGet(url, headers: headers);
}

/// GET that still runs on web (needed for wallet / user list when CORS allows GET).
Future<http.Response?> tryGet(Uri url, {Map<String, String>? headers}) async {
  try {
    return await http
        .get(url, headers: headers ?? {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));
  } catch (e) {
    if (kDebugMode && isNetworkBlocked(e)) {
      debugPrint('API GET failed: $url — $e');
    }
    return null;
  }
}

Future<http.Response?> safePost(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
}) async {
  try {
    return await http
        .post(
          url,
          headers: headers ??
              {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
          body: body,
        )
        .timeout(const Duration(seconds: 12));
  } catch (e) {
    if (kDebugMode && isNetworkBlocked(e)) {
      debugPrint('API POST blocked (CORS/offline): $url');
    }
    return null;
  }
}
