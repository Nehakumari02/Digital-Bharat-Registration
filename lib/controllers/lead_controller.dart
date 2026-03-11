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
}