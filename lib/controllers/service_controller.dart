import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ServiceController {
  // Use the same dynamic IP logic as LoginController
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }

  Future<bool> submitData(Map<String, dynamic> payload) async {
    final url = Uri.parse('$_baseUrl/save-service');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10)); // Added timeout to prevent hanging

      // Successfully saved in the specific domain table
      return response.statusCode == 201;
    } catch (e) {
      print("Submit Error: $e");
      return false;
    }
  }

  Future<List<dynamic>> fetchJobs() async {
    final url = Uri.parse('$_baseUrl/jobs');

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Fetch Jobs Error: $e");
      return [];
    }
  }
}