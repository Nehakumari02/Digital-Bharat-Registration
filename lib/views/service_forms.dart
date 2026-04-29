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

class InternshipScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const InternshipScreen({super.key, required this.userData});

  @override
  State<InternshipScreen> createState() => _InternshipScreenState();
}

class _InternshipScreenState extends State<InternshipScreen> {
  bool _isApplying = false;
  late Future<List<dynamic>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = ServiceController().fetchJobs();
  }

  void _applyForJob(int jobId, String title) async {
    setState(() => _isApplying = true);

    final payload = {
      "user_id": widget.userData['id'],
      "type": "job_apply",
      "data": {
        "job_id": jobId,
      }
    };

    bool success = await ServiceController().submitData(payload);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Applied for $title successfully!")));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to apply or already applied.")));
    }
    setState(() => _isApplying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Available Internships", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<dynamic>>(
            future: _jobsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              final jobs = snapshot.data ?? [];
              if (jobs.isEmpty) {
                return const Center(child: Text("No internships available right now."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF26522).withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.laptop_mac, color: Color(0xFFF26522)),
                      ),
                      title: Text(job['job_title'] ?? "Unknown Title", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(job['company_name'] ?? "Unknown Company", style: TextStyle(color: Colors.grey.shade600)),
                      trailing: SizedBox(
                        width: 80,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              job['salary_range']?.toString() ?? "N/A", 
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text("Apply Now", style: TextStyle(color: Color(0xFFF26522), fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      onTap: _isApplying ? null : () {
                        final id = job['id'];
                        if (id != null) {
                          _applyForJob(int.parse(id.toString()), job['job_title']?.toString() ?? "Internship");
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
          if (_isApplying)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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

class EducationLoanForm extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EducationLoanForm({super.key, required this.userData});

  @override
  State<EducationLoanForm> createState() => _EducationLoanFormState();
}

class _EducationLoanFormState extends State<EducationLoanForm> {
  final _collegeController = TextEditingController();
  final _courseController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSaving = false;

  void _submitForm() async {
    if (_collegeController.text.isEmpty || _courseController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isSaving = true);

    final payload = {
      "user_id": widget.userData['id'],
      "type": "edu_loan",
      "data": {
        "college_name": _collegeController.text,
        "course_name": _courseController.text,
        "amount": _amountController.text,
      }
    };

    bool success = await ServiceController().submitData(payload);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Education Loan Application Submitted!")));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Submission failed. Check your connection.")));
    }
    setState(() => _isSaving = false);
  }

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
            TextField(controller: _collegeController, decoration: _inputStyle("College/University Name", Icons.school)),
            const SizedBox(height: 16),
            TextField(controller: _courseController, decoration: _inputStyle("Course Name", Icons.book)),
            const SizedBox(height: 16),
            TextField(controller: _amountController, decoration: _inputStyle("Loan Amount Required", Icons.currency_rupee), keyboardType: TextInputType.number),
            const SizedBox(height: 40),
            _isSaving 
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
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

class BusinessLoanForm extends StatefulWidget {
  final Map<String, dynamic> userData;
  const BusinessLoanForm({super.key, required this.userData});

  @override
  State<BusinessLoanForm> createState() => _BusinessLoanFormState();
}

class _BusinessLoanFormState extends State<BusinessLoanForm> {
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _tenureController = TextEditingController();
  bool _isSaving = false;

  void _submitForm() async {
    if (_amountController.text.isEmpty || _purposeController.text.isEmpty || _tenureController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isSaving = true);

    final payload = {
      "user_id": widget.userData['id'],
      "type": "biz_loan", 
      "data": {
        "amount": _amountController.text,
        "purpose": _purposeController.text,
        "tenure": _tenureController.text,
      }
    };

    bool success = await ServiceController().submitData(payload);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Business Loan Application Submitted!")));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Submission failed. Check your connection.")));
    }
    setState(() => _isSaving = false);
  }

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
            TextField(controller: _amountController, decoration: _inputStyle("Required Amount", Icons.currency_rupee), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            TextField(controller: _purposeController, decoration: _inputStyle("Purpose of Loan", Icons.business_center)),
            const SizedBox(height: 16),
            TextField(controller: _tenureController, decoration: _inputStyle("Tenure (in months)", Icons.calendar_today), keyboardType: TextInputType.number),
            const SizedBox(height: 40),
            _isSaving
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
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

class PostJobScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const PostJobScreen({super.key, required this.userData});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _salaryController = TextEditingController();
  bool _isSaving = false;

  void _submitForm() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty || _salaryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isSaving = true);

    final payload = {
      "user_id": widget.userData['id'],
      "type": "job_post",
      "data": {
        "job_title": _titleController.text,
        "description": _descController.text,
        "salary_range": _salaryController.text,
      }
    };

    bool success = await ServiceController().submitData(payload);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Job Posted Successfully!")));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to post job. Check connection.")));
    }
    setState(() => _isSaving = false);
  }

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
            TextField(controller: _titleController, decoration: _inputStyle("Job Title", Icons.work)),
            const SizedBox(height: 16),
            TextField(controller: _descController, maxLines: 3, decoration: _inputStyle("Job Description", Icons.description)),
            const SizedBox(height: 16),
            TextField(controller: _salaryController, decoration: _inputStyle("Salary Range", Icons.payments)),
            const SizedBox(height: 40),
            _isSaving 
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
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
              title: Text(applicants[index]['name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(applicants[index]['course'] ?? "N/A"),
              trailing: Text(applicants[index]['status'] ?? "Pending", style: const TextStyle(color: Colors.blue)),
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
  final int currentBankUserId; 
  final String? filterType; // Optional filter (biz_loan, edu_loan, kisan_loan)
  const AllLeadsScreen({super.key, required this.currentBankUserId, this.filterType});

  @override
  State<AllLeadsScreen> createState() => _AllLeadsScreenState();
}

class _AllLeadsScreenState extends State<AllLeadsScreen> {
  final LeadController _leadController = LeadController();
  int? _overrideId; // For debugging

  Key _refreshKey = UniqueKey(); // Used to force refresh the list

  void _handleClaim(int id) async {
    final int effectiveId = _overrideId ?? widget.currentBankUserId;
    bool success = await _leadController.updateLeadStatus(id, "Approved", effectiveId);

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
    final int effectiveId = _overrideId ?? widget.currentBankUserId;

    String title = "Loan Applications";
    if (widget.filterType == "Job Posting") title = "Business Loans";
    if (widget.filterType == "Education Loan") title = "Student Loans";
    if (widget.filterType == "Farmer Loan") title = "Farmer Loans";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _refreshKey = UniqueKey()),
          )
        ],
      ),
      body: FutureBuilder<List<LeadModel>>(
        key: _refreshKey,
        future: _leadController.fetchAllLeads(effectiveId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      "Error: ${snapshot.error.toString().replaceAll('Exception:', '')}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => setState(() => _overrideId = 1),
                      child: const Text("Try with Test ID (1)"),
                    ),
                  ],
                ),
              ),
            );
          }

          List<LeadModel> leads = snapshot.data ?? [];

          // Apply client-side filter if filterType is provided
          final String? filter = widget.filterType;
          /* 
          // TEMPORARILY DISABLED FILTERING TO DEBUG DATA VISIBILITY
          if (filter != null) {
            leads = leads.where((l) => l.loanType.trim().toLowerCase() == filter.trim().toLowerCase()).toList();
          }
          */

          // --- ADD DEBUG INFO ---
          final String debugInfo = "User ID: $effectiveId\nFilter: ${filter ?? 'None'}\nURL: ${LeadController.baseUrl}/leads?bank_user_id=$effectiveId";
          debugPrint(debugInfo);

          if (leads.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Text(debugInfo, style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontFamily: 'Courier')),
                    ),
                    const SizedBox(height: 20),
                    Icon(Icons.location_off_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      "No leads available",
                      style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Check back later for new requests.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    if (effectiveId != 1)
                      ElevatedButton(
                        onPressed: () => setState(() => _overrideId = 1),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF26522)),
                        child: const Text("Switch to Test ID (1)", style: TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leads.length,
            shrinkWrap: true, // Safety for layout issues
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

    String displayType = lead.loanType;
    if (displayType == "Job Posting") displayType = "Business";
    if (displayType == "Education Loan") displayType = "Student";
    if (displayType == "Farmer Loan") displayType = "Farmer";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(lead.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
            Text(lead.amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF26522))),
          ],
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(displayType, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(lead.mobile, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isClaimed ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isClaimed ? "APPROVED" : lead.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  color: isClaimed ? Colors.green.shade700 : Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
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
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leads[index].mobile),
                    Text(leads[index].loanType, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
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