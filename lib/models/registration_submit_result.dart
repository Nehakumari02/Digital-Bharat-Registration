import 'dart:convert';

class RegistrationSubmitResult {
  const RegistrationSubmitResult({
    required this.success,
    required this.statusCode,
    this.partnerCode,
    this.walletBalance,
    this.cashbackCredited,
    this.message,
    this.rawBody,
  });

  final bool success;
  final int statusCode;
  final String? partnerCode;
  final double? walletBalance;
  final double? cashbackCredited;
  final String? message;
  final String? rawBody;

  factory RegistrationSubmitResult.fromResponse(int statusCode, String body) {
    if (statusCode < 200 || statusCode >= 300) {
      return RegistrationSubmitResult(
        success: false,
        statusCode: statusCode,
        rawBody: body,
        message: _parseMessage(body) ?? 'Registration failed ($statusCode)',
      );
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final user = decoded['user'];
        final nested = decoded['data'];
        final partnerCode = _pickString(decoded, ['partner_code', 'partnerCode']) ??
            (user is Map ? _pickString(Map<String, dynamic>.from(user), ['partner_code', 'partnerCode']) : null) ??
            (nested is Map
                ? _pickString(Map<String, dynamic>.from(nested), ['partner_code', 'partnerCode'])
                : null);

        final wallet = _pickDouble(decoded, ['wallet_balance', 'walletBalance']) ??
            (user is Map
                ? _pickDouble(Map<String, dynamic>.from(user), ['wallet_balance', 'walletBalance'])
                : null);

        final cashback = _pickDouble(decoded, [
          'cashback_credited',
          'cashback_credited_to_partner',
          'partner_cashback',
        ]);

        return RegistrationSubmitResult(
          success: true,
          statusCode: statusCode,
          partnerCode: partnerCode,
          walletBalance: wallet,
          cashbackCredited: cashback,
          message: decoded['message']?.toString(),
          rawBody: body,
        );
      }
    } catch (_) {}

    return RegistrationSubmitResult(
      success: true,
      statusCode: statusCode,
      rawBody: body,
      message: 'Registration successful',
    );
  }

  static String? _pickString(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
    }
    return null;
  }

  static double? _pickDouble(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v == null) continue;
      final n = double.tryParse(v.toString());
      if (n != null) return n;
    }
    return null;
  }

  static String? _parseMessage(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {
      final match = RegExp(r'"message"\s*:\s*"([^"]*)"').firstMatch(body);
      return match?.group(1);
    }
    return body.length > 120 ? '${body.substring(0, 120)}…' : body;
  }
}
