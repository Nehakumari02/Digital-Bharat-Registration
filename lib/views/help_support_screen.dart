import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Center(
            child: Icon(Icons.support_agent, size: 80, color: Color(0xFFF26522)),
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
          _supportCard(context, Icons.chat_bubble_outline, "Live Chat", "Chat with our support executives.", () => _showChatDialog(context)),
          _supportCard(context, Icons.email_outlined, "Email Support", "Write to support@digitalregistration.com", () => _showEmailDialog(context)),
          _supportCard(context, Icons.phone_in_talk, "Call Us", "1800-123-4567 (Toll Free)", () => _showCallDialog(context)),
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
          backgroundColor: const Color(0xFFF26522).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFFF26522)),
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
      builder: (context) {
        return AlertDialog(
          title: const Text("Frequently Asked Questions"),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
        );
      },
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Live Chat"),
          content: const Text("All our support executives are currently busy. Please leave a message or try again later."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF26522), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Redirecting to message portal...")));
              },
              child: const Text("Leave Message"),
            ),
          ],
        );
      },
    );
  }

  void _showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Email Support"),
          content: const Text("Your default email client will open to draft a message to support@digitalregistration.com."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF26522), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening email client...")));
              },
              child: const Text("Open Mail"),
            ),
          ],
        );
      },
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Call Support"),
          content: const Text("Do you want to dial 1800-123-4567? Standard calling rates may apply depending on your provider."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dialing 1800-123-4567...")));
              },
              child: const Icon(Icons.call),
            ),
          ],
        );
      },
    );
  }
}
