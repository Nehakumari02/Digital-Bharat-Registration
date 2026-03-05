import 'package:flutter/material.dart';
import 'package:the_digital_registration/views/service_forms.dart'; // Ensure this file exists
import 'login_screen.dart'; // Ensure this file exists in your lib/views folder


class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const DashboardScreen({super.key, required this.userData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    String category = widget.userData['category'] ?? 'User';

    final List<Widget> _pages = [
      _buildHomeTab(category),
      _buildServicesTab(category),
      _buildProfileTab(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFF26522),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  // --- TAB 1: HOME ---
  Widget _buildHomeTab(String category) {
    return Column(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF26522), Color(0xFFFDB913)],
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fingerprint, color: Colors.white, size: 40),
                  const SizedBox(height: 15),
                  Text("Welcome, ${widget.userData['name']}",
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Digital India $category Portal",
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statBox("2.1L+", "Registrations"),
              _statBox("6.9L+", "Portal Users"),
              _statBox("18K+", "Approved"),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 2: SERVICES (Fixed Navigation Calls) ---
  Widget _buildServicesTab(String category) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Digital Services"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Available for $category"),

          // --- STUDENT ---
          if (category == 'Student') ...[
            _serviceCard(Icons.work, "Internship", "Find new opportunities", const InternshipScreen(), context),
            _serviceCard(Icons.school, "Scholarship", "Government grants", const ScholarshipScreen(), context),
            _serviceCard(Icons.description, "Loan Form", "Education financing", const EducationLoanForm(), context),
            _statusCard("Loan Status", "Approved"),
          ],

          // --- BUSINESS ---
          if (category == 'Business') ...[
            _serviceCard(Icons.monetization_on, "Loan Form", "Expansion capital", const BusinessLoanForm(), context),
            _serviceCard(Icons.post_add, "Post Job", "Hire Students", const PostJobScreen(), context),
            _serviceCard(Icons.people, "Applicants", "View applied students", const ApplicantsScreen(), context),
            _statusCard("Business Loan", "Pending"),
          ],

          // --- FARMERS ---
          if (category == 'Farmers') ...[
            _serviceCard(Icons.request_quote, "Loan Form", "Kisan Credit", const FarmerLoanForm(), context),
            _serviceCard(Icons.add_a_photo, "Crop Registration", "Add Image, Name, Price", const CropRegistrationScreen(), context),
            _serviceCard(Icons.security, "Bima Yojana", "Crop Insurance", const BimaYojanaScreen(), context),
            _serviceCard(Icons.account_balance_wallet, "Subsidy", "Govt Benefits", const SubsidyScreen(), context),
          ],

          // --- BANK ---
          if (category == 'Bank') ...[
            _serviceCard(Icons.list_alt, "All Leads", "New applications", const AllLeadsScreen(), context),
            _serviceCard(Icons.check_circle, "Accepted Leads", "Approved loans", const AcceptedLeadsScreen(), context),
          ],
        ],
      ),
    );
  }

  // --- TAB 3: PROFILE ---
  // --- TAB 3: PROFILE ---
  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFF26522),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(widget.userData['name'] ?? "User",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(widget.userData['email'] ?? "Email not provided"),
          const SizedBox(height: 30),

          // UPDATED LOGOUT BUTTON
          ElevatedButton(
            onPressed: () {
              // This clears the navigation stack and sets LoginScreen as the new root
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Logout"),
          )
        ],
      ),
    );
  }

  // --- HELPERS ---
  Widget _statBox(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF26522))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  // FIXED HELPER: Now accepts destination and context correctly
  Widget _serviceCard(IconData icon, String title, String sub, Widget destination, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFF26522)),
        title: Text(title),
        subtitle: Text(sub),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
      ),
    );
  }

  Widget _statusCard(String title, String status) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), Text(status, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))],
      ),
    );
  }
}