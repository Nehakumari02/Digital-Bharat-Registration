import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/registration_plan.dart';
import '../utils/partner_code_util.dart';

/// Local referral ledger when the API does not yet persist wallet credits.
class ReferralCreditEntry {
  ReferralCreditEntry({
    required this.amount,
    required this.refereeName,
    required this.at,
    this.refereeMobile,
    this.syncedToServer = false,
  });

  final double amount;
  final String refereeName;
  final String? refereeMobile;
  final DateTime at;
  final bool syncedToServer;

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'referee_name': refereeName,
        'referee_mobile': refereeMobile,
        'at': at.toIso8601String(),
        'synced_to_server': syncedToServer,
      };

  factory ReferralCreditEntry.fromJson(Map<String, dynamic> json) {
    return ReferralCreditEntry(
      amount: double.tryParse(json['amount']?.toString() ?? '') ??
          RegistrationPlan.cashbackForNormalRegistration(),
      refereeName: json['referee_name']?.toString() ?? 'New user',
      refereeMobile: json['referee_mobile']?.toString(),
      at: DateTime.tryParse(json['at']?.toString() ?? '') ?? DateTime.now(),
      syncedToServer: json['synced_to_server'] == true,
    );
  }
}

abstract final class PartnerWalletStore {
  static const _balanceKey = 'partner_wallet_balance_by_code_v1';
  static const _historyKey = 'partner_referral_history_v1';

  static Future<double> balanceForCode(String partnerCode) async {
    final code = PartnerCodeUtil.normalizeInput(partnerCode);
    if (code == null) return 0;
    final prefs = await SharedPreferences.getInstance();
    final map = _readBalanceMap(prefs);
    return double.tryParse(map[code]?.toString() ?? '') ?? 0;
  }

  /// Credits recorded on-device that are not yet reflected on the server.
  static Future<double> unsyncedBalanceForCode(String partnerCode) async {
    final history = await historyForCode(partnerCode);
    var sum = 0.0;
    for (final e in history) {
      if (!e.syncedToServer) sum += e.amount;
    }
    return sum;
  }

  static Future<void> markAllSynced(String partnerCode) async {
    final code = PartnerCodeUtil.normalizeInput(partnerCode);
    if (code == null) return;

    final prefs = await SharedPreferences.getInstance();
    final balances = _readBalanceMap(prefs);
    balances[code] = 0;
    await prefs.setString(_balanceKey, jsonEncode(balances));

    final history = await historyForCode(code);
    if (history.isEmpty) return;

    final updated = history
        .map(
          (e) => ReferralCreditEntry(
            amount: e.amount,
            refereeName: e.refereeName,
            refereeMobile: e.refereeMobile,
            at: e.at,
            syncedToServer: true,
          ),
        )
        .toList();
    await prefs.setString(
      '$_historyKey::$code',
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<ReferralCreditEntry>> historyForCode(String partnerCode) async {
    final code = PartnerCodeUtil.normalizeInput(partnerCode);
    if (code == null) return [];
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_historyKey::$code');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map>()
          .map((e) => ReferralCreditEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.at.compareTo(a.at));
    } catch (_) {
      return [];
    }
  }

  /// Credits partner wallet locally (e.g. after a referral registers on this device).
  static Future<double> credit({
    required String partnerCode,
    required double amount,
    String? refereeName,
    String? refereeMobile,
    bool syncedToServer = false,
  }) async {
    final code = PartnerCodeUtil.normalizeInput(partnerCode);
    if (code == null) return 0;

    final prefs = await SharedPreferences.getInstance();
    final balances = _readBalanceMap(prefs);
    final prev = double.tryParse(balances[code]?.toString() ?? '') ?? 0;
    final next = prev + amount;
    balances[code] = next;
    await prefs.setString(_balanceKey, jsonEncode(balances));

    final history = await historyForCode(code);
    history.insert(
      0,
      ReferralCreditEntry(
        amount: amount,
        refereeName: refereeName ?? 'New registration',
        refereeMobile: refereeMobile,
        at: DateTime.now(),
        syncedToServer: syncedToServer,
      ),
    );
    await prefs.setString(
      '$_historyKey::$code',
      jsonEncode(history.take(50).map((e) => e.toJson()).toList()),
    );

    return next;
  }

  static Map<String, dynamic> _readBalanceMap(SharedPreferences prefs) {
    final raw = prefs.getString(_balanceKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return {};
  }
}
