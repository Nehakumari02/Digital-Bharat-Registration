import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lead_model.dart';

class LeadController {
  static const String _url = 'http://10.0.2.2:8000/api/leads';

  Future<List<LeadModel>> fetchAllLeads() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => LeadModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load leads");
      }
    } catch (e) {
      throw Exception("Error: $e");
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