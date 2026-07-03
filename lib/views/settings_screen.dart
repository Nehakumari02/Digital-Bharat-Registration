import 'package:flutter/material.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';
import 'package:the_digital_registration/main.dart' as import_main;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ResponsiveScrollBody(
        children: [
          const Text("App Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text("Push Notifications"),
            subtitle: const Text("Receive updates and alerts"),
            value: _notificationsEnabled,
            activeColor: const Color(0xFF2196F3),
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Enable dark theme for the app"),
            value: _darkModeEnabled,
            activeColor: const Color(0xFF2196F3),
            onChanged: (bool value) {
              setState(() {
                _darkModeEnabled = value;
              });
              import_main.themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          ListTile(
            title: const Text("Language"),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showLanguageDialog,
          ),
          const Divider(height: 30),
          const Text("Account & Security", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showPasswordDialog,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text("Privacy Policy"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showPrivacyDialog,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Delete Account", style: TextStyle(color: Colors.red)),
            onTap: _showDeleteDialog,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    ResponsiveDialog.show(
      context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Select Language", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...['English', 'Hindi', 'Marathi', 'Gujarati'].map((lang) {
              return RadioListTile<String>(
                title: Text(lang),
                value: lang,
                groupValue: _selectedLanguage,
                activeColor: const Color(0xFF2196F3),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password updated successfully!")));
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    ResponsiveDialog.show(
      context,
      maxHeight: 480,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Privacy Policy", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const SingleChildScrollView(
              child: Text(
                "Your privacy is important to us. It is our policy to respect your privacy regarding any information we may collect from you across our application.\n\n"
                "We only ask for personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent.\n\n"
                "We don't share any personally identifying information publicly or with third-parties, except when required to by law.",
                style: TextStyle(fontSize: 14),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    ResponsiveDialog.show(
      context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Delete Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Are you sure you want to permanently delete your account? This action cannot be undone."),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account deletion requested.")));
                  },
                  child: const Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
