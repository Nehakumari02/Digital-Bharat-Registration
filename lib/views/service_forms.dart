import 'package:flutter/material.dart';

// --- SHARED UI HELPERS ---
Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
  );
}

InputDecoration _inputStyle(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: const Color(0xFFF26522)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFF26522), width: 2),
    ),
  );
}

// --- 1. STUDENT SERVICES ---

class InternshipScreen extends StatelessWidget {
  const InternshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> jobs = [
      {"title": "Web Developer Intern", "company": "Tech Solutions", "stipend": "₹10,000"},
      {"title": "Graphic Designer", "company": "Creative Hub", "stipend": "₹8,000"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Available Internships")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.laptop_mac, color: Color(0xFFF26522)),
              title: Text(jobs[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(jobs[index]['company']!),
              trailing: Text(jobs[index]['stipend']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}

class ScholarshipScreen extends StatelessWidget {
  const ScholarshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scholarships")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSchemeCard("Post-Matric Scholarship", "For SC/ST/OBC Students", "Deadline: 30 April"),
          _buildSchemeCard("National Merit Scholarship", "Based on Academic Excellence", "Deadline: 15 May"),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(String title, String desc, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(desc, style: const TextStyle(color: Colors.grey)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text("APPLY NOW")),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class EducationLoanForm extends StatelessWidget {
  const EducationLoanForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Education Loan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(decoration: _inputStyle("College/University Name", Icons.school)),
            const SizedBox(height: 15),
            TextField(decoration: _inputStyle("Course Name", Icons.book)),
            const SizedBox(height: 15),
            TextField(decoration: _inputStyle("Loan Amount Required", Icons.currency_rupee)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text("SUBMIT LOAN REQUEST"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. BUSINESS SERVICES ---

class BusinessLoanForm extends StatelessWidget {
  const BusinessLoanForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Business Loan Application")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Loan Requirements"),
            TextField(decoration: _inputStyle("Required Amount", Icons.currency_rupee)),
            const SizedBox(height: 15),
            TextField(decoration: _inputStyle("Purpose of Loan", Icons.business_center)),
            const SizedBox(height: 15),
            TextField(decoration: _inputStyle("Tenure (in months)", Icons.calendar_today)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text("SUBMIT APPLICATION"),
            ),
          ],
        ),
      ),
    );
  }
}

class PostJobScreen extends StatelessWidget {
  const PostJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post a New Job")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Job Details"),
            TextField(decoration: _inputStyle("Job Title", Icons.work)),
            const SizedBox(height: 15),
            TextField(maxLines: 3, decoration: _inputStyle("Job Description", Icons.description)),
            const SizedBox(height: 15),
            TextField(decoration: _inputStyle("Salary Range", Icons.payments)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text("POST JOB"),
            ),
          ],
        ),
      ),
    );
  }
}

class ApplicantsScreen extends StatelessWidget {
  const ApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> applicants = [
      {"name": "Rahul Kumar", "course": "B.Tech CSE", "status": "Pending"},
      {"name": "Priya Sharma", "course": "MBA", "status": "Shortlisted"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Student Applicants")),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: applicants.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFF26522), child: Icon(Icons.person, color: Colors.white)),
              title: Text(applicants[index]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(applicants[index]['course']!),
              trailing: Text(applicants[index]['status']!, style: const TextStyle(color: Colors.blue)),
            ),
          );
        },
      ),
    );
  }
}

// --- 3. FARMER SERVICES ---

class CropRegistrationScreen extends StatelessWidget {
  const CropRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register My Crop")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey)),
              child: const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(decoration: _inputStyle("Crop Name", Icons.grass)),
            const SizedBox(height: 15),
            TextField(decoration: _inputStyle("Price per Quintal", Icons.sell)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text("REGISTER CROP"),
            ),
          ],
        ),
      ),
    );
  }
}

class FarmerLoanForm extends StatelessWidget {
  const FarmerLoanForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kisan Loan Application")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Land & Loan Details"),
            TextField(decoration: _inputStyle("Land Size (in Acres)", Icons.landscape)),
            const SizedBox(height: 15),
            TextField(decoration: _inputStyle("Khasra/Khatauni Number", Icons.numbers)),
            const SizedBox(height: 15),
            TextField(decoration: _inputStyle("Required Amount", Icons.currency_rupee)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text("APPLY FOR KCC LOAN"),
            ),
          ],
        ),
      ),
    );
  }
}

class BimaYojanaScreen extends StatelessWidget {
  const BimaYojanaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pradhan Mantri Fasal Bima")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            color: Colors.green,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Protect your crops against natural calamities. Policy Status: Active", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Insurance Details"),
          const ListTile(
            leading: Icon(Icons.verified_user, color: Colors.green),
            title: Text("Policy No: PMBY-2026-8821"),
            subtitle: Text("Valid until: Nov 2026"),
          ),
          const Divider(),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.file_download), label: const Text("Download Policy Bond")),
        ],
      ),
    );
  }
}

class SubsidyScreen extends StatelessWidget {
  const SubsidyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Government Subsidies")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("Available Benefits"),
          _subsidyItem("Fertilizer Subsidy", "Direct Benefit Transfer", "₹2,400 Received"),
          _subsidyItem("Solar Pump Scheme", "PM-KUSUM", "Application Pending"),
          _subsidyItem("Seed Subsidy", "Kharif 2026", "Available for Claim"),
        ],
      ),
    );
  }

  Widget _subsidyItem(String title, String scheme, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(scheme),
        trailing: Text(status, style: const TextStyle(color: Color(0xFFF26522), fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// --- 4. BANK SERVICES ---

class AllLeadsScreen extends StatelessWidget {
  const AllLeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loan Applications (Leads)")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _leadItem("Karan Mehra", "Farmer Loan", "₹2,50,000"),
          _leadItem("Suresh Raina", "Business Loan", "₹10,00,000"),
          _leadItem("Amit Singh", "Education Loan", "₹5,00,000"),
        ],
      ),
    );
  }

  Widget _leadItem(String name, String type, String amount) {
    return Card(
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(type),
        trailing: Text(amount, style: const TextStyle(color: Color(0xFFF26522), fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class AcceptedLeadsScreen extends StatelessWidget {
  const AcceptedLeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Approved Loans")),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            SizedBox(height: 10),
            Text("No new approvals today.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}