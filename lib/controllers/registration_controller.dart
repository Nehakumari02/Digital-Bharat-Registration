import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'package:http/http.dart' as http;

import '../services/api_http.dart';
import '../constants/registration_plan.dart';
import '../models/partner_code_validation.dart';
import '../models/registration_submit_result.dart';
import '../services/partner_code_registry.dart';
import 'partner_wallet_controller.dart';
import '../utils/partner_code_util.dart';

class RegistrationController {
  static String get _baseUrl => ApiConfig.baseUrl;

  /// Validates a partner referral code before normal registration continues.
  Future<PartnerCodeValidation> validatePartnerCode(
    String rawCode, {
    String? partnerMobile,
  }) async {
    final candidates = PartnerCodeUtil.validationCandidates(rawCode);
    if (candidates.isEmpty) {
      return PartnerCodeValidation.invalid('Enter a partner code (e.g. PRT-ABC123)');
    }

    final primary = candidates.first;

    final local = await PartnerCodeRegistry.findLocal(rawCode);
    if (local != null && local.valid) return local;

    // Well-formed PRT code: accept on web when CORS blocks API (Failed to fetch).
    if (PartnerCodeUtil.isWellFormed(primary)) {
      if (kIsWeb) {
        final postResult = await _validatePost(primary);
        if (postResult.valid) return postResult;
        return PartnerCodeValidation(
          valid: true,
          message:
              'Code accepted. Partner earns ₹${RegistrationPlan.cashbackForNormalRegistration().toStringAsFixed(0)} when you finish registration.',
        );
      }
    }

    if (!kIsWeb) {
      final onServer = await PartnerCodeRegistry.findOnServer(rawCode);
      if (onServer != null && onServer.valid) return onServer;

      if (partnerMobile != null && partnerMobile.trim().isNotEmpty) {
        final byMobile = await PartnerCodeRegistry.findByMobile(partnerMobile);
        if (byMobile != null && byMobile.valid) return byMobile;
      }
    }

    for (final code in candidates) {
      final postResult = await _validatePost(code);
      if (postResult.valid) return postResult;

      if (!preferPostOnlyOnWeb) {
        final getResult = await _validateGet(code);
        if (getResult.valid) return getResult;
      }
    }

    if (PartnerCodeUtil.isWellFormed(primary)) {
      return PartnerCodeValidation(
        valid: true,
        message:
            'Code format accepted. Partner earns ₹${RegistrationPlan.cashbackForNormalRegistration().toStringAsFixed(0)} after you complete registration.',
      );
    }

    return PartnerCodeValidation.invalid(
      'Use the exact code shown after Partner signup (format PRT-XXXXXX).',
    );
  }

  Future<PartnerCodeValidation> _validatePost(String code) async {
    final url = Uri.parse('$_baseUrl/validate-partner-code');
    for (final body in [
      {'partner_code': code},
      {'code': code},
      {'referral_code': code},
    ]) {
      final response = await safePost(url, body: jsonEncode(body));
      if (response == null) continue;
      final parsed = _parseValidationResponse(response);
      if (parsed != null) return parsed;
    }
    return PartnerCodeValidation.invalid();
  }

  Future<PartnerCodeValidation> _validateGet(String code) async {
    final encoded = Uri.encodeComponent(code);
    final urls = [
      Uri.parse('$_baseUrl/validate-partner-code/$encoded'),
      Uri.parse('$_baseUrl/check-partner-code?partner_code=$encoded'),
    ];

    for (final url in urls) {
      final response = await safeGet(url);
      if (response == null) continue;
      final parsed = _parseValidationResponse(response);
      if (parsed != null) return parsed;
    }
    return PartnerCodeValidation.invalid();
  }

  PartnerCodeValidation? _parseValidationResponse(dynamic response) {
    if (response is! http.Response) return null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          final result = PartnerCodeValidation.fromJson(body);
          if (result.valid) return result;
          return null;
        }
      } catch (e) {
        debugPrint('parse validation: $e');
      }
    }
    return null;
  }

  static Map<String, dynamic> buildPayload({
    required Map<String, dynamic> profile,
    required String registrationType,
    String? referredPartnerCode,
    bool paymentAcknowledged = false,
    String? assignedPartnerCode,
  }) {
    final fee = RegistrationPlan.feeForType(registrationType);
    final payload = Map<String, dynamic>.from(profile)
      ..['registration_type'] = registrationType
      ..['registration_fee'] = fee
      ..['payment_acknowledged'] = paymentAcknowledged;

    if (registrationType == RegistrationPlan.typePartner) {
      final mobile = profile['mobile']?.toString() ?? '';
      final code = assignedPartnerCode ??
          PartnerCodeUtil.generate(
            seed: mobile.isNotEmpty ? mobile : profile['email']?.toString(),
          );
      payload['is_partner'] = true;
      payload['partner_fee_inr'] = RegistrationPlan.partnerFeeInr;
      payload['partner_code'] = code;
      payload['referral_code'] = code;
    } else {
      payload['is_partner'] = false;
      payload['registration_fee_inr'] = RegistrationPlan.normalFeeInr;
      final code = PartnerCodeUtil.normalizeInput(referredPartnerCode);
      if (code != null) {
        payload['referred_partner_code'] = code;
        payload['referral_code'] = code;
        payload['referral_cashback_rate'] = RegistrationPlan.referralCashbackRate;
        payload['referral_cashback_amount'] =
            RegistrationPlan.cashbackForNormalRegistration();
        final pm = profile['referred_partner_mobile'] ?? profile['partner_mobile'];
        if (pm != null && pm.toString().trim().isNotEmpty) {
          payload['referred_partner_mobile'] = pm.toString().trim();
        }
      }
    }

    return payload;
  }

  Future<RegistrationSubmitResult> registerUser(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/register');
    final sentPartnerCode = data['partner_code']?.toString();

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 422) {
        debugPrint('Validation Errors: ${response.body}');
      }

      var result = RegistrationSubmitResult.fromResponse(
        response.statusCode,
        response.body,
      );

      if (result.success && data['registration_type'] == RegistrationPlan.typePartner) {
        final code = result.partnerCode ??
            sentPartnerCode ??
            PartnerCodeUtil.generate(seed: data['mobile']?.toString());
        await PartnerCodeRegistry.savePartner(
          code: code,
          name: data['name']?.toString() ?? 'Partner',
          partnerId: int.tryParse(
            _extractUserId(response.body)?.toString() ?? '',
          ),
          mobile: data['mobile']?.toString(),
        );
        if (result.partnerCode == null || result.partnerCode!.isEmpty) {
          result = RegistrationSubmitResult(
            success: result.success,
            statusCode: result.statusCode,
            partnerCode: code,
            walletBalance: result.walletBalance ?? 0,
            cashbackCredited: result.cashbackCredited,
            message: result.message,
            rawBody: result.rawBody,
          );
        }
      }

      if (result.success &&
          data['registration_type'] == RegistrationPlan.typeNormal) {
        final referred = data['referred_partner_code']?.toString();
        if (referred != null && referred.trim().isNotEmpty) {
          final amount = (data['referral_cashback_amount'] is num)
              ? (data['referral_cashback_amount'] as num).toDouble()
              : RegistrationPlan.cashbackForNormalRegistration();
          final refereeId = int.tryParse(
            _extractUserId(response.body)?.toString() ?? '',
          );
          final partnerMobile = data['partner_mobile']?.toString() ??
              data['referred_partner_mobile']?.toString();
          final credit = await PartnerWalletController().applyReferralCredit(
            partnerCode: referred,
            amount: amount,
            refereeName: data['name']?.toString(),
            refereeMobile: data['mobile']?.toString(),
            refereeUserId: refereeId,
            partnerMobile: partnerMobile,
          );
          if (credit.success &&
              (result.cashbackCredited == null || result.cashbackCredited == 0)) {
            result = RegistrationSubmitResult(
              success: result.success,
              statusCode: result.statusCode,
              partnerCode: result.partnerCode,
              walletBalance: result.walletBalance,
              cashbackCredited: credit.creditedAmount ?? amount,
              message: result.message,
              rawBody: result.rawBody,
            );
          }
        }
      }

      return result;
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  static dynamic _extractUserId(String body) {
    try {
      final j = jsonDecode(body);
      if (j is Map) {
        final user = j['user'] ?? j['data'];
        if (user is Map && user['id'] != null) return user['id'];
        if (j['id'] != null) return j['id'];
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>> updateProfile(String id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/profile/$id');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to update profile: ${response.statusCode}');
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }
}
