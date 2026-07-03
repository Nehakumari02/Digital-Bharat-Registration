import 'user_profile_helpers.dart';

/// Extracts user map from common Laravel / API login JSON shapes.
Map<String, dynamic> parseLoginUser(
  dynamic body, {
  String? mobileOrEmail,
}) {
  final out = <String, dynamic>{};

  if (body is Map) {
    final map = Map<String, dynamic>.from(body);

    final nestedUser = map['user'];
    if (nestedUser is Map) {
      out.addAll(Map<String, dynamic>.from(nestedUser));
    }

    final data = map['data'];
    if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      final dataUser = dataMap['user'];
      if (dataUser is Map) {
        out.addAll(Map<String, dynamic>.from(dataUser));
      } else if (dataMap['id'] != null ||
          dataMap['email'] != null ||
          dataMap['mobile'] != null) {
        out.addAll(dataMap);
      }
    }

    if (out.isEmpty &&
        (map['id'] != null || map['email'] != null || map['mobile'] != null)) {
      for (final e in map.entries) {
        if (e.key == 'token' ||
            e.key == 'access_token' ||
            e.key == 'message' ||
            e.key == 'success') {
          continue;
        }
        if (e.value is Map || e.value is List) continue;
        out[e.key] = e.value;
      }
    }

    for (final tokenKey in ['token', 'access_token', 'api_token']) {
      if (map[tokenKey] != null) {
        out[tokenKey] = map[tokenKey];
      }
    }
  }

  final loginId = mobileOrEmail?.trim();
  if (loginId != null && loginId.isNotEmpty) {
    if (loginId.contains('@')) {
      out['email'] ??= loginId;
    } else {
      out['mobile'] ??= loginId;
    }
  }

  return UserProfileHelpers.normalize(out);
}
