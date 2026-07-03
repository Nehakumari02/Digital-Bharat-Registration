import 'dart:math';

/// Client-side partner code helper (server should assign the authoritative code on register).
abstract final class PartnerCodeUtil {
  static final _random = Random();

  static final _codePattern = RegExp(r'^PRT-[A-Z0-9]{4,12}$');

  /// Format: PRT-XXXXXX (6 alphanumeric chars).
  static String generate({String? seed}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final buffer = StringBuffer('PRT-');
    if (seed != null && seed.isNotEmpty) {
      final hash = seed.codeUnits.fold<int>(0, (a, b) => a + b);
      for (var i = 0; i < 6; i++) {
        buffer.write(chars[(hash + i * 17) % chars.length]);
      }
      return buffer.toString();
    }
    for (var i = 0; i < 6; i++) {
      buffer.write(chars[_random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  static String? normalizeInput(String? raw) {
    if (raw == null) return null;
    var s = raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (s.isEmpty) return null;
    if (!s.startsWith('PRT-')) {
      s = s.startsWith('PRT') ? 'PRT-${s.substring(3)}' : 'PRT-$s';
    }
    return s;
  }

  /// Variants to try when validating (user may omit prefix or add extra dashes).
  static List<String> validationCandidates(String? raw) {
    final primary = normalizeInput(raw);
    if (primary == null) return [];

    final set = <String>{primary};
    final bare = raw?.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '') ?? '';
    if (bare.isNotEmpty) {
      set.add(bare);
      if (!bare.startsWith('PRT-')) {
        set.add('PRT-$bare');
      }
    }
    final noDashes = primary.replaceAll('-', '');
    if (noDashes.startsWith('PRT') && noDashes.length > 3) {
      set.add('PRT-${noDashes.substring(3)}');
    }
    return set.toList();
  }

  static bool isWellFormed(String code) => _codePattern.hasMatch(code);
}
