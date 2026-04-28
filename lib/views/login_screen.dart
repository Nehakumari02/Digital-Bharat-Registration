import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../controllers/login_controller.dart';
import '../models/login_model.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'dart:convert';

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4EB), Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        backgroundColor: Color(0x1AF26522),
                        child: Icon(
                          Icons.fingerprint_rounded,
                          size: 38,
                          color: Color(0xFFF26522),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "DIGITAL INDIA",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "REGISTRATION",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 28),
                      CustomTextField(
                        controller: _mobileController,
                        label: "Mobile or Email",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _passwordController,
                        label: "Password",
                        obscureText: true,
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.6,
                                  ),
                                )
                                : const Text("LOGIN"),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Not registered yet? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Register Here",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
