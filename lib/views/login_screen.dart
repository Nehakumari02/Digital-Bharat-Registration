import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/responsive_layout.dart';
import '../controllers/login_controller.dart';
import '../models/login_model.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import '../controllers/partner_wallet_controller.dart';
import '../services/auth_session.dart';
import '../utils/login_response_parser.dart';
import '../utils/user_profile_helpers.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginController = LoginController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_mobileController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnack("Please enter both mobile and password", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final loginData = LoginModel(
        mobile: _mobileController.text,
        password: _passwordController.text,
      );

      final response = await _loginController.login(loginData);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final userData = parseLoginUser(
          body,
          mobileOrEmail: _mobileController.text.trim(),
        );
        final id = int.tryParse(userData['id']?.toString() ?? '');
        if (id != null) {
          final code = UserProfileHelpers.displayPartnerCode(userData);
          final info = await PartnerWalletController().fetchWallet(
            id,
            partnerCode: code,
            profileBalance: UserProfileHelpers.walletBalance(userData),
            user: userData,
          );
          if (info != null) {
            userData['wallet_balance'] = info.balance;
          }
        }

        final sessionSaved = await AuthSession.save(userData);

        if (!mounted) return;
        if (!sessionSaved) {
          _showSnack(
            'Logged in but session could not be saved. Contact support.',
            Colors.orange,
          );
        } else {
          _showSnack('Login Successful!', Colors.green);
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(userData: userData),
          ),
          (route) => false,
        );
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
    return ResponsiveAuthShell(
      formChild: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Login to your account",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your credentials to continue",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _mobileController,
              label: "Mobile or Email",
              prefixIcon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _passwordController,
              label: "Password",
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "LOGIN",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      footer: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Create One",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
