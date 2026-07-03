import '../services/partner_code_registry.dart';
import '../constants/registration_plan.dart';
import 'partner_code_util.dart';
import 'user_profile_helpers.dart';

/// All partner codes that might identify the same partner (API, registry, generated).
abstract final class PartnerCodeResolver {
  static Future<List<String>> allCodesForUser(Map<String, dynamic> user) async {
    final normalized = UserProfileHelpers.normalize(user);
    final set = <String>{};

    void add(String? raw) {
      for (final c in PartnerCodeUtil.validationCandidates(raw)) {
        set.add(c);
      }
    }

    add(UserProfileHelpers.partnerCode(normalized));

    final mobile = normalized['mobile']?.toString();
    if (mobile != null && mobile.isNotEmpty) {
      add(await PartnerCodeRegistry.partnerCodeForMobile(mobile));
      add(PartnerCodeUtil.generate(seed: mobile));
    }

    final email = normalized['email']?.toString();
    if (email != null && email.isNotEmpty) {
      add(PartnerCodeUtil.generate(seed: email));
    }

    if (mobile != null && mobile.isNotEmpty) {
      add(PartnerCodeUtil.generate(seed: mobile));
    }

    if (email != null && email.isNotEmpty) {
      add(PartnerCodeUtil.generate(seed: email));
    }

    return set.toList();
  }

  static Future<String?> primaryCode(Map<String, dynamic> user) async {
    final codes = await allCodesForUser(user);
    return codes.isNotEmpty ? codes.first : null;
  }
}
