import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:the_digital_registration/controllers/service_controller.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';

/// Full internship application: resume, education, cover letter, etc.
class InternshipApplicationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final int jobId;
  final String jobTitle;
  final String companyName;
  final String salaryRange;
  final Map<String, dynamic>? jobDetails;

  const InternshipApplicationScreen({
    super.key,
    required this.userData,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.salaryRange,
    this.jobDetails,
  });

  @override
  State<InternshipApplicationScreen> createState() =>
      _InternshipApplicationScreenState();
}

class _InternshipApplicationScreenState
    extends State<InternshipApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _city = TextEditingController();
  final _linkedin = TextEditingController();
  final _portfolio = TextEditingController();
  final _github = TextEditingController();

  final _institution = TextEditingController();
  final _degree = TextEditingController();
  final _branch = TextEditingController();
  final _cgpa = TextEditingController();
  final _gradYear = TextEditingController();
  final _coursework = TextEditingController();

  final _experience = TextEditingController();
  final _skills = TextEditingController();
  final _projects = TextEditingController();
  final _certifications = TextEditingController();

  final _coverLetter = TextEditingController();
  final _whyCompany = TextEditingController();
  final _availabilityStart = TextEditingController();
  final _durationMonths = TextEditingController();
  String _workMode = 'Hybrid';

  final _expectedStipend = TextEditingController();
  final _resumeLink = TextEditingController();

  final _refName = TextEditingController();
  final _refPhone = TextEditingController();
  final _refRelation = TextEditingController();

  String? _resumeFileName;
  List<int>? _resumeBytes;
  String? _resumePickError;
  bool _declaration = false;
  bool _isSubmitting = false;

  static const int _maxResumeBytesForPayload = 700000;

  @override
  void initState() {
    super.initState();
    final u = widget.userData;
    _fullName.text = (u['name'] ?? '').toString();
    _email.text = (u['email'] ?? '').toString();
    _mobile.text = (u['mobile'] ?? '').toString();
    _city.text = (u['city'] ?? '').toString();
    _institution.text = (u['college_name'] ?? '').toString();
    _degree.text = (u['stream'] ?? '').toString();
    _cgpa.text = (u['gpa'] ?? '').toString();
    _gradYear.text = (u['graduation_year'] ?? '').toString();
    _skills.text = (u['skills'] ?? '').toString();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _mobile.dispose();
    _city.dispose();
    _linkedin.dispose();
    _portfolio.dispose();
    _github.dispose();
    _institution.dispose();
    _degree.dispose();
    _branch.dispose();
    _cgpa.dispose();
    _gradYear.dispose();
    _coursework.dispose();
    _experience.dispose();
    _skills.dispose();
    _projects.dispose();
    _certifications.dispose();
    _coverLetter.dispose();
    _whyCompany.dispose();
    _availabilityStart.dispose();
    _durationMonths.dispose();
    _expectedStipend.dispose();
    _resumeLink.dispose();
    _refName.dispose();
    _refPhone.dispose();
    _refRelation.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    setState(() {
      _resumePickError = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final f = result.files.single;
      final bytes = f.bytes;
      if (bytes == null) {
        setState(() {
          _resumePickError =
              'Could not read file. Try a smaller PDF or use the resume link field.';
        });
        return;
      }
      if (bytes.length > _maxResumeBytesForPayload) {
        setState(() {
          _resumePickError =
              'File is too large to send in-app (max ~${(_maxResumeBytesForPayload / 1000000).toStringAsFixed(1)}MB). '
              'Use a smaller PDF or paste a Google Drive / Dropbox link in Resume link.';
        });
        return;
      }
      setState(() {
        _resumeFileName = f.name;
        _resumeBytes = bytes.toList();
        _resumePickError = null;
      });
    } catch (e) {
      setState(() {
        _resumePickError = 'Could not pick file: $e';
      });
    }
  }

  void _clearResume() {
    setState(() {
      _resumeFileName = null;
      _resumeBytes = null;
      _resumePickError = null;
    });
  }

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
      filled: true,
      fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        decoration: _dec(label, icon),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  String? _req(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return null;
  }

  Future<void> _submit() async {
    if (!_declaration) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the declaration')),
      );
      return;
    }

    final hasResumeFile = _resumeBytes != null && _resumeBytes!.isNotEmpty;
    final hasResumeLink = _resumeLink.text.trim().length >= 12;
    if (!hasResumeFile && !hasResumeLink) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Attach a resume (PDF/DOC) or paste a resume link (Drive/Dropbox/Portfolio).',
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = <String, dynamic>{
      'job_id': widget.jobId,
      'job_title': widget.jobTitle,
      'company_name': widget.companyName,
      'salary_range_posted': widget.salaryRange,
      'full_name': _fullName.text.trim(),
      'email': _email.text.trim(),
      'mobile': _mobile.text.trim(),
      'city': _city.text.trim(),
      'linkedin_url': _linkedin.text.trim(),
      'portfolio_url': _portfolio.text.trim(),
      'github_url': _github.text.trim(),
      'institution': _institution.text.trim(),
      'degree_program': _degree.text.trim(),
      'branch_major': _branch.text.trim(),
      'cgpa_or_percentage': _cgpa.text.trim(),
      'graduation_year': _gradYear.text.trim(),
      'relevant_coursework': _coursework.text.trim(),
      'work_experience_internships': _experience.text.trim(),
      'skills': _skills.text.trim(),
      'projects': _projects.text.trim(),
      'certifications': _certifications.text.trim(),
      'cover_letter': _coverLetter.text.trim(),
      'why_this_role': _whyCompany.text.trim(),
      'availability_start': _availabilityStart.text.trim(),
      'internship_duration_months': _durationMonths.text.trim(),
      'work_mode_preference': _workMode,
      'expected_stipend': _expectedStipend.text.trim(),
      'resume_link': _resumeLink.text.trim(),
      'resume_filename': _resumeFileName ?? '',
      if (hasResumeFile)
        'resume_base64': base64Encode(_resumeBytes!),
      'reference_name': _refName.text.trim(),
      'reference_phone': _refPhone.text.trim(),
      'reference_relation': _refRelation.text.trim(),
    };

    final payload = {
      'user_id': widget.userData['id'],
      'type': 'job_apply',
      'data': data,
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.ok) {
      final extra = result.infoMessage.isNotEmpty ? ' ${result.infoMessage}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application submitted for ${widget.jobTitle}.$extra'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage.isEmpty
                ? 'Submission failed (HTTP ${result.statusCode}).'
                : result.errorMessage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Apply for internship',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        centerTitle: true,
      ),
      body: ResponsiveFormScroll(
        formKey: _formKey,
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.jobTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.companyName,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stipend / range: ${widget.salaryRange}',
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildJobDetails(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _section('Contact'),
              _field(_fullName, 'Full name', Icons.person, validator: _req),
              _field(
                _email,
                'Email',
                Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Valid email required' : null,
              ),
              _field(
                _mobile,
                'Mobile',
                Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.length < 10) ? 'Valid mobile required' : null,
              ),
              _field(_city, 'Current city', Icons.location_city, validator: _req),
              _field(
                _linkedin,
                'LinkedIn profile URL',
                Icons.link,
                validator: _req,
              ),
              _field(
                _portfolio,
                'Portfolio / website (optional)',
                Icons.language,
                validator: (_) => null,
              ),
              _field(
                _github,
                'GitHub profile (optional)',
                Icons.code,
                validator: (_) => null,
              ),
              _section('Education'),
              _field(
                _institution,
                'College / university',
                Icons.school,
                validator: _req,
              ),
              _field(
                _degree,
                'Degree / program (e.g. B.Tech CSE)',
                Icons.menu_book,
                validator: _req,
              ),
              _field(
                _branch,
                'Branch / specialisation',
                Icons.category,
                validator: _req,
              ),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _cgpa,
                      'CGPA or %',
                      Icons.grade,
                      validator: _req,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _gradYear,
                      'Graduation year',
                      Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      validator: _req,
                    ),
                  ),
                ],
              ),
              _field(
                _coursework,
                'Relevant coursework (optional)',
                Icons.list_alt,
                maxLines: 2,
                validator: (_) => null,
              ),
              _section('Resume & work samples'),
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _pickResume,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _resumeFileName == null
                      ? 'Attach resume (PDF, DOC, DOCX)'
                      : 'Change resume',
                ),
              ),
              if (_resumeFileName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _resumeFileName!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton(onPressed: _clearResume, child: const Text('Remove')),
                  ],
                ),
              ],
              if (_resumePickError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _resumePickError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
              const SizedBox(height: 8),
              _field(
                _resumeLink,
                'Or paste resume link (Google Drive, Dropbox, etc.)',
                Icons.cloud_upload,
                validator: (_) => null,
              ),
              _section('Experience & skills'),
              _field(
                _experience,
                'Previous internships / jobs (or type None)',
                Icons.work_history,
                maxLines: 4,
                validator: _req,
              ),
              _field(
                _skills,
                'Technical & soft skills (comma separated)',
                Icons.build,
                maxLines: 2,
                validator: _req,
              ),
              _field(
                _projects,
                'Key projects (brief — tech stack & outcome)',
                Icons.rocket_launch,
                maxLines: 4,
                validator: _req,
              ),
              _field(
                _certifications,
                'Certifications / competitions (optional)',
                Icons.military_tech,
                maxLines: 2,
                validator: (_) => null,
              ),
              _section('Application questions'),
              _field(
                _coverLetter,
                'Cover letter (why you + what you bring)',
                Icons.article,
                maxLines: 6,
                validator: (v) {
                  if (v == null || v.trim().length < 80) {
                    return 'Cover letter should be at least 80 characters';
                  }
                  return null;
                },
              ),
              _field(
                _whyCompany,
                'Why this company & role?',
                Icons.favorite,
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.trim().length < 40) {
                    return 'Please write at least 40 characters';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _availabilityStart,
                      'Available from (DD/MM/YYYY)',
                      Icons.event,
                      validator: _req,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _durationMonths,
                      'Duration you can commit (months)',
                      Icons.timelapse,
                      keyboardType: TextInputType.number,
                      validator: _req,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Work mode preference', style: TextStyle(color: Colors.grey.shade800)),
              DropdownButtonFormField<String>(
                value: _workMode,
                decoration: _dec('Work mode', Icons.work_outline),
                items: const [
                  DropdownMenuItem(value: 'On-site', child: Text('On-site')),
                  DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                  DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (v) => setState(() => _workMode = v ?? 'Hybrid'),
              ),
              const SizedBox(height: 8),
              _field(
                _expectedStipend,
                'Expected stipend (₹ / month, optional)',
                Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: (_) => null,
              ),
              _section('Reference (faculty / previous employer)'),
              _field(
                _refName,
                'Reference name',
                Icons.contact_page,
                validator: _req,
              ),
              _field(
                _refPhone,
                'Reference mobile',
                Icons.phone_in_talk,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.length < 10) ? 'Valid mobile' : null,
              ),
              _field(
                _refRelation,
                'How they know you (e.g. Course faculty)',
                Icons.link,
                validator: _req,
              ),
              CheckboxListTile(
                value: _declaration,
                onChanged: (v) => setState(() => _declaration = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I confirm the information is accurate and I consent to the employer contacting my reference and reviewing my resume.',
                  style: TextStyle(fontSize: 13, height: 1.35),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'SUBMIT APPLICATION',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
      ),
    );
  }

  Widget _buildJobDetails() {
    final d = widget.jobDetails;
    if (d == null) return const SizedBox.shrink();

    Map<String, dynamic> details = {};
    if (d['details'] is Map) {
      details = Map<String, dynamic>.from(d['details']);
    } else if (d['details'] is String) {
      try {
        details = jsonDecode(d['details']);
      } catch (_) {}
    }

    if (details.isEmpty && d['description'] == null) return const SizedBox.shrink();

    Widget infoRow(IconData icon, String label, String? val) {
      if (val == null || val.trim().isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label: $val',
                style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
        const Text("Job Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        infoRow(Icons.work_outline, "Type", details['job_type']),
        infoRow(Icons.computer, "Work Mode", details['work_mode']),
        infoRow(Icons.location_on, "Location", details['location']),
        infoRow(Icons.category, "Department", details['department']),
        infoRow(Icons.school, "Required Education", details['qualification']),
        infoRow(Icons.build, "Skills Required", details['skills_required']),
        infoRow(Icons.group, "Openings", details['openings']),
        infoRow(Icons.event, "Apply Before", details['application_deadline']),
        const SizedBox(height: 8),
        if ((d['description']?.toString() ?? details['description']?.toString() ?? '').isNotEmpty) ...[
          const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            d['description']?.toString() ?? details['description']?.toString() ?? '',
            style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
          ),
          const SizedBox(height: 8),
        ],
        if ((details['benefits']?.toString() ?? '').isNotEmpty) ...[
          const Text("Benefits & Perks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            details['benefits'].toString(),
            style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
