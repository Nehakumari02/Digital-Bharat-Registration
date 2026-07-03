import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/lead_category.dart';
import '../models/lead_model.dart';
import '../config/api_config.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb

class LeadController {
  static String get baseUrl => ApiConfig.baseUrl;

  List<LeadModel> _filterByCategory(List<LeadModel> leads, LeadCategory category) {
    return leads
        .where(
          (lead) => category.matchesLead(
            loanType: lead.loanType,
            table: lead.tableName,
          ),
        )
        .toList();
  }

  Future<List<LeadModel>> fetchLeads(
    int myUserId, {
    required LeadCategory category,
  }) async {
    // The /leads endpoint returns ALL leads by type/table — no bank_user_id filter needed.
    // This allows every bank to see all leads and their claimed status.
    final url =
        "${LeadController.baseUrl}/leads"
        "?type=${Uri.encodeComponent(category.apiType)}"
        "&table=${Uri.encodeComponent(category.tableName)}";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint("API Response Body: ${response.body}");
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is! List) {
            debugPrint('Lead API expected a list, got: ${decoded.runtimeType}');
            return [];
          }
          final leads = decoded.map((item) => LeadModel.fromJson(item)).toList();
          return _filterByCategory(leads, category);
        } catch (e) {
          debugPrint("Lead JSON Decode Error: $e");
          return [];
        }
      } else {
        try {
          final body = jsonDecode(response.body);
          final errorMsg = (body is Map ? body['message'] : null) ?? "Server Error: ${response.statusCode}";
          throw Exception("$errorMsg (at $url)");
        } catch (_) {
          throw Exception("Server Error: ${response.statusCode} (at $url)");
        }
      }
    } catch (e) {
      debugPrint("Lead Fetch Error: $e");
      rethrow;
    }
  }



  Future<List<LeadModel>> fetchUserLoans(
    int userId, {
    required LeadCategory category,
  }) async {
    final url =
        "${LeadController.baseUrl}/my-loans?user_id=$userId"
        "&table=${Uri.encodeComponent(category.tableName)}";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is! List) return [];
        final leads = body.map((item) => LeadModel.fromJson(item)).toList();
        return _filterByCategory(leads, category);
      }
      if (response.statusCode == 404) return [];
      throw Exception('Failed to load loans (HTTP ${response.statusCode})');
    } catch (e) {
      debugPrint('User loan fetch error: $e');
      rethrow;
    }
  }

  Future<LeadModel?> fetchLatestUserLoan(
    int userId, {
    required LeadCategory category,
  }) async {
    final loans = await fetchUserLoans(userId, category: category);
    if (loans.isEmpty) return null;
    return loans.first;
  }

  Future<bool> updateLeadStatus(int id, String status, int currentBankUserId, String tableName) async {
    final String url = "${LeadController.baseUrl}/leads/update-status";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'id': id.toString(),
          'status': status,
          'bank_user_id': currentBankUserId.toString(),
          'table': tableName,
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update Lead Status Error (at $url): $e");
      return false;
    }
  }

  Future<List<LeadModel>> fetchMyLeads(
    int userId, {
    LeadCategory? category,
  }) async {
    final String url =
        "${LeadController.baseUrl}/leads/my-accepted-leads?bank_user_id=$userId";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          List<dynamic> body = jsonDecode(response.body);
          final leads = body.map((item) => LeadModel.fromJson(item)).toList();
          if (category == null) return leads;
          return _filterByCategory(leads, category);
        } catch (e) {
          debugPrint("MyLeads JSON Error: $e");
          return [];
        }
      }
      return [];
    } catch (e) {
      debugPrint("MyLeads Fetch Error (at $url): $e");
      return [];
    }
  }

  @Deprecated('Use fetchLeads with LeadCategory instead')
  Future<List<LeadModel>> fetchAllLeads(int myUserId, {String? type}) async {
    LeadCategory? category;
    for (final c in LeadCategory.values) {
      if (c.apiType == type) {
        category = c;
        break;
      }
    }
    if (category == null) {
      throw ArgumentError('Unknown lead type: $type');
    }
    return fetchLeads(myUserId, category: category);
  }
}