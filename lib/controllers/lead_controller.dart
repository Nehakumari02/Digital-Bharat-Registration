import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lead_model.dart';
import 'package:flutter/foundation.dart'; // This enables debugPrint

class LeadController {
  static const String _url = 'http://10.0.2.2:8000/api/leads';

  // Change this to the base API path
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<LeadModel>> fetchAllLeads(int myUserId) async {
    try {
      // FIX: Use the correct endpoint without duplicating 'leads'
      final response = await http.get(
        Uri.parse("$_baseUrl/leads?bank_user_id=$myUserId"),
        headers: {
          'Accept': 'application/json', // Forces Laravel to send JSON instead of HTML
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => LeadModel.fromJson(item)).toList();
      } else {
        // If it fails, print the body so you can see why
        debugPrint("Server Error: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Flutter Error: $e");
      return [];
    }
  }
  // controllers/lead_controller.dart

// inside LeadController
  Future<bool> updateLeadStatus(int id, String status, int currentBankUserId) async {
    try {
      final response = await http.post(
        Uri.parse("$_url/update-status"),
        body: {
          'id': id.toString(),
          'status': status,
          'bank_user_id': currentBankUserId.toString()
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<LeadModel>> fetchMyLeads(int userId) async {
    try {
      // Send the userId as a query parameter
      final response = await http.get(
          Uri.parse("$_url/my-accepted-leads?bank_user_id=$userId")
      );
      print("Fetching for User ID: $userId");
      print("Response: ${response.body}"); // CHECK THIS IN YOUR CONSOLE

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => LeadModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}