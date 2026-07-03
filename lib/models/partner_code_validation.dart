class PartnerCodeValidation {
  const PartnerCodeValidation({
    required this.valid,
    this.partnerName,
    this.partnerId,
    this.message,
  });

  final bool valid;
  final String? partnerName;
  final int? partnerId;
  final String? message;

  factory PartnerCodeValidation.invalid([String? message]) =>
      PartnerCodeValidation(valid: false, message: message ?? 'Invalid partner code');

  factory PartnerCodeValidation.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final Map<String, dynamic> m = data is Map
        ? Map<String, dynamic>.from(data)
        : json;

    final partner = m['partner'];
    final user = m['user'];
    final partnerMap = partner is Map ? Map<String, dynamic>.from(partner) : null;
    final userMap = user is Map ? Map<String, dynamic>.from(user) : null;

    if (partnerMap != null || (userMap != null && _hasPartnerCode(userMap))) {
      return PartnerCodeValidation(
        valid: true,
        partnerName: partnerMap?['name']?.toString() ??
            userMap?['name']?.toString(),
        partnerId: int.tryParse(
          partnerMap?['id']?.toString() ??
              userMap?['id']?.toString() ??
              '',
        ),
        message: m['message']?.toString(),
      );
    }

    final msg = (m['message'] ?? json['message'])?.toString().toLowerCase() ?? '';
    if (msg.contains('not found') ||
        msg.contains('invalid') ||
        msg.contains('does not exist')) {
      return PartnerCodeValidation.invalid(
        m['message']?.toString() ?? json['message']?.toString() ?? 'Invalid partner code',
      );
    }

    final explicitInvalid = m['valid'] == false || m['success'] == false;
    final valid = !explicitInvalid &&
        (m['valid'] == true ||
            m['success'] == true ||
            m['status'] == 'ok' ||
            m['exists'] == true ||
            m['found'] == true);

    return PartnerCodeValidation(
      valid: valid,
      partnerName: m['partner_name']?.toString() ??
          m['name']?.toString() ??
          partnerMap?['name']?.toString(),
      partnerId: int.tryParse(
        m['partner_id']?.toString() ??
            m['id']?.toString() ??
            partnerMap?['id']?.toString() ??
            '',
      ),
      message: m['message']?.toString() ?? json['message']?.toString(),
    );
  }

  static bool _hasPartnerCode(Map<String, dynamic> user) {
    for (final key in ['partner_code', 'partnerCode', 'referral_code']) {
      final v = user[key];
      if (v != null && v.toString().trim().isNotEmpty) return true;
    }
    return false;
  }
}
