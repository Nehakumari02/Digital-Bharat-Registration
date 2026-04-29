import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lead_model.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb

class LeadController {
  // Use the same dynamic IP logic as other controllers
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }

  Future<List<LeadModel>> fetchAllLeads(int myUserId) async {
    final String url = "${LeadController.baseUrl}/leads?bank_user_id=$myUserId";
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
          return body.map((item) => LeadModel.fromJson(item)).toList();
        } catch (e) {
          debugPrint("Lead JSON Decode Error: $e");
          return [];
        }
      } else {
        try {
          final body = jsonDecode(response.body);
          final errorMsg = (body is Map ? body['message'] : null) ?? "Server Error: ${response.statusCode}";
          throw Exception("$errorMsg (at $url)");
        } catch (e) {
          throw Exception("Server Error: ${response.statusCode} (at $url)");
        }
      }
    } catch (e) {
      debugPrint("Lead Fetch Error: $e");
      rethrow; // Re-throw to be caught by FutureBuilder
    }
  }

  Future<bool> updateLeadStatus(int id, String status, int currentBankUserId) async {
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
          'bank_user_id': currentBankUserId.toString()
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update Lead Status Error (at $url): $e");
      return false;
    }
  }

  Future<List<LeadModel>> fetchMyLeads(int userId) async {
    final String url = "${LeadController.baseUrl}/leads/my-accepted-leads?bank_user_id=$userId";
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
          return body.map((item) => LeadModel.fromJson(item)).toList();
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
}