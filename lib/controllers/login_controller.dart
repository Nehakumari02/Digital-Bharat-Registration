import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import '../models/login_model.dart';

class LoginController {
  // We use a getter to pick the right IP address automatically
  static String get _baseUrl {
    if (kIsWeb) {
      // Use this for Chrome/Web
      return 'http://127.0.0.1:8000/api';
    } else {
      // Use this for Android Emulator
      return 'http://10.0.2.2:8000/api';
    }
  }

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