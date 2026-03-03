import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/login_model.dart';

class LoginController {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  Future<http.Response> login(LoginModel data) async {
    final url = Uri.parse('$_baseUrl/login');

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data.toJson()),
    );
  }
}