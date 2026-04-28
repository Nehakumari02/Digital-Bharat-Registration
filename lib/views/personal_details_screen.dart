import 'package:flutter/material.dart';

class PersonalDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const PersonalDetailsScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Details"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFF26522),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),
          ...userData.entries.map((entry) {
            // Exclude password, raw IDs, null values, or empty strings
            if (entry.key == 'password' || entry.key == 'id' || entry.key == '_id' || entry.key == '__v') {
              return const SizedBox.shrink();
            }
            if (entry.value == null || entry.value.toString().trim().isEmpty || entry.value.toString() == "null") {
              return const SizedBox.shrink();
            }
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                title: Text(
                  _formatKey(entry.key),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                subtitle: Text(
                  entry.value.toString(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    // Converts keys like "company_name" to "Company Name"
    return key.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
