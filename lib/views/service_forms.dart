import 'package:flutter/material.dart';
import 'package:the_digital_registration/controllers/service_controller.dart';
import '../controllers/lead_controller.dart';
import '../models/lead_model.dart';

// --- SHARED UI HELPERS ---
Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16, top: 10),
    child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5)),
  );
}

InputDecoration _inputStyle(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: const Color(0xFFF26522)),
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Education Loan", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Student Information"),
            TextField(decoration: _inputStyle("College/University Name", Icons.school)),
            const SizedBox(height: 16),
            TextField(decoration: _inputStyle("Course Name", Icons.book)),
            const SizedBox(height: 16),
            TextField(decoration: _inputStyle("Loan Amount Required", Icons.currency_rupee)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFF26522),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: const Color(0xFFF26522).withOpacity(0.5),
                ),
                child: const Text("SUBMIT REQUEST", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Business Loan", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Loan Requirements"),
            TextField(decoration: _inputStyle("Required Amount", Icons.currency_rupee)),
            const SizedBox(height: 16),
            TextField(decoration: _inputStyle("Purpose of Loan", Icons.business_center)),
            const SizedBox(height: 16),
            TextField(decoration: _inputStyle("Tenure (in months)", Icons.calendar_today)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFF26522),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: const Color(0xFFF26522).withOpacity(0.5),
                ),
                child: const Text("SUBMIT APPLICATION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Post a New Job", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Job Details"),
            TextField(decoration: _inputStyle("Job Title", Icons.work)),
            const SizedBox(height: 16),
            TextField(maxLines: 3, decoration: _inputStyle("Job Description", Icons.description)),
            const SizedBox(height: 16),
            TextField(decoration: _inputStyle("Salary Range", Icons.payments)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFF26522),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: const Color(0xFFF26522).withOpacity(0.5),
                ),
                child: const Text("POST JOB", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
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

class CropRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const CropRegistrationScreen({super.key, required this.userData});

  @override
  State<CropRegistrationScreen> createState() => _CropRegistrationScreenState();
}

class _CropRegistrationScreenState extends State<CropRegistrationScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isSaving = false;

  void _saveCrop() async {
    setState(() => _isSaving = true);
    final payload = {
      "user_id": widget.userData['id'],
      "type": "crop_reg",
      "data": {
        "crop_name": _nameController.text,
        "price": _priceController.text,
        // Add image logic here later
      }
    };

    bool success = await ServiceController().submitData(payload);
    if (success && mounted) Navigator.pop(context);
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Register My Crop", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Crop Details"),
            Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: _inputStyle("Crop Name", Icons.grass)),
            const SizedBox(height: 16),
            TextField(controller: _priceController, decoration: _inputStyle("Price per Quintal", Icons.sell)),
            const SizedBox(height: 40),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveCrop,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFF26522),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                        shadowColor: const Color(0xFFF26522).withOpacity(0.5),
                      ),
                      child: const Text("REGISTER CROP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// --- FARMER LOAN FORM (KCC) ---
class FarmerLoanForm extends StatefulWidget {
  final Map<String, dynamic> userData; // Correct: Defined in Widget class
  const FarmerLoanForm({super.key, required this.userData});

  @override
  State<FarmerLoanForm> createState() => _FarmerLoanFormState();
}

class _FarmerLoanFormState extends State<FarmerLoanForm> {
  final _landSizeController = TextEditingController();
  final _khasraController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSaving = false;

  void _applyForLoan() async {
    if (_landSizeController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => _isSaving = true);

    final payload = {
      "user_id": widget.userData['id'], // Accessing via 'widget.'
      "type": "kisan_loan",
      "data": {
        "land_size": _landSizeController.text,
        "khasra_number": _khasraController.text,
        "amount": _amountController.text,
      }
    };

    bool success = await ServiceController().submitData(payload);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Loan Application Submitted Successfully!")),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit. Please check your connection.")),
      );
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Kisan Loan Application", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Land & Loan Details"),
            TextField(
              controller: _landSizeController,
              decoration: _inputStyle("Land Size (in Acres)", Icons.landscape),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _khasraController,
              decoration: _inputStyle("Khasra/Khatauni Number", Icons.numbers),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: _inputStyle("Required Amount", Icons.currency_rupee),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyForLoan,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFF26522),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                        shadowColor: const Color(0xFFF26522).withOpacity(0.5),
                      ),
                      child: const Text("APPLY FOR KCC LOAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
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

class AllLeadsScreen extends StatefulWidget {
  final int currentBankUserId; // Pass this from your login/session
  const AllLeadsScreen({super.key,required this.currentBankUserId});


  @override
  State<AllLeadsScreen> createState() => _AllLeadsScreenState();
}

class _AllLeadsScreenState extends State<AllLeadsScreen> {
  final LeadController _leadController = LeadController();

  Key _refreshKey = UniqueKey(); // Used to force refresh the list

  void _handleClaim(int id) async {
    // 1. Call the API
    bool success = await _leadController.updateLeadStatus(id, "Approved",widget.currentBankUserId);

    if (success && mounted) {
      // 2. Only if the API returned true, update the UI
      setState(() {
        // Changing the key forces the FutureBuilder to run the 'future' again
        _refreshKey = UniqueKey();
      });
    } else {
      // Handle failure (maybe the server is down?)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update status on server")),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loan Applications (Leads)")),
      body: FutureBuilder<List<LeadModel>>(
        key: _refreshKey,
        future: _leadController.fetchAllLeads(widget.currentBankUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));

          final leads = snapshot.data ?? [];

          // --- ADD THIS CHECK ---
          if (leads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    "No leads available for you",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "There are no farmers within 100km of your location.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leads.length,
            itemBuilder: (context, index) {
              final lead = leads[index];
              return _leadItem(lead);
            },
          );
        },
      ),
    );
  }

  Widget _leadItem(LeadModel lead) {
    // Check if the status is already approved or claimed
    bool isClaimed = lead.status.toLowerCase() == "approved" || lead.status.toLowerCase() == "claimed";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
            lead.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${lead.loanType} • ${lead.amount}"),
            const SizedBox(height: 4),
            Text(
              isClaimed ? "APPROVED" : lead.status.toUpperCase(),
              style: TextStyle(
                  fontSize: 12,
                  color: isClaimed ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          // If claimed, onPressed is null (disables button)
          onPressed: isClaimed ? null : () => _handleClaim(lead.id),
          style: ElevatedButton.styleFrom(
            // Change color based on state
            backgroundColor: isClaimed ? Colors.grey : const Color(0xFFF26522),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300], // Color when disabled
            disabledForegroundColor: Colors.grey[600],
          ),
          child: Text(isClaimed ? "CLAIMED" : "CLAIM"),
        ),
      ),
    );
  }
}


class AcceptedLeadsScreen extends StatefulWidget {
  final int currentBankUserId; // Pass this from your login/session
  const AcceptedLeadsScreen({super.key, required this.currentBankUserId});

  @override
  State<AcceptedLeadsScreen> createState() => _AcceptedLeadsScreenState();
}

class _AcceptedLeadsScreenState extends State<AcceptedLeadsScreen> {
  final LeadController _leadController = LeadController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Approved Loans")),
      body: FutureBuilder<List<LeadModel>>(
        // Call a specific method that filters by User ID
        future: _leadController.fetchMyLeads(widget.currentBankUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final leads = snapshot.data ?? [];

          if (leads.isEmpty) {
            return const Center(child: Text("You haven't approved any loans yet."));
          }

          return ListView.builder(
            itemCount: leads.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.verified, color: Colors.green),
                title: Text(leads[index].name),
                subtitle: Text(leads[index].mobile),
                trailing: Text(
                  leads[index].amount,
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}