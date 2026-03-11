import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiceController {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

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
      );

      // Successfully saved in the specific domain table
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}