import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../controllers/login_controller.dart';
import '../models/login_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _loginController = LoginController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);

    final loginData = LoginModel(mobile: _mobileController.text);

    try {
      final response = await _loginController.login(loginData);

      if (response.statusCode == 200) {
        _showSnack("Login Successful!", Colors.green);
        // Navigate to Home Screen here later
      } else {
        _showSnack("User not found or Invalid Mobile", Colors.red);
      }
    } catch (e) {
      _showSnack("Server Error. Is DBngin running?", Colors.red);
    } finally {
      setState(() => _isLoading = false);
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
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _mobileController,
              label: "Mobile Number",
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading ? const CircularProgressIndicator() : const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}