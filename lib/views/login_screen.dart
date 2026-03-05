import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../controllers/login_controller.dart';
import '../models/login_model.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'dart:convert'; // THIS IS THE MISSING LINE

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController(); // Added for security
  final _loginController = LoginController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_mobileController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnack("Please enter both mobile and password", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create login data with both fields
      final loginData = LoginModel(
        mobile: _mobileController.text,
        password: _passwordController.text,
      );

      final response = await _loginController.login(loginData);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body)['user'];
        _showSnack("Login Successful!", Colors.green);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(userData: userData),
            ),
          );
        }
      } else {
        _showSnack("Invalid credentials or User not found", Colors.red);
      }
    } catch (e) {
      _showSnack("Server Error. Check your connection.", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint_rounded, size: 80, color: Color(0xFFF26522)),
              const SizedBox(height: 15),
              const Text("DIGITAL INDIA", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              const Text("REGISTRATION", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFFF26522))),
              const SizedBox(height: 40),

              CustomTextField(
                controller: _mobileController,
                label: "Mobile or Email",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: _passwordController,
                label: "Password",
                // Set obscureText: true in your CustomTextField widget
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  backgroundColor: const Color(0xFFF26522),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Not registered yet? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    child: const Text(
                      "Register Here",
                      style: TextStyle(color: Color(0xFFF26522), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}