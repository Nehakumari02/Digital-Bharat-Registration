import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Security"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text("Login & Security", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF26522))),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text("Change Password"),
            subtitle: const Text("Update your password regularly"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showPasswordDialog,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text("Biometric Authentication"),
            subtitle: const Text("Use fingerprint or face ID to login"),
            value: _biometricEnabled,
            activeColor: const Color(0xFFF26522),
            onChanged: (bool value) {
              setState(() {
                _biometricEnabled = value;
              });
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.security),
            title: const Text("Two-Factor Authentication"),
            subtitle: const Text("Require an OTP to login to new devices"),
            value: _twoFactorEnabled,
            activeColor: const Color(0xFFF26522),
            onChanged: (bool value) {
              setState(() {
                _twoFactorEnabled = value;
              });
            },
          ),
          const Divider(height: 30),
          const Text("Device Management", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF26522))),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text("Active Sessions"),
            subtitle: const Text("Review devices logged into your account"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No other active sessions found.")));
            },
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(decoration: InputDecoration(labelText: "Current Password"), obscureText: true),
              SizedBox(height: 10),
              TextField(decoration: InputDecoration(labelText: "New Password"), obscureText: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF26522), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password updated successfully!")));
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
