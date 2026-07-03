import 'package:flutter/material.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';
import 'live_chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        centerTitle: true,
      ),
      body: ResponsiveScrollBody(
        children: [
          const Center(
            child: Icon(Icons.support_agent, size: 80, color: Color(0xFF2196F3)),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              "How can we help you?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          _supportCard(context, Icons.article_outlined, "FAQs", "Find answers to common questions.", () => _showFAQDialog(context)),
          _supportCard(context, Icons.chat_bubble_outline, "Live Chat", "Chat with our support executives.", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveChatScreen()))),
          _supportCard(context, Icons.email_outlined, "Email Support", "Write to our support emails", () => _showEmailDialog(context)),
          _supportCard(context, Icons.phone_in_talk, "Call Us", "+91 9669122331 / +91 6262122331", () => _showCallDialog(context)),
        ],
      ),
    );
  }

  Widget _supportCard(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF2196F3)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Frequently Asked Questions"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("Q: How do I change my password?", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("A: Go to Profile -> Settings -> Change Password.\n"),
              Text("Q: Can I update my category?", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("A: No, you must re-register to change your category.\n"),
              Text("Q: Where do I find my application status?", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("A: Check the 'Services' tab under 'Accepted Leads' or 'Status'."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Email Support"),
        content: const Text("Please write an email to:\n\nSupport@digitalindiastartup.com\nSupport@digitalindiaregistration.com"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Call Support"),
        content: const Text("You can reach us at:\n\n+91 9669122331\n+91 6262122331\n\nStandard calling rates may apply depending on your provider."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
