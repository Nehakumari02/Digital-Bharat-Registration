import 'package:http/http.dart' as http;
import 'dart:convert';
// Note: You might not even need the registration_model import anymore
// if you are passing the Map directly!

class RegistrationController {
  // Use 10.0.2.2 to connect from the Android Emulator to your local server
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  // CHANGE: Parameter changed from 'RegistrationModel data' to 'Map<String, dynamic> data'
  Future<http.Response> registerUser(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/register');

    try {
      // Since 'data' is already a Map, we can encode it directly
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json", // FIX: Moved inside the headers Map
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 422) {
        // This will print EXACTLY which field failed (e.g., "The mobile has already been taken")
        print("Validation Errors: ${response.body}");
      }

      return response;
    } catch (e) {
      // Rethrow to allow the Screen to handle network failures
      throw Exception("Connection Error: $e");
    }
  }
}