import '../constants/registration_plan.dart';
import 'partner_code_util.dart';

abstract final class UserProfileHelpers {
  /// Call after login/register so partner flags work even if API omits some fields.
  static Map<String, dynamic> normalize(Map<String, dynamic> raw) {
    final user = Map<String, dynamic>.from(raw);

    final fee = int.tryParse(user['registration_fee']?.toString() ?? '');
    if (fee == RegistrationPlan.partnerFeeInr) {
      user['registration_type'] ??= RegistrationPlan.typePartner;
      user['is_partner'] = true;
    }

    final type = user['registration_type']?.toString().toLowerCase();
    if (type == RegistrationPlan.typePartner) {
      user['is_partner'] = true;
    }

    final code = user['partner_code']?.toString().trim();
    if (code != null && code.isNotEmpty) {
      user['is_partner'] = true;
    }

    final flag = user['is_partner'];
    if (flag == true || flag == 1 || flag == '1' || flag == 'true') {
      user['is_partner'] = true;
    }

    return user;
  }

  static bool isPartner(Map<String, dynamic> user) {
    final normalized = normalize(user);
    return normalized['is_partner'] == true;
  }

  /// Wallet screen is available for every logged-in user.
  static bool showWalletMenu(Map<String, dynamic> user) => true;

  static String? partnerCode(Map<String, dynamic> user) {
    final c = user['partner_code']?.toString().trim();
    if (c != null && c.isNotEmpty) {
      return PartnerCodeUtil.normalizeInput(c);
    }
    final alt = user['referral_code']?.toString().trim();
    if (alt != null && alt.isNotEmpty) {
      return PartnerCodeUtil.normalizeInput(alt);
    }
    return null;
  }

  /// Code to show in wallet UI (profile/API or Partner registration seed).
  static String? displayPartnerCode(Map<String, dynamic> user) {
    final normalized = normalize(user);
    final existing = partnerCode(normalized);
    if (existing != null) return existing;
    if (isPartner(normalized) ||
        registrationFee(normalized) == RegistrationPlan.partnerFeeInr) {
      final seed = normalized['mobile']?.toString().trim();
      final email = normalized['email']?.toString().trim();
      return PartnerCodeUtil.generate(
        seed: (seed != null && seed.isNotEmpty) ? seed : email,
      );
    }
    return null;
  }

  static double walletBalance(Map<String, dynamic> user) {
    final v = user['wallet_balance'] ?? user['walletBalance'];
    if (v == null) return 0;
    return double.tryParse(v.toString()) ?? 0;
  }

  static bool isNormalAccount(Map<String, dynamic> user) {
    final normalized = normalize(user);
    if (isPartner(normalized)) return false;
    final fee = int.tryParse(normalized['registration_fee']?.toString() ?? '');
    return fee == null || fee == RegistrationPlan.normalFeeInr;
  }

  static String accountPlanLabel(Map<String, dynamic> user) {
    final normalized = normalize(user);
    if (isPartner(normalized) ||
        registrationFee(normalized) == RegistrationPlan.partnerFeeInr) {
      return 'Partner (₹${RegistrationPlan.partnerFeeInr})';
    }
    return 'Normal (₹${RegistrationPlan.normalFeeInr})';
  }

  static int registrationFee(Map<String, dynamic> user) {
    final v = user['registration_fee'];
    if (v != null) {
      final n = int.tryParse(v.toString());
      if (n != null) return n;
    }
    return isPartner(user) ? RegistrationPlan.partnerFeeInr : RegistrationPlan.normalFeeInr;
  }
}
