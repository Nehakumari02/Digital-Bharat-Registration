import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../constants/registration_plan.dart';
import '../utils/partner_code_util.dart';
import 'api_http.dart';

/// Estimates partner earnings by counting users who registered with a partner code.
abstract final class PartnerReferralBalance {
  static Future<double> earningsForPartnerCode(String rawCode) async {
    final code = PartnerCodeUtil.normalizeInput(rawCode);
    if (code == null) return 0;

    final count = await countReferralsForCode(code);
    return count * RegistrationPlan.cashbackForNormalRegistration();
  }

  static Future<int> countReferralsForCode(String code) async {
    final base = ApiConfig.baseUrl;
    final listUrls = [
      '$base/users',
      '$base/registered-users',
      '$base/all-users',
      '$base/get-users',
    ];

    for (final urlStr in listUrls) {
      try {
        final response = await tryGet(Uri.parse(urlStr));
        if (response == null || response.statusCode != 200) continue;

        final users = _extractUserList(response.body);
        var count = 0;
        for (final user in users) {
          if (_isReferredByCode(user, code)) count++;
        }
        if (count > 0) {
          debugPrint('PartnerReferralBalance: $count referrals for $code');
          return count;
        }
      } catch (e) {
        debugPrint('PartnerReferralBalance scan $urlStr: $e');
      }
    }
    return 0;
  }

  static bool _isReferredByCode(Map<String, dynamic> user, String partnerCode) {
    final type = user['registration_type']?.toString().toLowerCase();
    if (type == RegistrationPlan.typePartner) return false;

    for (final key in [
      'referred_partner_code',
      'referral_code',
      'partner_code_used',
      'used_partner_code',
    ]) {
      final v = PartnerCodeUtil.normalizeInput(user[key]?.toString() ?? '');
      if (v == partnerCode) return true;
    }
    // Some APIs store the code used at signup on `partner_code` for normal users.
    final fee = int.tryParse(user['registration_fee']?.toString() ?? '');
    if (fee != RegistrationPlan.partnerFeeInr) {
      final used = PartnerCodeUtil.normalizeInput(
        user['partner_code']?.toString() ?? '',
      );
      if (used == partnerCode) return true;
    }
    return false;
  }

  static List<Map<String, dynamic>> _extractUserList(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      if (decoded is Map) {
        for (final key in ['data', 'users', 'registered_users', 'items']) {
          final v = decoded[key];
          if (v is List) {
            return v
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          }
        }
      }
    } catch (_) {}
    return [];
  }
}
