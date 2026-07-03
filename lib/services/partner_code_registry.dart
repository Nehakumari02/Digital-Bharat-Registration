import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import 'api_http.dart';
import '../models/partner_code_validation.dart';
import '../utils/partner_code_util.dart';

/// Local + API partner code lookup (works even when validate-partner-code route is missing).
class PartnerCodeRegistry {
  static const _storageKey = 'partner_codes_v1';

  static Future<void> savePartner({
    required String code,
    required String name,
    int? partnerId,
    String? mobile,
  }) async {
    final normalized = PartnerCodeUtil.normalizeInput(code);
    if (normalized == null) return;

    final prefs = await SharedPreferences.getInstance();
    final map = await _readMap(prefs);
    map[normalized] = {
      'name': name,
      'id': partnerId,
      'mobile': mobile,
      'saved_at': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_storageKey, jsonEncode(map));
    debugPrint('PartnerCodeRegistry: saved $normalized');
  }

  /// Partner code saved on this device for the given mobile (after Partner signup).
  static Future<String?> partnerCodeForMobile(String rawMobile) async {
    final digits = rawMobile.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return null;
    final mobile = digits.length > 10 ? digits.substring(digits.length - 10) : digits;

    final prefs = await SharedPreferences.getInstance();
    final map = await _readMap(prefs);
    for (final entry in map.entries) {
      final data = entry.value;
      if (data is! Map) continue;
      final m = data['mobile']?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
      final tail = m.length >= 10 ? m.substring(m.length - 10) : m;
      if (tail == mobile) return entry.key;
    }
    return null;
  }

  static Future<int?> partnerIdForCode(String rawCode) async {
    final local = await findLocal(rawCode);
    if (local?.partnerId != null) return local!.partnerId;
    final server = await findOnServer(rawCode);
    return server?.partnerId;
  }

  static Future<PartnerCodeValidation?> findLocal(String rawCode) async {
    final candidates = PartnerCodeUtil.validationCandidates(rawCode);
    if (candidates.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final map = await _readMap(prefs);

    for (final code in candidates) {
      final entry = map[code];
      if (entry is Map) {
        return PartnerCodeValidation(
          valid: true,
          partnerName: entry['name']?.toString(),
          partnerId: int.tryParse(entry['id']?.toString() ?? ''),
          message: 'Verified (registered partner)',
        );
      }
    }
    return null;
  }

  /// Scans common Laravel list endpoints for a user with matching partner_code.
  /// Find partner by mobile number (10 digits) when code lookup fails.
  static Future<PartnerCodeValidation?> findByMobile(String rawMobile) async {
    final digits = rawMobile.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return null;
    final mobile = digits.length > 10 ? digits.substring(digits.length - 10) : digits;

    final base = ApiConfig.baseUrl;
    final listUrls = ['$base/users', '$base/registered-users', '$base/all-users'];

    for (final urlStr in listUrls) {
      try {
        final response = await safeGet(Uri.parse(urlStr));
        if (response == null || response.statusCode != 200) continue;

        for (final user in _extractUserList(response.body)) {
          final userMobile = user['mobile']?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
          final tail = userMobile.length >= 10
              ? userMobile.substring(userMobile.length - 10)
              : userMobile;
          if (tail != mobile) continue;
          if (!_isPartnerUser(user)) continue;

          final code = _partnerCodeFromUser(user) ??
              PartnerCodeUtil.generate(seed: mobile);
          await savePartner(
            code: code,
            name: user['name']?.toString() ?? 'Partner',
            partnerId: int.tryParse(user['id']?.toString() ?? ''),
            mobile: mobile,
          );
          return PartnerCodeValidation(
            valid: true,
            partnerName: user['name']?.toString(),
            partnerId: int.tryParse(user['id']?.toString() ?? ''),
            message: 'Verified via partner mobile',
          );
        }
      } catch (e) {
        debugPrint('PartnerCodeRegistry mobile scan: $e');
      }
    }
    return null;
  }

  static Future<PartnerCodeValidation?> findOnServer(String rawCode) async {
    final candidates = PartnerCodeUtil.validationCandidates(rawCode);
    if (candidates.isEmpty) return null;

    final base = ApiConfig.baseUrl;
    final listUrls = [
      '$base/users',
      '$base/registered-users',
      '$base/all-users',
      '$base/get-users',
      '$base/partners',
    ];

    for (final urlStr in listUrls) {
      try {
        final response = await safeGet(Uri.parse(urlStr));
        if (response == null || response.statusCode != 200) continue;

        final users = _extractUserList(response.body);
        for (final user in users) {
          final match = _userMatchesCode(user, candidates);
          if (match != null) {
            final code = _partnerCodeFromUser(user) ?? match;
            await savePartner(
              code: code,
              name: user['name']?.toString() ?? 'Partner',
              partnerId: int.tryParse(user['id']?.toString() ?? ''),
              mobile: user['mobile']?.toString(),
            );
            return PartnerCodeValidation(
              valid: true,
              partnerName: user['name']?.toString(),
              partnerId: int.tryParse(user['id']?.toString() ?? ''),
              message: 'Verified',
            );
          }
        }
      } catch (e) {
        debugPrint('PartnerCodeRegistry server scan $urlStr: $e');
      }
    }

    return await _findSingleUserEndpoints(candidates);
  }

  static Future<PartnerCodeValidation?> _findSingleUserEndpoints(List<String> candidates) async {
    final base = ApiConfig.baseUrl;
    for (final code in candidates) {
      final urls = [
        '$base/user-by-partner-code?partner_code=$code',
        '$base/user-by-partner-code?code=$code',
        '$base/partners/$code',
      ];
      for (final urlStr in urls) {
        try {
          final response = await safeGet(Uri.parse(urlStr));
          if (response == null || response.statusCode != 200) continue;
          final body = jsonDecode(response.body);
          if (body is! Map) continue;
          final m = Map<String, dynamic>.from(body);
          final user = m['user'] ?? m['partner'] ?? m['data'] ?? m;
          if (user is Map) {
            final u = Map<String, dynamic>.from(user);
            return PartnerCodeValidation(
              valid: true,
              partnerName: u['name']?.toString(),
              partnerId: int.tryParse(u['id']?.toString() ?? ''),
              message: 'Verified',
            );
          }
        } catch (_) {}
      }
    }
    return null;
  }

  static List<Map<String, dynamic>> _extractUserList(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) {
        return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
      if (decoded is Map) {
        for (final key in ['data', 'users', 'registered_users', 'partners', 'items']) {
          final v = decoded[key];
          if (v is List) {
            return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
          }
        }
      }
    } catch (e) {
      debugPrint('PartnerCodeRegistry parse list: $e');
    }
    return [];
  }

  static String? _partnerCodeFromUser(Map<String, dynamic> user) {
    for (final key in ['partner_code', 'partnerCode', 'referral_code', 'referralCode', 'code']) {
      final v = user[key];
      if (v != null && v.toString().trim().isNotEmpty) {
        return PartnerCodeUtil.normalizeInput(v.toString());
      }
    }
    return null;
  }

  static bool _isPartnerUser(Map<String, dynamic> user) {
    final type = user['registration_type']?.toString().toLowerCase();
    if (type == 'partner') return true;
    final flag = user['is_partner'];
    return flag == true || flag == 1 || flag == '1' || flag == 'true';
  }

  static String? _userMatchesCode(Map<String, dynamic> user, List<String> candidates) {
    final stored = _partnerCodeFromUser(user);
    if (stored == null || !candidates.contains(stored)) return null;
    if (_isPartnerUser(user)) return stored;
    // Legacy rows: partner_code set without registration_type
    return stored;
  }

  static Future<Map<String, dynamic>> _readMap(SharedPreferences prefs) async {
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return {};
  }
}
