/// Registration plan types and fee rules.
abstract final class RegistrationPlan {
  static const String typeNormal = 'normal';
  static const String typePartner = 'partner';

  static const int normalFeeInr = 599;
  static const int partnerFeeInr = 5999;

  /// Partner earns this share of the normal registration fee when their code is used.
  static const double referralCashbackRate = 0.10;

  static int feeForType(String type) =>
      type == typePartner ? partnerFeeInr : normalFeeInr;

  static double cashbackForNormalRegistration() =>
      normalFeeInr * referralCashbackRate;

  static bool isPartnerType(String type) => type == typePartner;

  static String feeLabel(int fee) => '₹$fee';
}
