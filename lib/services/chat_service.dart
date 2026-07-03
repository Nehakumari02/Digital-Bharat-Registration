import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ChatService {
  static Future<List<dynamic>> fetchMessages(String userId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/support-messages/$userId');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['messages'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  static Future<bool> sendMessage(String userId, String message) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/support-messages');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'registration_id': userId,
          'message': message,
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Simulate an admin reply for demo purposes
  static Future<bool> simulateAdminReply(String userId, String message) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/support-messages/admin-reply');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'registration_id': userId,
          'message': message,
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error simulating admin reply: $e');
      return false;
    }
  }
}
