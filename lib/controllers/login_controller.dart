import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/login_model.dart';

class LoginController {
  static String get _baseUrl => ApiConfig.baseUrl;

  Future<http.Response> login(LoginModel data) async {
    final url = Uri.parse('$_baseUrl/login');

    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json", // Added this to help Laravel return JSON errors
      },
      body: jsonEncode(data.toJson()),
    );
  }
}