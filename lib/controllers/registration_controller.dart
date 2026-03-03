import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/registration_model.dart';

class RegistrationController {
  // Use 10.0.2.2 to connect from the Android Emulator to your local Mac server
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  Future<http.Response> registerUser(RegistrationModel data) async {
    final url = Uri.parse('$_baseUrl/register');

    try {
      // The controller sends the "packaged" data from the model to the API
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data.toJson()),
      );

      return response;
    } catch (e) {
      // Rethrow to allow the Screen to handle network failures
      throw Exception("Connection Error: $e");
    }
  }
}