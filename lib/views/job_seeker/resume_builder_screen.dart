import 'package:flutter/material.dart';
import 'resume_preview_screen.dart';

class ResumeBuilderScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ResumeBuilderScreen({super.key, required this.userData});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Info
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();

  // Summary
  final _summaryCtrl = TextEditingController();

  // Education
  final _institutionCtrl = TextEditingController();
  final _degreeCtrl = TextEditingController();
  final _gradYearCtrl = TextEditingController();
  final _gpaCtrl = TextEditingController();

  // Experience
  final _companyCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Skills
  final _skillsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final u = widget.userData;
    _nameCtrl.text = (u['name'] ?? '').toString();
    _emailCtrl.text = (u['email'] ?? '').toString();
    _phoneCtrl.text = (u['mobile'] ?? '').toString();
    _institutionCtrl.text = (u['college_name'] ?? '').toString();
    _degreeCtrl.text = (u['stream'] ?? '').toString();
    _gpaCtrl.text = (u['gpa'] ?? '').toString();
    _gradYearCtrl.text = (u['graduation_year'] ?? '').toString();
    _skillsCtrl.text = (u['skills'] ?? '').toString();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _linkedinCtrl.dispose();
    _portfolioCtrl.dispose();
    _summaryCtrl.dispose();
    _institutionCtrl.dispose();
    _degreeCtrl.dispose();
    _gradYearCtrl.dispose();
    _gpaCtrl.dispose();
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _durationCtrl.dispose();
    _descCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  void _generateResume() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields')),
      );
      return;
    }

    final resumeData = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'linkedin': _linkedinCtrl.text.trim(),
      'portfolio': _portfolioCtrl.text.trim(),
      'summary': _summaryCtrl.text.trim(),
      'education': {
        'institution': _institutionCtrl.text.trim(),
        'degree': _degreeCtrl.text.trim(),
        'year': _gradYearCtrl.text.trim(),
        'gpa': _gpaCtrl.text.trim(),
      },
      'experience': {
        'company': _companyCtrl.text.trim(),
        'role': _roleCtrl.text.trim(),
        'duration': _durationCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
      },
      'skills': _skillsCtrl.text.trim(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumePreviewScreen(resumeData: resumeData),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
      filled: true,
      fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {int maxLines = 1, bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        decoration: _dec(label, icon),
        validator: isRequired
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Resume Builder', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        elevation: 1,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('Personal Details'),
                _field(_nameCtrl, 'Full Name', Icons.person, isRequired: true),
                _field(_emailCtrl, 'Email Address', Icons.email, isRequired: true),
                _field(_phoneCtrl, 'Phone Number', Icons.phone, isRequired: true),
                _field(_linkedinCtrl, 'LinkedIn URL', Icons.link),
                _field(_portfolioCtrl, 'Portfolio / Website', Icons.language),

                _sectionHeader('Professional Summary'),
                const Text('Write a brief summary highlighting your key achievements.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 12),
                _field(_summaryCtrl, 'Summary', Icons.text_snippet, maxLines: 4, isRequired: true),

                _sectionHeader('Education'),
                _field(_institutionCtrl, 'Institution / College', Icons.school, isRequired: true),
                _field(_degreeCtrl, 'Degree / Major (e.g. B.Tech CSE)', Icons.menu_book, isRequired: true),
                Row(
                  children: [
                    Expanded(child: _field(_gradYearCtrl, 'Graduation Year', Icons.calendar_today, isRequired: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_gpaCtrl, 'GPA / Percentage', Icons.grade, isRequired: true)),
                  ],
                ),

                _sectionHeader('Experience'),
                const Text('Add your most recent or relevant job/internship.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 12),
                _field(_companyCtrl, 'Company Name', Icons.business),
                _field(_roleCtrl, 'Job Title / Role', Icons.work),
                _field(_durationCtrl, 'Duration (e.g. Jan 2023 - Present)', Icons.date_range),
                _field(_descCtrl, 'Description & Achievements', Icons.description, maxLines: 4),

                _sectionHeader('Skills'),
                const Text('Enter your skills separated by commas (e.g. Flutter, Dart).', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 12),
                _field(_skillsCtrl, 'Skills', Icons.build, maxLines: 3, isRequired: true),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _generateResume,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('PREVIEW RESUME', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
