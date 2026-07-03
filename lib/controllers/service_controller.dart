import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'service_submit_result.dart';

export 'service_submit_result.dart';

class ServiceController {
  static String get _baseUrl => ApiConfig.baseUrl;

  static const _largeKeys = {
    'resume_base64',
    'crop_photo_base64',
  };

  static Map<String, dynamic> _copyPayload(Map<String, dynamic> payload) {
    return jsonDecode(jsonEncode(payload)) as Map<String, dynamic>;
  }

  static Map<String, dynamic> _stripLargeDataFields(Map<String, dynamic> payload) {
    final p = _copyPayload(payload);
    final data = p['data'];
    if (data is Map) {
      final d = Map<String, dynamic>.from(data);
      for (final k in _largeKeys) {
        d.remove(k);
      }
      p['data'] = d;
    }
    return p;
  }

  static bool _payloadHasLargeData(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is! Map) return false;
    final d = data;
    return _largeKeys.any((k) => d[k] != null && d[k].toString().isNotEmpty);
  }

  static String _shorten(String s, int maxLen) {
    if (s.length <= maxLen) return s;
    return '${s.substring(0, maxLen)}…';
  }

  static String _parseErrorBody(String body) {
    if (body.isEmpty) return 'Empty response from server';
    try {
      final j = jsonDecode(body);
      if (j is Map) {
        final msg = j['message'];
        if (msg != null && msg.toString().isNotEmpty) {
          return _shorten(msg.toString(), 280);
        }
        final errs = j['errors'];
        if (errs is Map) {
          final parts = <String>[];
          for (final e in errs.values) {
            if (e is List && e.isNotEmpty) {
              parts.add(e.first.toString());
            } else if (e != null) {
              parts.add(e.toString());
            }
            if (parts.length >= 4) break;
          }
          if (parts.isNotEmpty) {
            return _shorten(parts.join(' '), 280);
          }
        }
      }
    } catch (_) {}
    return _shorten(body.replaceAll(RegExp(r'\s+'), ' ').trim(), 220);
  }

  static Map<String, dynamic> _normalizeUserId(Map<String, dynamic> payload) {
    final p = Map<String, dynamic>.from(payload);
    final id = p['user_id'];
    if (id != null) {
      final n = int.tryParse(id.toString());
      if (n != null) p['user_id'] = n;
    }
    return p;
  }

  /// MySQL error 1366 ("Incorrect string value") often comes from **utf8mb3**
  /// columns that cannot store 4-byte UTF-8 (emoji, some symbols). This keeps
  /// the Basic Multilingual Plane only and drops disallowed control chars.
  static String _sanitizeForLegacyMysqlUtf8(String s) {
    if (s.isEmpty) return s;
    final out = <int>[];
    for (final r in s.runes) {
      if (r == 0) continue;
      if (r > 0xFFFF) continue; // supplementary plane → skip (emoji etc.)
      if (r < 0x20 && r != 0x09 && r != 0x0A && r != 0x0D) continue;
      out.add(r);
    }
    return String.fromCharCodes(out);
  }

  static dynamic _deepSanitizeStrings(dynamic value) {
    if (value == null) return null;
    if (value is String) return _sanitizeForLegacyMysqlUtf8(value);
    if (value is bool || value is int || value is double) return value;
    if (value is Map) {
      return value.map(
        (dynamic k, dynamic v) =>
            MapEntry(k.toString(), _deepSanitizeStrings(v)),
      );
    }
    if (value is List) {
      return value.map(_deepSanitizeStrings).toList();
    }
    return value;
  }

  /// Posts to `save-service`. Treats any **2xx** status as success (many Laravel apps return 200).
  /// Retries once **without** large base64 fields if the first attempt fails with 413 / 500
  /// and the payload contained attachment blobs.
  Future<ServiceSubmitResult> submitData(Map<String, dynamic> payload) async {
    final url = Uri.parse('$_baseUrl/save-service');
    final normalized = _normalizeUserId(payload);

    Future<http.Response?> doPost(Map<String, dynamic> body) async {
      try {
        final safe = _deepSanitizeStrings(
          Map<String, dynamic>.from(body),
        ) as Map<String, dynamic>;
        final encoded = jsonEncode(safe);
        return await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: encoded,
            )
            .timeout(const Duration(seconds: 45));
      } catch (e) {
        debugPrint('save-service network error: $e');
        return null;
      }
    }

    http.Response? response = await doPost(normalized);

    if (response == null) {
      return ServiceSubmitResult.failure(
        0,
        'Could not reach server. Check Wi-Fi, that your API is running, and the base URL (emulator uses 10.0.2.2).',
      );
    }

    final code = response.statusCode;
    if (code >= 200 && code < 300) {
      return ServiceSubmitResult.success(statusCode: code);
    }

    final shouldRetryStripped =
        _payloadHasLargeData(normalized) &&
        (code == 400 ||
            code == 413 ||
            code == 415 ||
            (code >= 500 && code < 600) ||
            response.body.toLowerCase().contains('too large') ||
            response.body.toLowerCase().contains('request entity'));

    if (shouldRetryStripped) {
      final stripped = _stripLargeDataFields(normalized);
      final retryResponse = await doPost(stripped);
      if (retryResponse != null &&
          retryResponse.statusCode >= 200 &&
          retryResponse.statusCode < 300) {
        return ServiceSubmitResult.success(
          statusCode: retryResponse.statusCode,
          infoMessage:
              'Saved without large photo/resume file. Add a link in the form next time, or raise server upload limits.',
        );
      }
      if (retryResponse != null) {
        return ServiceSubmitResult.failure(
          retryResponse.statusCode,
          _parseErrorBody(retryResponse.body),
        );
      }
    }

    return ServiceSubmitResult.failure(
      code,
      _parseErrorBody(response.body),
    );
  }

  Future<List<dynamic>> fetchJobs() async {
    final url = Uri.parse('$_baseUrl/jobs');
    try {
      final response = await http
          .get(
            url,
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
        throw Exception('Response is not a list: $decoded');
      }
      throw Exception('Failed to fetch jobs: HTTP ${response.statusCode} - ${response.body}');
    } catch (e) {
      debugPrint('Fetch Jobs Error: $e');
      throw Exception('Fetch Jobs Error: $e');
    }
  }
  Future<List<dynamic>> fetchBusinessJobs(int userId) async {
    final url = Uri.parse('$_baseUrl/business/jobs?user_id=$userId');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
      }
      return [];
    } catch (e) {
      debugPrint('Fetch Business Jobs Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchBusinessApplicants(int userId) async {
    final url = Uri.parse('$_baseUrl/business/applicants?user_id=$userId');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
      }
      return [];
    } catch (e) {
      debugPrint('Fetch Business Applicants Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchMarketCrops() async {
    final url = Uri.parse('$_baseUrl/market/crops');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
      }
      return [];
    } catch (e) {
      debugPrint('Fetch Market Crops Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchRegistrations() async {
    final url = Uri.parse('$_baseUrl/registrations');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
      }
      return [];
    } catch (e) {
      debugPrint('Fetch Registrations Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchFarmerInsuranceApplications() async {
    final url = Uri.parse('$_baseUrl/farmer-insurance/applications');
    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['data'] is List) {
          return decoded['data'] as List;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Fetch Farmer Insurance Applications Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchSubsidyApplications() async {
    final url = Uri.parse('$_baseUrl/subsidy/applications');
    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['data'] is List) {
          return decoded['data'] as List;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Fetch Subsidy Applications Error: $e');
      return [];
    }
  }
  Future<List<dynamic>> fetchMyJobApplications(int userId) async {
    final url = Uri.parse('$_baseUrl/my-job-applications?user_id=$userId');
    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) return decoded;
        throw Exception('Response is not a list: $decoded');
      }
      throw Exception('Failed to fetch applications: HTTP ${response.statusCode} - ${response.body}');
    } catch (e) {
      debugPrint('Fetch My Job Applications Error: $e');
      throw Exception('Fetch My Job Applications Error: $e');
    }
  }
}
