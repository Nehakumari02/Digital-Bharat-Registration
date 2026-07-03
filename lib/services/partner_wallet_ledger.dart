import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../utils/partner_code_util.dart';
import 'platform_storage.dart';

/// Referral earnings stored on-device (survives refresh on Flutter web).
/// Keyed by partner code and by partner mobile so balance can be found reliably.
abstract final class PartnerWalletLedger {
  static const _byCodeKey = 'partner_referral_ledger_by_code_v2';
  static const _byMobileKey = 'partner_referral_ledger_by_mobile_v2';

  static Future<void> addCredit({
    required String partnerCode,
    required double amount,
    String? partnerMobile,
  }) async {
    final code = PartnerCodeUtil.normalizeInput(partnerCode);
    if (code == null || amount <= 0) return;

    final byCode = await _readMap(_byCodeKey);
    byCode[code] = (_readAmount(byCode[code]) + amount).toStringAsFixed(2);
    await PlatformStorage.write(_byCodeKey, jsonEncode(byCode));
    debugPrint('PartnerWalletLedger: $code -> ${byCode[code]}');

    final mobile = _normalizeMobile(partnerMobile);
    if (mobile != null) {
      final byMobile = await _readMap(_byMobileKey);
      byMobile[mobile] = (_readAmount(byMobile[mobile]) + amount).toStringAsFixed(2);
      await PlatformStorage.write(_byMobileKey, jsonEncode(byMobile));
      debugPrint('PartnerWalletLedger: mobile $mobile -> ${byMobile[mobile]}');
    }
  }

  /// Highest balance among code variants (same earnings may be stored under one key).
  static Future<double> balanceForCodes(Iterable<String> codes) async {
    final map = await _readMap(_byCodeKey);
    var best = 0.0;
    for (final raw in codes) {
      for (final candidate in PartnerCodeUtil.validationCandidates(raw)) {
        final v = _readAmount(map[candidate]);
        if (v > best) best = v;
      }
    }
    return best;
  }

  static Future<double> balanceForMobile(String? rawMobile) async {
    final mobile = _normalizeMobile(rawMobile);
    if (mobile == null) return 0;
    final map = await _readMap(_byMobileKey);
    return _readAmount(map[mobile]);
  }

  static Future<double> resolveBalance({
    required Iterable<String> partnerCodes,
    String? partnerMobile,
  }) async {
    final fromCodes = await balanceForCodes(partnerCodes);
    final fromMobile = await balanceForMobile(partnerMobile);
    return fromCodes > fromMobile ? fromCodes : fromMobile;
  }

  static String? _normalizeMobile(String? raw) {
    if (raw == null) return null;
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return null;
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  static double _readAmount(dynamic v) =>
      double.tryParse(v?.toString() ?? '') ?? 0;

  static Future<Map<String, dynamic>> _readMap(String key) async {
    final raw = await PlatformStorage.read(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {};
  }
}
