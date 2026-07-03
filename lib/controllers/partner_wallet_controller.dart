import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../constants/registration_plan.dart';
import '../services/api_http.dart';
import '../services/partner_code_registry.dart';
import '../services/partner_referral_balance.dart';
import '../services/partner_wallet_ledger.dart';
import '../services/partner_wallet_store.dart';
import '../utils/partner_code_resolver.dart';
import '../utils/partner_code_util.dart';

class PartnerWalletInfo {
  const PartnerWalletInfo({
    required this.balance,
    required this.partnerCode,
    this.totalCashbackEarned,
    this.referralCount,
    this.serverBalance = 0,
    this.localBalance = 0,
    this.deviceLedgerBalance = 0,
    this.referralEarnings = 0,
  });

  final double balance;
  final double serverBalance;
  final double localBalance;
  final double deviceLedgerBalance;
  final double referralEarnings;
  final String partnerCode;
  final double? totalCashbackEarned;
  final int? referralCount;

  factory PartnerWalletInfo.fromJson(Map<String, dynamic> json) {
    return PartnerWalletInfo(
      balance: double.tryParse(
            (json['wallet_balance'] ?? json['balance'] ?? '0').toString(),
          ) ??
          0,
      serverBalance: double.tryParse(
            (json['wallet_balance'] ?? json['balance'] ?? '0').toString(),
          ) ??
          0,
      partnerCode: (json['partner_code'] ?? json['code'] ?? '').toString(),
      totalCashbackEarned: double.tryParse(
        (json['total_cashback'] ?? json['total_cashback_earned'] ?? '').toString(),
      ),
      referralCount: int.tryParse(
        (json['referral_count'] ?? json['referrals'] ?? '').toString(),
      ),
    );
  }
}

class ReferralCreditResult {
  const ReferralCreditResult({
    required this.success,
    this.creditedAmount,
    this.newBalance,
    this.syncedToServer = false,
    this.message,
  });

  final bool success;
  final double? creditedAmount;
  final double? newBalance;
  final bool syncedToServer;
  final String? message;
}

class PartnerWalletController {
  static String get _baseUrl => ApiConfig.baseUrl;

  Future<PartnerWalletInfo?> fetchWallet(
    int? userId, {
    String? partnerCode,
    double profileBalance = 0,
    Map<String, dynamic>? user,
  }) async {
    final userMap = user ?? <String, dynamic>{if (userId != null) 'id': userId};
    final allCodes = await PartnerCodeResolver.allCodesForUser(userMap);
    final effectiveCode = partnerCode != null
        ? PartnerCodeUtil.normalizeInput(partnerCode)
        : (allCodes.isNotEmpty ? allCodes.first : null);

    double serverBalance = 0;
    PartnerWalletInfo? info;
    var loadedFromApi = false;

    if (userId != null) {
    final url = Uri.parse('$_baseUrl/partner-wallet?user_id=$userId');
    try {
      final response = await tryGet(url);
      if (response != null && response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          info = PartnerWalletInfo.fromJson(body);
        } else if (body is Map) {
          info = PartnerWalletInfo.fromJson(Map<String, dynamic>.from(body));
        }
        if (info != null) {
          serverBalance = info.serverBalance;
          loadedFromApi = true;
        }
      }
    } catch (e) {
      debugPrint('partner-wallet fetch: $e');
    }

    if (serverBalance <= 0) {
      final fromUser = await _walletFromUserRecord(userId);
      if (fromUser > serverBalance) serverBalance = fromUser;
    }
    }

    final mobile = userMap['mobile']?.toString();
    final deviceLedger = await PartnerWalletLedger.resolveBalance(
      partnerCodes: allCodes.isNotEmpty ? allCodes : [if (effectiveCode != null) effectiveCode],
      partnerMobile: mobile,
    );

    var referralEarnings = 0.0;
    var referralCount = info?.referralCount;
    if (effectiveCode != null) {
      referralEarnings =
          await PartnerReferralBalance.earningsForPartnerCode(effectiveCode);
      if (referralCount == null && referralEarnings > 0) {
        referralCount = (referralEarnings /
                RegistrationPlan.cashbackForNormalRegistration())
            .round();
      }
    }

    if (loadedFromApi &&
        effectiveCode != null &&
        serverBalance > 0) {
      final ledger = await PartnerWalletStore.balanceForCode(effectiveCode);
      if (serverBalance >= ledger - 0.01 && ledger > 0) {
        await PartnerWalletStore.markAllSynced(effectiveCode);
      }
    }

    final pendingLocal = effectiveCode != null
        ? await PartnerWalletStore.unsyncedBalanceForCode(effectiveCode)
        : 0.0;

    // Avoid compounding on refresh: profileBalance may already include local credits.
    // Prefer authoritative sources (API/server/referral scan/device ledger) first.
    // Only fallback to profileBalance when no other source has any value.
    final computedBase = [serverBalance, referralEarnings, deviceLedger]
        .reduce(math.max);
    final apiOrProfile = computedBase > 0
        ? computedBase
        : (loadedFromApi ? serverBalance : profileBalance);

    final base = apiOrProfile;
    final total = base + pendingLocal;

    debugPrint(
      'Wallet userId=$userId codes=$allCodes api=$apiOrProfile '
      'device=$deviceLedger referrals=$referralEarnings total=$total',
    );

    return PartnerWalletInfo(
      balance: total,
      serverBalance: apiOrProfile,
      localBalance: pendingLocal,
      deviceLedgerBalance: deviceLedger,
      referralEarnings: referralEarnings,
      partnerCode: effectiveCode ?? info?.partnerCode ?? '',
      totalCashbackEarned: info?.totalCashbackEarned ?? referralEarnings,
      referralCount: referralCount,
    );
  }

  static Future<double> _walletFromUserRecord(int userId) async {
    final paths = [
      '$_baseUrl/users/$userId',
      '$_baseUrl/user/$userId',
    ];
    for (final urlStr in paths) {
      try {
        final response = await tryGet(Uri.parse(urlStr));
        if (response == null || response.statusCode != 200) continue;
        final body = jsonDecode(response.body);
        if (body is! Map) continue;
        final m = Map<String, dynamic>.from(body);
        final user = m['user'] ?? m['data'] ?? m;
        if (user is Map) {
          final u = Map<String, dynamic>.from(user);
          final b = double.tryParse(
            (u['wallet_balance'] ?? u['walletBalance'] ?? '0').toString(),
          );
          if (b != null && b > 0) return b;
        }
      } catch (e) {
        debugPrint('wallet user record $urlStr: $e');
      }
    }
    return 0;
  }

  Future<ReferralCreditResult> applyReferralCredit({
    required String partnerCode,
    required double amount,
    String? refereeName,
    String? refereeMobile,
    int? refereeUserId,
    String? partnerMobile,
  }) async {
    final code = PartnerCodeUtil.normalizeInput(partnerCode);
    if (code == null) {
      return const ReferralCreditResult(success: false, message: 'Invalid partner code');
    }

    final partnerUserId = await PartnerCodeRegistry.partnerIdForCode(code);

    final body = {
      'partner_code': code,
      'referral_code': code,
      'amount': amount,
      'cashback_amount': amount,
      'referee_name': refereeName,
      'referee_mobile': refereeMobile,
      if (refereeUserId != null) 'referee_user_id': refereeUserId,
      if (partnerUserId != null) 'partner_user_id': partnerUserId,
    };

    final urls = [
      Uri.parse('$_baseUrl/partner-wallet/credit'),
      Uri.parse('$_baseUrl/referral-credit'),
      Uri.parse('$_baseUrl/apply-referral-cashback'),
    ];

    for (final url in urls) {
      final response = await safePost(url, body: jsonEncode(body));
      if (response == null) continue;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await PartnerWalletLedger.addCredit(
          partnerCode: code,
          amount: amount,
          partnerMobile: partnerMobile,
        );
        try {
          final decoded = jsonDecode(response.body);
          final newBal = decoded is Map
              ? double.tryParse(
                  (decoded['wallet_balance'] ??
                          decoded['new_balance'] ??
                          decoded['balance'] ??
                          '')
                      .toString(),
                )
              : null;
          if (newBal != null) {
            return ReferralCreditResult(
              success: true,
              creditedAmount: amount,
              newBalance: newBal,
              syncedToServer: true,
              message: 'Partner wallet updated on server',
            );
          }
        } catch (_) {}
        return ReferralCreditResult(
          success: true,
          creditedAmount: amount,
          syncedToServer: true,
        );
      }
    }

    await PartnerWalletLedger.addCredit(
      partnerCode: code,
      amount: amount,
      partnerMobile: partnerMobile,
    );

    await PartnerWalletStore.credit(
      partnerCode: code,
      amount: amount,
      refereeName: refereeName,
      refereeMobile: refereeMobile,
      syncedToServer: false,
    );

    final ledgerBal = await PartnerWalletLedger.balanceForCodes([code]);

    return ReferralCreditResult(
      success: true,
      creditedAmount: amount,
      newBalance: ledgerBal,
      syncedToServer: false,
      message: '₹${amount.toStringAsFixed(2)} added to partner wallet on this device.',
    );
  }

  static double defaultCashbackAmount() => RegistrationPlan.cashbackForNormalRegistration();
}
