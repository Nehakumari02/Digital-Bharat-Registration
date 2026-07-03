import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:the_digital_registration/config/api_config.dart';
import 'package:the_digital_registration/controllers/lead_controller.dart';
import 'package:the_digital_registration/controllers/service_controller.dart';
import 'package:the_digital_registration/views/service_forms.dart';
import 'package:the_digital_registration/models/lead_model.dart';
import 'package:the_digital_registration/constants/lead_category.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';

/// Curated e-book list (static catalogue — replace with API when available).
class EbooksLibraryScreen extends StatelessWidget {
  final String? streamHint;

  const EbooksLibraryScreen({super.key, this.streamHint});

  static const _books = <Map<String, String>>[
    {
      'title': 'Indian Constitution at Work (NCERT)',
      'meta': 'Polity · Class XI–XII',
    },
    {
      'title': 'Introduction to Algorithms (Cormen et al.)',
      'meta': 'Computer Science · Reference',
    },
    {
      'title': 'RBI Financial Awareness Handbook',
      'meta': 'Banking & Economy · Govt publication',
    },
    {
      'title': 'English Grammar in Use (Murphy)',
      'meta': 'Language · Interview communication',
    },
    {
      'title': 'NCERT Mathematics (Class 12)',
      'meta': 'Quantitative aptitude base',
    },
    {
      'title': 'Ethics, Integrity & Aptitude (UPSC)',
      'meta': 'General Studies · Paper IV',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final hint = streamHint?.trim().isNotEmpty == true
        ? streamHint!
        : 'General studies';

    return Scaffold(
      appBar: AppBar(title: const Text('E-Books Library')),
      body: ResponsiveScrollBody(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Picks for your stream',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hint,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These titles are commonly used for competitive exams, campus placements, and skill building. Add your own PDFs later via your institution portal if linked.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._books.map(
            (b) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x1AF26522),
                  child: Icon(Icons.menu_book, color: Color(0xFF2196F3)),
                ),
                title: Text(
                  b['title']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(b['meta']!),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Open "${b['title']}" from your library app or institution LMS when linked.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SkillAssessmentsScreen extends StatelessWidget {
  final String? skillsCsv;

  const SkillAssessmentsScreen({super.key, this.skillsCsv});

  @override
  Widget build(BuildContext context) {
    final skills = skillsCsv
            ?.split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        <String>[];

    final topics = skills.isEmpty
        ? <String>[
            'Logical reasoning (25 min)',
            'Quantitative aptitude (30 min)',
            'English comprehension (20 min)',
          ]
        : skills
            .map(
              (s) => '$s — practice module (20 min)',
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Skill assessments')),
      body: ResponsiveScrollBody(
        children: [
          Text(
            skills.isEmpty
                ? 'No skills listed on your profile yet. Here are default placement-style modules you can try.'
                : 'Modules aligned with skills on your profile:',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          ...topics.asMap().entries.map(
                (e) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade50,
                      child: Text('${e.key + 1}'),
                    ),
                    title: Text(e.value),
                    subtitle: const Text('Tap to start a timed practice (local demo)'),
                    trailing: const Icon(Icons.play_circle_outline),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Demo: "${e.value}" would start here. Wire to your assessment API when ready.',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// College / university admission applications (central & state portals).
class OnlineAdmissionScreen extends StatelessWidget {
  const OnlineAdmissionScreen({super.key, this.userData});

  final Map<String, dynamic>? userData;

  String _v(String key) {
    final v = userData?[key];
    if (v == null) return '—';
    final s = v.toString().trim();
    return s.isEmpty || s == 'null' ? '—' : s;
  }

  static const _portals = <Map<String, String>>[
    {
      'name': 'CUET (UG) — NTA',
      'detail': 'Central universities & participating colleges',
      'status': 'Check registration window on nta.ac.in',
    },
    {
      'name': 'State CET / Board admission',
      'detail': 'Punjab, Maharashtra, Karnataka & other state portals',
      'status': 'Use your domicile state counselling site',
    },
    {
      'name': 'NCHM JEE / NEET / JEE',
      'detail': 'Professional & medical / engineering entrances',
      'status': 'Apply only on official NTA portals',
    },
    {
      'name': 'Study in India (SII)',
      'detail': 'Scholarships for international students in India',
      'status': 'studyinindia.gov.in',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online admission')),
      body: ResponsiveScrollBody(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Stream: ${_v('stream')}'),
                  Text('Year / class: ${_v('standard_year')}'),
                  Text('College (if any): ${_v('college_name')}'),
                  const SizedBox(height: 8),
                  Text(
                    'Keep marksheets, category certificate, and Aadhaar ready before applying.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Popular admission portals',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ..._portals.map(
            (p) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x1AF26522),
                  child: Icon(Icons.school_outlined, color: Color(0xFF2196F3)),
                ),
                title: Text(
                  p['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('${p['detail']}\n${p['status']}'),
                isThreeLine: true,
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Open ${p['name']} on the official website.'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// National Scholarship Portal & state schemes hub.
class ScholarshipPortalScreen extends StatelessWidget {
  const ScholarshipPortalScreen({super.key});

  static const _schemes = <Map<String, String>>[
    {
      'title': 'National Scholarship Portal (NSP)',
      'subtitle': 'Pre-matric, post-matric, merit & minority schemes',
    },
    {
      'title': 'PM Yasasvi Scholarship',
      'subtitle': 'OBC, EBC & DNT students — Class 9 to UG',
    },
    {
      'title': 'AICTE / UGC scholarships',
      'subtitle': 'Technical & university-level funding',
    },
    {
      'title': 'State scholarship portals',
      'subtitle': 'Punjab, UP, Bihar & other state e-Scholarship sites',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scholarship portal')),
      body: ResponsiveScrollBody(
        children: [
          Card(
            color: const Color(0xFFFFF4EB),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Apply on scholarships.gov.in (NSP) with your bank account linked to Aadhaar. '
                'Track renewal status each academic year before the deadline.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._schemes.map(
            (s) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x1A2196F3),
                  child: Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.blue),
                ),
                title: Text(
                  s['title']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(s['subtitle']!),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Browse ${s['title']} on the official portal.')),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScholarshipScreen(),
                ),
              );
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('View scheme deadlines in app'),
          ),
        ],
      ),
    );
  }
}

/// SWAYAM, DIKSHA, NPTEL and other govt learning platforms.
class DigitalLearningPlatformsScreen extends StatelessWidget {
  const DigitalLearningPlatformsScreen({super.key});

  static const _platforms = <Map<String, dynamic>>[
    {
      'name': 'SWAYAM',
      'icon': Icons.play_lesson,
      'color': 0xFF1565C0,
      'desc': 'Free MOOCs from IITs, IISc & top universities',
    },
    {
      'name': 'DIKSHA',
      'icon': Icons.cast_for_education,
      'color': 0xFF2E7D32,
      'desc': 'School & teacher learning content (NCERT aligned)',
    },
    {
      'name': 'NPTEL',
      'icon': Icons.engineering,
      'color': 0xFF6A1B9A,
      'desc': 'Engineering & science video courses with certification',
    },
    {
      'name': 'e-Pathshala',
      'icon': Icons.menu_book,
      'color': 0xFFE65100,
      'desc': 'NCERT textbooks & audio books (Classes I–XII)',
    },
    {
      'name': 'Skill India Digital',
      'icon': Icons.workspace_premium,
      'color': 0xFF2196F3,
      'desc': 'Short-term NSDC courses & employability skills',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital learning')),
      body: ResponsiveScrollBody(
        children: [
          Text(
            'Government-approved platforms for online study and upskilling.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          ..._platforms.map((p) {
            final color = Color(p['color'] as int);
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(p['icon'] as IconData, color: color),
                ),
                title: Text(
                  p['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(p['desc'] as String),
                trailing: const Icon(Icons.launch),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Open ${p['name']} in your browser.'),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// DigiLocker & verified online certificates.
class OnlineCertificatesScreen extends StatelessWidget {
  const OnlineCertificatesScreen({super.key, this.userData});

  final Map<String, dynamic>? userData;

  String _v(String key) {
    final v = userData?[key];
    if (v == null) return '—';
    final s = v.toString().trim();
    return s.isEmpty || s == 'null' ? '—' : s;
  }

  static const _types = <Map<String, String>>[
    {
      'title': 'DigiLocker',
      'body': 'Store marksheets, Aadhaar, driving licence & degree certificates',
    },
    {
      'title': 'NPTEL / SWAYAM certificates',
      'body': 'Download after passing proctored exams on the course portal',
    },
    {
      'title': 'Skill India credentials',
      'body': 'NSDC course completion & assessment certificates',
    },
    {
      'title': 'Internship completion',
      'body': 'Request letter from employer after verified internship',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online certificates')),
      body: ResponsiveScrollBody(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user, color: Color(0xFF2196F3)),
              title: const Text('Skills on your profile'),
              subtitle: Text(_v('skills')),
            ),
          ),
          const SizedBox(height: 12),
          ..._types.map(
            (t) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x1A4CAF50),
                  child: Icon(Icons.card_membership, color: Colors.green),
                ),
                title: Text(
                  t['title']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(t['body']!),
                trailing: const Icon(Icons.download_outlined),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Link ${t['title']} when API is connected.'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _profileField(Map<String, dynamic>? userData, String key) {
  final v = userData?[key];
  if (v == null) return '—';
  final s = v.toString().trim();
  return s.isEmpty || s == 'null' ? '—' : s;
}

// --- SHARED FORM HELPERS ---
InputDecoration _fieldStyle(BuildContext context, String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
    filled: true,
    fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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

Widget _formField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  String? Function(String?)? validator,
}) {
  return Builder(
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          decoration: _fieldStyle(context, label, icon),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          inputFormatters: keyboardType == TextInputType.number 
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))] 
              : null,
        ),
      );
    }
  );
}

String? _req(String? v, [String msg = 'Required']) {
  if (v == null || v.trim().isEmpty) return msg;
  return null;
}

String? _validatePan(String? v) {
  if (v == null || v.trim().isEmpty) return 'PAN is required';
  final p = v.trim().toUpperCase();
  if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(p)) {
    return 'Enter valid PAN (AAAAA9999A)';
  }
  return null;
}

String? _validateAadhaar(String? v) {
  if (v == null || v.trim().isEmpty) return 'Aadhaar is required';
  if (!RegExp(r'^\d{12}$').hasMatch(v.trim())) {
    return 'Aadhaar must be 12 digits';
  }
  return null;
}

String? _validateMobile(String? v) {
  if (v == null || v.trim().isEmpty) return 'Mobile is required';
  if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
    return 'Enter a valid 10-digit mobile number';
  }
  return null;
}

String? _validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email is required';
  if (!v.contains('@')) return 'Enter a valid email address';
  return null;
}

/// New GST registration on gst.gov.in.
class GstRegistrationScreen extends StatefulWidget {
  const GstRegistrationScreen({super.key, this.userData});

  final Map<String, dynamic>? userData;

  @override
  State<GstRegistrationScreen> createState() => _GstRegistrationScreenState();
}

class _GstRegistrationScreenState extends State<GstRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessName;
  late final TextEditingController _tradeName;
  late final TextEditingController _pan;
  late final TextEditingController _mobile;
  late final TextEditingController _email;
  late final TextEditingController _address;
  String _entityType = 'Proprietorship';
  bool _isSaving = false;
  bool _declarationAccepted = false;

  static const _steps = <Map<String, String>>[
    {
      'title': 'Check eligibility',
      'body': 'Turnover above threshold or interstate supply may require GST registration.',
    },
    {
      'title': 'Documents',
      'body': 'PAN, Aadhaar, business proof, address proof, bank account, photos of signatory.',
    },
    {
      'title': 'Apply on GST portal',
      'body': 'Register at reg.gst.gov.in → Part A (TRN) → Part B with documents.',
    },
    {
      'title': 'ARN & verification',
      'body': 'Track Application Reference Number; officer may visit premises if needed.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _businessName = TextEditingController(text: widget.userData?['company_name'] ?? '');
    _tradeName = TextEditingController(text: widget.userData?['company_name'] ?? '');
    _pan = TextEditingController(text: widget.userData?['pan'] ?? '');
    _mobile = TextEditingController(text: widget.userData?['mobile'] ?? '');
    _email = TextEditingController(text: widget.userData?['email'] ?? '');
    _address = TextEditingController(text: widget.userData?['address'] ?? '');
  }

  @override
  void dispose() {
    _businessName.dispose();
    _tradeName.dispose();
    _pan.dispose();
    _mobile.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the declaration')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = {
      "user_id": widget.userData?['id'] ?? 0,
      "type": "gst_reg",
      "data": {
        "legal_business_name": _businessName.text.trim(),
        "trade_name": _tradeName.text.trim(),
        "entity_type": _entityType,
        "pan": _pan.text.trim().toUpperCase(),
        "mobile": _mobile.text.trim(),
        "email": _email.text.trim(),
        "business_address": _address.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.ok) {
      final extra = result.infoMessage.isNotEmpty ? ' ${result.infoMessage}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GST registration request submitted successfully.$extra')),
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
    final gst = _profileField(widget.userData, 'gst_number');
    return Scaffold(
      appBar: AppBar(title: const Text('GST registration')),
      body: ResponsiveScrollBody(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business on profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Company: ${_profileField(widget.userData, 'company_name')}'),
                  Text('GSTIN (if any): $gst'),
                  Text('Turnover (lakhs): ${_profileField(widget.userData, 'turnover')}'),
                ],
              ),
            ),
          ),
          if (gst != '—') ...[
            const SizedBox(height: 8),
            Card(
              color: Colors.green.shade50,
              child: const ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('GSTIN already on file'),
                subtitle: Text('Use GST Portal for returns & e-invoicing.'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Apply for GST Registration', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    _formField(
                      controller: _businessName,
                      label: 'Legal Name of Business (as in PAN)',
                      icon: Icons.business,
                      validator: (v) => _req(v, 'Business name is required'),
                    ),
                    _formField(
                      controller: _tradeName,
                      label: 'Trade Name (if different)',
                      icon: Icons.store,
                      validator: (v) => _req(v, 'Trade name is required'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: _entityType,
                        decoration: _fieldStyle(context, 'Constitution of Business / Entity Type', Icons.category),
                        items: ['Proprietorship', 'Partnership', 'Private Limited Company', 'LLP', 'One Person Company', 'Public Limited Company', 'Others']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _entityType = val);
                        },
                      ),
                    ),
                    _formField(
                      controller: _pan,
                      label: 'Business PAN',
                      icon: Icons.badge,
                      validator: _validatePan,
                    ),
                    _formField(
                      controller: _mobile,
                      label: 'Mobile Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: _validateMobile,
                    ),
                    _formField(
                      controller: _email,
                      label: 'Email Address',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    _formField(
                      controller: _address,
                      label: 'Principal Place of Business (Address)',
                      icon: Icons.location_on,
                      maxLines: 2,
                      validator: (v) => _req(v, 'Address is required'),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _declarationAccepted,
                          onChanged: (val) {
                            if (val != null) setState(() => _declarationAccepted = val);
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'I declare that the information provided is correct and I authorize submission.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _submitForm,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Submit GST Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Registration steps', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ..._steps.asMap().entries.map(
                (e) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0x1AF26522),
                      child: Text('${e.key + 1}'),
                    ),
                    title: Text(
                      e.value['title']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(e.value['body']!),
                  ),
                ),
              ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GstOverviewScreen(userData: widget.userData ?? {}),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long),
            label: const Text('View saved GST details'),
          ),
        ],
      ),
    );
  }
}

/// Udyam / MSME registration.
class MsmeRegistrationScreen extends StatefulWidget {
  const MsmeRegistrationScreen({super.key, this.userData});

  final Map<String, dynamic>? userData;

  @override
  State<MsmeRegistrationScreen> createState() => _MsmeRegistrationScreenState();
}

class _MsmeRegistrationScreenState extends State<MsmeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _aadhaar;
  late final TextEditingController _promoterName;
  late final TextEditingController _enterpriseName;
  late final TextEditingController _pan;
  late final TextEditingController _mobile;
  late final TextEditingController _email;
  String _socialCategory = 'General';
  bool _isSaving = false;
  bool _declarationAccepted = false;

  static const _benefits = <String>[
    'Collateral-free loans under CGTMSE',
    'Priority sector lending & lower interest',
    'Tender preference & trade fair subsidies',
    'Protection against delayed payments (MSMED Act)',
  ];

  @override
  void initState() {
    super.initState();
    _aadhaar = TextEditingController();
    _promoterName = TextEditingController(text: widget.userData?['name'] ?? '');
    _enterpriseName = TextEditingController(text: widget.userData?['company_name'] ?? '');
    _pan = TextEditingController(text: widget.userData?['pan'] ?? '');
    _mobile = TextEditingController(text: widget.userData?['mobile'] ?? '');
    _email = TextEditingController(text: widget.userData?['email'] ?? '');
  }

  @override
  void dispose() {
    _aadhaar.dispose();
    _promoterName.dispose();
    _enterpriseName.dispose();
    _pan.dispose();
    _mobile.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the declaration')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = {
      "user_id": widget.userData?['id'] ?? 0,
      "type": "msme_reg",
      "data": {
        "aadhaar_number": _aadhaar.text.trim(),
        "promoter_name": _promoterName.text.trim(),
        "enterprise_name": _enterpriseName.text.trim(),
        "social_category": _socialCategory,
        "pan": _pan.text.trim().toUpperCase(),
        "mobile": _mobile.text.trim(),
        "email": _email.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.ok) {
      final extra = result.infoMessage.isNotEmpty ? ' ${result.infoMessage}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('MSME Udyam registration request submitted successfully.$extra')),
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
      appBar: AppBar(title: const Text('MSME registration')),
      body: ResponsiveScrollBody(
        children: [
          Card(
            color: const Color(0xFFFFF4EB),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Register free on udyamregistration.gov.in using Aadhaar + PAN. '
                'No documents upload needed for most micro & small enterprises.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your business profile', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Company: ${_profileField(widget.userData, 'company_name')}'),
                  Text('Employees: ${_profileField(widget.userData, 'employee_count')}'),
                  Text('Turnover: ${_profileField(widget.userData, 'turnover')} lakhs'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Apply for MSME/Udyam Registration', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    _formField(
                      controller: _aadhaar,
                      label: 'Aadhaar Number of Promoter',
                      icon: Icons.pin,
                      keyboardType: TextInputType.number,
                      validator: _validateAadhaar,
                    ),
                    _formField(
                      controller: _promoterName,
                      label: 'Name of Promoter (as in Aadhaar)',
                      icon: Icons.person,
                      validator: (v) => _req(v, 'Promoter name is required'),
                    ),
                    _formField(
                      controller: _enterpriseName,
                      label: 'Name of Enterprise',
                      icon: Icons.business,
                      validator: (v) => _req(v, 'Enterprise name is required'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: _socialCategory,
                        decoration: _fieldStyle(context, 'Social Category', Icons.people),
                        items: ['General', 'OBC', 'SC', 'ST']
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _socialCategory = val);
                        },
                      ),
                    ),
                    _formField(
                      controller: _pan,
                      label: 'Enterprise PAN',
                      icon: Icons.badge,
                      validator: _validatePan,
                    ),
                    _formField(
                      controller: _mobile,
                      label: 'Mobile Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: _validateMobile,
                    ),
                    _formField(
                      controller: _email,
                      label: 'Email Address',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _declarationAccepted,
                          onChanged: (val) {
                            if (val != null) setState(() => _declarationAccepted = val);
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'I declare that the information provided is correct and I authorize submission.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _submitForm,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Submit MSME Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Key benefits', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ..._benefits.map(
            (b) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.verified, color: Color(0xFF2196F3)),
                title: Text(b),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shop & Establishment Act licence (state labour department).
class ShopActLicenseScreen extends StatefulWidget {
  const ShopActLicenseScreen({super.key, this.userData});

  final Map<String, dynamic>? userData;

  @override
  State<ShopActLicenseScreen> createState() => _ShopActLicenseScreenState();
}

class _ShopActLicenseScreenState extends State<ShopActLicenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _establishmentName;
  late final TextEditingController _employerName;
  late final TextEditingController _natureOfBusiness;
  late final TextEditingController _address;
  late final TextEditingController _employeesCount;
  late final TextEditingController _commencementDate;
  late final TextEditingController _mobile;
  late final TextEditingController _email;
  bool _isSaving = false;
  bool _declarationAccepted = false;

  @override
  void initState() {
    super.initState();
    _establishmentName = TextEditingController(text: widget.userData?['company_name'] ?? '');
    _employerName = TextEditingController(text: widget.userData?['name'] ?? '');
    _natureOfBusiness = TextEditingController();
    _address = TextEditingController(text: widget.userData?['address'] ?? '');
    _employeesCount = TextEditingController(text: widget.userData?['employee_count']?.toString() ?? '');
    _commencementDate = TextEditingController();
    _mobile = TextEditingController(text: widget.userData?['mobile'] ?? '');
    _email = TextEditingController(text: widget.userData?['email'] ?? '');
  }

  @override
  void dispose() {
    _establishmentName.dispose();
    _employerName.dispose();
    _natureOfBusiness.dispose();
    _address.dispose();
    _employeesCount.dispose();
    _commencementDate.dispose();
    _mobile.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the declaration')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = {
      "user_id": widget.userData?['id'] ?? 0,
      "type": "shop_act",
      "data": {
        "establishment_name": _establishmentName.text.trim(),
        "employer_name": _employerName.text.trim(),
        "nature_of_business": _natureOfBusiness.text.trim(),
        "establishment_address": _address.text.trim(),
        "employees_count": _employeesCount.text.trim(),
        "commencement_date": _commencementDate.text.trim(),
        "mobile": _mobile.text.trim(),
        "email": _email.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.ok) {
      final extra = result.infoMessage.isNotEmpty ? ' ${result.infoMessage}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shop Act license application submitted successfully.$extra')),
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
    final state = _profileField(widget.userData, 'state');
    final district = _profileField(widget.userData, 'district');

    return Scaffold(
      appBar: AppBar(title: const Text('Shop Act licence')),
      body: ResponsiveScrollBody(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop & Establishment Act',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mandatory for shops, offices, hotels, restaurants & commercial establishments. '
                    'Rules vary by state — apply on your state labour / SHOPS portal.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Location: $district, $state'),
                  Text('Company: ${_profileField(widget.userData, 'company_name')}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Apply for Shop Act Licence', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    _formField(
                      controller: _establishmentName,
                      label: 'Name of Establishment',
                      icon: Icons.store,
                      validator: (v) => _req(v, 'Establishment name is required'),
                    ),
                    _formField(
                      controller: _employerName,
                      label: 'Name of Employer/Owner',
                      icon: Icons.person,
                      validator: (v) => _req(v, 'Employer name is required'),
                    ),
                    _formField(
                      controller: _natureOfBusiness,
                      label: 'Nature of Business (e.g. Retail, IT Services)',
                      icon: Icons.category,
                      validator: (v) => _req(v, 'Nature of business is required'),
                    ),
                    _formField(
                      controller: _address,
                      label: 'Establishment Address',
                      icon: Icons.location_on,
                      maxLines: 2,
                      validator: (v) => _req(v, 'Address is required'),
                    ),
                    _formField(
                      controller: _employeesCount,
                      label: 'Number of Employees',
                      icon: Icons.people,
                      keyboardType: TextInputType.number,
                      validator: (v) => _req(v, 'Employee count is required'),
                    ),
                    _formField(
                      controller: _commencementDate,
                      label: 'Commencement Date (DD/MM/YYYY)',
                      icon: Icons.calendar_today,
                      validator: (v) => _req(v, 'Commencement date is required'),
                    ),
                    _formField(
                      controller: _mobile,
                      label: 'Mobile Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: _validateMobile,
                    ),
                    _formField(
                      controller: _email,
                      label: 'Email Address',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _declarationAccepted,
                          onChanged: (val) {
                            if (val != null) setState(() => _declarationAccepted = val);
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'I declare that the information provided is correct and I authorize submission.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _submitForm,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Submit Shop Act Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const ListTile(
            leading: Icon(Icons.description_outlined, color: Color(0xFF2196F3)),
            title: Text('Documents usually required'),
            subtitle: Text(
              'PAN, address proof, rent agreement / ownership, employee count, '
              'business commencement date, proprietor ID proof.',
            ),
            isThreeLine: true,
          ),
          const ListTile(
            leading: Icon(Icons.schedule, color: Colors.blue),
            title: Text('Validity'),
            subtitle: Text(
              'Typically 1–5 years depending on state; renew before expiry to avoid penalties.',
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}

/// Company / LLP / partnership firm registration (MCA).
class CompanyFirmRegistrationScreen extends StatefulWidget {
  const CompanyFirmRegistrationScreen({super.key, this.userData});

  final Map<String, dynamic>? userData;

  @override
  State<CompanyFirmRegistrationScreen> createState() => _CompanyFirmRegistrationScreenState();
}

class _CompanyFirmRegistrationScreenState extends State<CompanyFirmRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _proposedName1;
  late final TextEditingController _proposedName2;
  late final TextEditingController _directorsCount;
  late final TextEditingController _address;
  late final TextEditingController _shareCapital;
  late final TextEditingController _mobile;
  late final TextEditingController _email;
  String _companyType = 'Private Limited Company';
  bool _isSaving = false;
  bool _declarationAccepted = false;

  static const _types = <Map<String, String>>[
    {
      'name': 'Private Limited Company',
      'desc': 'Separate legal entity · ideal for funded startups & scale',
    },
    {
      'name': 'LLP (Limited Liability Partnership)',
      'desc': 'Professional firms · partners with limited liability',
    },
    {
      'name': 'Partnership Firm',
      'desc': 'Simple structure · register deed with Registrar of Firms',
    },
    {
      'name': 'Proprietorship',
      'desc': 'Single owner · no separate MCA registration; GST/Shop Act may apply',
    },
  ];

  @override
  void initState() {
    super.initState();
    _proposedName1 = TextEditingController(text: widget.userData?['company_name'] ?? '');
    _proposedName2 = TextEditingController();
    _directorsCount = TextEditingController(text: '2');
    _address = TextEditingController(text: widget.userData?['address'] ?? '');
    _shareCapital = TextEditingController(text: '100000');
    _mobile = TextEditingController(text: widget.userData?['mobile'] ?? '');
    _email = TextEditingController(text: widget.userData?['email'] ?? '');
  }

  @override
  void dispose() {
    _proposedName1.dispose();
    _proposedName2.dispose();
    _directorsCount.dispose();
    _address.dispose();
    _shareCapital.dispose();
    _mobile.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the declaration')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = {
      "user_id": widget.userData?['id'] ?? 0,
      "type": "company_firm",
      "data": {
        "proposed_name_1": _proposedName1.text.trim(),
        "proposed_name_2": _proposedName2.text.trim(),
        "company_type": _companyType,
        "directors_count": _directorsCount.text.trim(),
        "registered_address": _address.text.trim(),
        "share_capital": _shareCapital.text.trim(),
        "mobile": _mobile.text.trim(),
        "email": _email.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.ok) {
      final extra = result.infoMessage.isNotEmpty ? ' ${result.infoMessage}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Company/Firm incorporation request submitted successfully.$extra')),
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
      appBar: AppBar(title: const Text('Company / firm registration')),
      body: ResponsiveScrollBody(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Incorporate on MCA portal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Companies & LLPs are registered on mca.gov.in via SPICe+ / FiLLiP forms. '
                    'Get DIN, digital signature & name approval before filing.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Proposed name: ${_profileField(widget.userData, 'company_name')}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Apply for Incorporation / Registration', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    _formField(
                      controller: _proposedName1,
                      label: 'Proposed Name Option 1',
                      icon: Icons.title,
                      validator: (v) => _req(v, 'Proposed name 1 is required'),
                    ),
                    _formField(
                      controller: _proposedName2,
                      label: 'Proposed Name Option 2',
                      icon: Icons.title,
                      validator: (v) => _req(v, 'Proposed name 2 is required'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: _companyType,
                        decoration: _fieldStyle(context, 'Type of Entity', Icons.category),
                        items: ['Private Limited Company', 'LLP (Limited Liability Partnership)', 'One Person Company', 'Partnership Firm', 'Proprietorship']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _companyType = val);
                        },
                      ),
                    ),
                    _formField(
                      controller: _directorsCount,
                      label: 'Number of Directors / Partners',
                      icon: Icons.people,
                      keyboardType: TextInputType.number,
                      validator: (v) => _req(v, 'Directors count is required'),
                    ),
                    _formField(
                      controller: _address,
                      label: 'Registered Office Address',
                      icon: Icons.location_on,
                      maxLines: 2,
                      validator: (v) => _req(v, 'Address is required'),
                    ),
                    _formField(
                      controller: _shareCapital,
                      label: 'Authorized Share Capital (INR)',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      validator: (v) => _req(v, 'Share capital is required'),
                    ),
                    _formField(
                      controller: _mobile,
                      label: 'Mobile Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: _validateMobile,
                    ),
                    _formField(
                      controller: _email,
                      label: 'Email Address',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _declarationAccepted,
                          onChanged: (val) {
                            if (val != null) setState(() => _declarationAccepted = val);
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'I declare that the information provided is correct and I authorize submission.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _submitForm,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Submit Incorporation Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Company / Firm Types', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ..._types.map(
            (t) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x1A3F51B5),
                  child: Icon(Icons.business, color: Colors.indigo),
                ),
                title: Text(
                  t['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(t['desc']!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Digital Marketing Support.
class DigitalMarketingSupportScreen extends StatefulWidget {
  const DigitalMarketingSupportScreen({super.key, this.userData});

  final Map<String, dynamic>? userData;

  @override
  State<DigitalMarketingSupportScreen> createState() => _DigitalMarketingSupportScreenState();
}

class _DigitalMarketingSupportScreenState extends State<DigitalMarketingSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessName;
  late final TextEditingController _contactPerson;
  late final TextEditingController _targetLocation;
  late final TextEditingController _mobile;
  late final TextEditingController _email;
  late final TextEditingController _extraNotes;
  String _marketingPlatform = 'Meta Ads (Facebook & Instagram)';
  String _marketingBudget = 'Under ₹10,000';
  bool _isSaving = false;
  bool _declarationAccepted = false;

  @override
  void initState() {
    super.initState();
    _businessName = TextEditingController(text: widget.userData?['company_name'] ?? '');
    _contactPerson = TextEditingController(text: widget.userData?['name'] ?? '');
    _targetLocation = TextEditingController();
    _mobile = TextEditingController(text: widget.userData?['mobile'] ?? '');
    _email = TextEditingController(text: widget.userData?['email'] ?? '');
    _extraNotes = TextEditingController();
  }

  @override
  void dispose() {
    _businessName.dispose();
    _contactPerson.dispose();
    _targetLocation.dispose();
    _mobile.dispose();
    _email.dispose();
    _extraNotes.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the declaration')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = {
      "user_id": widget.userData?['id'] ?? 0,
      "type": "marketing_support",
      "data": {
        "business_name": _businessName.text.trim(),
        "contact_person": _contactPerson.text.trim(),
        "platform_of_choice": _marketingPlatform,
        "monthly_budget": _marketingBudget,
        "target_location": _targetLocation.text.trim(),
        "mobile": _mobile.text.trim(),
        "email": _email.text.trim(),
        "extra_notes": _extraNotes.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.ok) {
      final extra = result.infoMessage.isNotEmpty ? ' ${result.infoMessage}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Digital marketing support request submitted successfully.$extra')),
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
      appBar: AppBar(title: const Text('Digital Marketing Support')),
      body: ResponsiveScrollBody(
        children: [
          Card(
            color: const Color(0xFFE3F2FD),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Boost Your Business Online',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Get expert assistance with Facebook/Instagram Ads, Google SEO, YouTube campaigns, and localized targeting. Fill out this form and our marketing team will connect with a customized strategy.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Marketing Request Form', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    _formField(
                      controller: _businessName,
                      label: 'Business Name',
                      icon: Icons.business,
                      validator: (v) => _req(v, 'Business name is required'),
                    ),
                    _formField(
                      controller: _contactPerson,
                      label: 'Contact Person Name',
                      icon: Icons.person,
                      validator: (v) => _req(v, 'Contact person name is required'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: _marketingPlatform,
                        decoration: _fieldStyle(context, 'Preferred Advertising Platform', Icons.campaign),
                        items: [
                          'Meta Ads (Facebook & Instagram)',
                          'Google Ads & Search',
                          'YouTube Marketing',
                          'SEO & Website Optimization',
                          'Social Media Management',
                          'Bulk SMS / Email Campaign'
                        ]
                            .map((platform) => DropdownMenuItem(value: platform, child: Text(platform)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _marketingPlatform = val);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: _marketingBudget,
                        decoration: _fieldStyle(context, 'Estimated Monthly Budget', Icons.monetization_on),
                        items: ['Under ₹10,000', '₹10,000 - ₹25,000', '₹25,000 - ₹50,000', 'Over ₹50,000']
                            .map((budget) => DropdownMenuItem(value: budget, child: Text(budget)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _marketingBudget = val);
                        },
                      ),
                    ),
                    _formField(
                      controller: _targetLocation,
                      label: 'Target Audience Location (e.g. Mumbai, Maharashtra)',
                      icon: Icons.map,
                      validator: (v) => _req(v, 'Target location is required'),
                    ),
                    _formField(
                      controller: _mobile,
                      label: 'Mobile Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: _validateMobile,
                    ),
                    _formField(
                      controller: _email,
                      label: 'Email Address',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    _formField(
                      controller: _extraNotes,
                      label: 'Campaign Objectives / Requirements',
                      icon: Icons.note_alt,
                      maxLines: 3,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _declarationAccepted,
                          onChanged: (val) {
                            if (val != null) setState(() => _declarationAccepted = val);
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'I agree to be contacted by the marketing team with proposals.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _submitForm,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Submit Marketing Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GstOverviewScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const GstOverviewScreen({super.key, required this.userData});

  String _v(String key) => _profileField(userData, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GST & business')),
      body: ResponsiveScrollBody(
        children: [
          _tile(context, 'Company', _v('company_name')),
          _tile(context, 'GST number', _v('gst_number')),
          _tile(context, 'Annual turnover (lakhs)', _v('turnover')),
          _tile(context, 'Employees', _v('employee_count')),
          _tile(context, 'Website', _v('business_website')),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Official return filing and e-invoicing are done on the government GST portal. '
                'This screen only shows what you saved during registration; update details from Profile → Personal Details when your backend supports edits.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}

class WeatherAdvisoryScreen extends StatefulWidget {
  final String? district;
  final String? state;

  const WeatherAdvisoryScreen({super.key, this.district, this.state});

  @override
  State<WeatherAdvisoryScreen> createState() => _WeatherAdvisoryScreenState();
}

class _WeatherAdvisoryScreenState extends State<WeatherAdvisoryScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    // Prefer district, then state. If both empty, default to Delhi.
    final loc = widget.district?.trim().isNotEmpty == true 
      ? widget.district!.trim() 
      : (widget.state?.trim().isNotEmpty == true ? widget.state!.trim() : 'Delhi');

    final data = await WeatherService.getCurrentWeather(loc);
    
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = [
      if (widget.district != null && widget.district!.trim().isNotEmpty) widget.district!.trim(),
      if (widget.state != null && widget.state!.trim().isNotEmpty) widget.state!.trim(),
    ].join(', ');
    final heading = loc.isEmpty ? 'Your area' : loc;

    return Scaffold(
      appBar: AppBar(title: const Text('Weather & Crop Planning')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)))
        : ResponsiveScrollBody(
            children: [
              Text(
                'Live Advisory for $heading',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (_weatherData != null) ...[
                _buildWeatherCard(),
                const SizedBox(height: 24),
                Text('Farming Tips for Today', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...WeatherService.getFarmingTips(_weatherData!['weathercode']).map((tip) => _buildTipTile(tip)),
              ] else ...[
                const Text('Could not load live weather data for your area.', style: TextStyle(color: Colors.red)),
              ]
            ],
          ),
    );
  }

  Widget _buildWeatherCard() {
    final temp = _weatherData!['temperature'];
    final windspeed = _weatherData!['windspeed'];
    final code = _weatherData!['weathercode'];
    final isDay = _weatherData!['is_day'];

    final desc = WeatherService.getWeatherDescription(code, isDay);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDay == 1 
            ? [Colors.blue.shade300, Colors.blue.shade600] 
            : [Colors.indigo.shade500, Colors.indigo.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$temp°C',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                desc['description']!,
                style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.air, size: 16, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text('$windspeed km/h wind', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ],
          ),
          Text(
            desc['emoji']!,
            style: const TextStyle(fontSize: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildTipTile(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(tip, style: TextStyle(fontSize: 16, height: 1.4, color: Theme.of(context).colorScheme.onSurface))),
        ],
      ),
    );
  }
}

class BankGuidelinesScreen extends StatelessWidget {
  const BankGuidelinesScreen({super.key});

  static const _items = <String>[
    'Verify applicant identity and KYC documents before moving a lead to approved.',
    'Confirm loan purpose matches the product (education, MSME, Kisan) before disbursement checklist.',
    'Log interest rate and tenure in line with your branch policy and RBI fair-practice norms.',
    'Do not share customer PII outside approved bank systems.',
    'Escalate suspicious applications to compliance rather than approving on the portal alone.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Branch guidelines')),
      body: ResponsiveScrollBody(
        children: [
          Text(
            'Internal checklist for loan lead handling on this portal:',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          ..._items.asMap().entries.map(
                (e) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${e.key + 1}'),
                    ),
                    title: Text(e.value),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class PortalPolicyScreen extends StatelessWidget {
  final String category;

  const PortalPolicyScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portal policies')),
      body: ResponsiveScrollBody(
        children: [
          Text(
            'Account type: $category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _section(
            'Data we store',
            'Name, contact, category-specific fields you submitted at registration, and service forms you complete in-app. Passwords are not shown again after signup.',
          ),
          _section(
            'How we use it',
            'To show the correct services, match bank users to nearby leads where implemented, and display your own submissions back to you.',
          ),
          _section(
            'Your controls',
            'Use Profile → Personal Details to review stored fields. Use Settings for notifications. Contact support for account corrections.',
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Builder(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(fontSize: 14, height: 1.45, color: Theme.of(context).colorScheme.onSurface)),
            ],
          );
        }
      ),
    );
  }
}

class OnlineBankingScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const OnlineBankingScreen({super.key, this.userData});

  @override
  State<OnlineBankingScreen> createState() => _OnlineBankingScreenState();
}

class _OnlineBankingScreenState extends State<OnlineBankingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _branchController;
  late final TextEditingController _commentsController;

  String _accountType = 'Savings';
  bool _isLoading = false;
  final List<LeadModel> _mySubmissions = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.userData?['mobile'] ?? '');
    _emailController = TextEditingController(text: widget.userData?['email'] ?? '');
    _branchController = TextEditingController();
    _commentsController = TextEditingController();
    _loadSubmissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _branchController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    final userId = int.tryParse(widget.userData?['id']?.toString() ?? '0') ?? 0;
    if (userId == 0) return;
    setState(() => _isLoading = true);
    try {
      final loans = await LeadController().fetchUserLoans(userId, category: LeadCategory.business);
      if (!mounted) return;
      setState(() {
        _mySubmissions.clear();
        _mySubmissions.addAll(loans.where((l) => l.loanType == 'Online Banking'));
      });
    } catch (e) {
      debugPrint('Error loading online banking leads: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _submitLead() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final payload = {
      "user_id": widget.userData?['id'] ?? 1,
      "type": "online_banking_reg",
      "data": {
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "branch": _branchController.text.trim(),
        "account_type": _accountType,
        "comments": _commentsController.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Online Banking lead generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _branchController.clear();
      _commentsController.clear();
      _loadSubmissions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${result.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Banking Lead Form'),
        backgroundColor: Colors.blue.withOpacity(0.05),
        elevation: 0,
      ),
      body: ResponsiveScrollBody(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.withOpacity(0.15), Colors.blue.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Apply for Online Banking',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Submit a lead to open a new digital banking account and get access to internet banking services.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

            final formWidget = Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Banking Account Lead Details',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _formField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (v) => _req(v, 'Name is required'),
                      ),
                      _formField(
                        controller: _phoneController,
                        label: 'Mobile Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.number,
                        validator: _validateMobile,
                      ),
                      _formField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      _formField(
                        controller: _branchController,
                        label: 'Preferred Branch / City',
                        icon: Icons.location_city,
                        validator: (v) => _req(v, 'Preferred branch is required'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: _accountType,
                          decoration: _fieldStyle(context, 'Account Type', Icons.layers),
                          items: ['Savings', 'Current', 'Salary']
                              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _accountType = val);
                          },
                        ),
                      ),
                      _formField(
                        controller: _commentsController,
                        label: 'Additional Requirements / Comments',
                        icon: Icons.comment,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _submitLead,
                          icon: const Icon(Icons.send),
                          label: const Text('Submit Application'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            final listWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Submissions',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
                    : _mySubmissions.isEmpty
                        ? Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  'No previous submissions found.',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _mySubmissions.length,
                            itemBuilder: (context, idx) {
                              final lead = _mySubmissions[idx];
                              final isApproved = lead.status.toLowerCase() == 'approved';
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: (isApproved ? Colors.green : Colors.orange).withOpacity(0.1),
                                    child: Icon(
                                      isApproved ? Icons.check_circle : Icons.hourglass_empty,
                                      color: isApproved ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                  title: Text(
                                    'Online Banking (${lead.extraData['account_type'] ?? 'Savings'})',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Branch: ${lead.extraData['branch'] ?? 'N/A'}\nSubmitted: ${lead.extraData['comments'] ?? ''}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isApproved ? Colors.green : Colors.orange).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      lead.status.toUpperCase(),
                                      style: TextStyle(
                                        color: isApproved ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: formWidget),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: listWidget),
                ],
              );
            } else {
              return Column(
                children: [
                  formWidget,
                  const SizedBox(height: 20),
                  listWidget,
                ],
              );
            }
          }),
        ],
      ),
    );
  }
}

class UpiPaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const UpiPaymentScreen({super.key, this.userData});

  @override
  State<UpiPaymentScreen> createState() => _UpiPaymentScreenState();
}

class _UpiPaymentScreenState extends State<UpiPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _merchantNameController;
  late final TextEditingController _preferredUpiController;
  late final TextEditingController _volumeController;

  bool _isLoading = false;
  final List<LeadModel> _mySubmissions = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.userData?['mobile'] ?? '');
    _emailController = TextEditingController(text: widget.userData?['email'] ?? '');
    _merchantNameController = TextEditingController(text: widget.userData?['company_name'] ?? '');
    _preferredUpiController = TextEditingController();
    _volumeController = TextEditingController();
    _loadSubmissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _merchantNameController.dispose();
    _preferredUpiController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    final userId = int.tryParse(widget.userData?['id']?.toString() ?? '0') ?? 0;
    if (userId == 0) return;
    setState(() => _isLoading = true);
    try {
      final loans = await LeadController().fetchUserLoans(userId, category: LeadCategory.business);
      if (!mounted) return;
      setState(() {
        _mySubmissions.clear();
        _mySubmissions.addAll(loans.where((l) => l.loanType == 'UPI Payments'));
      });
    } catch (e) {
      debugPrint('Error loading UPI payment leads: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _submitLead() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final payload = {
      "user_id": widget.userData?['id'] ?? 1,
      "type": "upi_payment_reg",
      "data": {
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "merchant_name": _merchantNameController.text.trim(),
        "preferred_upi": '${_preferredUpiController.text.trim().toLowerCase()}@upi',
        "estimated_volume": _volumeController.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ UPI Payments lead generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _preferredUpiController.clear();
      _volumeController.clear();
      _loadSubmissions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${result.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Payment Lead Form'),
        backgroundColor: Colors.pink.withOpacity(0.05),
        elevation: 0,
      ),
      body: ResponsiveScrollBody(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.withOpacity(0.15), Colors.purple.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.qr_code_scanner, color: Colors.pink, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Apply for UPI Merchant Onboarding',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Submit a lead to register your business for UPI payments, request merchant QR codes, and enable digital collection.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

            final formWidget = Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UPI Merchant Details',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _formField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (v) => _req(v, 'Name is required'),
                      ),
                      _formField(
                        controller: _phoneController,
                        label: 'Mobile Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.number,
                        validator: _validateMobile,
                      ),
                      _formField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      _formField(
                        controller: _merchantNameController,
                        label: 'Business / Merchant Name',
                        icon: Icons.store,
                        validator: (v) => _req(v, 'Merchant name is required'),
                      ),
                      _formField(
                        controller: _preferredUpiController,
                        label: 'Preferred UPI Handle Prefix (e.g. shopname)',
                        icon: Icons.alternate_email,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'UPI Handle is required';
                          if (v.contains('@')) return 'Enter prefix only (domain @upi will be appended)';
                          return null;
                        },
                      ),
                      _formField(
                        controller: _volumeController,
                        label: 'Estimated Monthly Transaction Volume (₹)',
                        icon: Icons.currency_rupee,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Estimated volume is required';
                          if (double.tryParse(v) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _submitLead,
                          icon: const Icon(Icons.send),
                          label: const Text('Submit Application'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink.shade700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            final listWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Submissions',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
                    : _mySubmissions.isEmpty
                        ? Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  'No previous submissions found.',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _mySubmissions.length,
                            itemBuilder: (context, idx) {
                              final lead = _mySubmissions[idx];
                              final isApproved = lead.status.toLowerCase() == 'approved';
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: (isApproved ? Colors.green : Colors.orange).withOpacity(0.1),
                                    child: Icon(
                                      isApproved ? Icons.check_circle : Icons.hourglass_empty,
                                      color: isApproved ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                  title: Text(
                                    'UPI Merchant (${lead.extraData['merchant_name'] ?? 'N/A'})',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'VPA: ${lead.extraData['preferred_upi'] ?? 'N/A'}\nEst. Volume: ₹${lead.extraData['estimated_volume'] ?? '0'}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isApproved ? Colors.green : Colors.orange).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      lead.status.toUpperCase(),
                                      style: TextStyle(
                                        color: isApproved ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: formWidget),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: listWidget),
                ],
              );
            } else {
              return Column(
                children: [
                  formWidget,
                  const SizedBox(height: 20),
                  listWidget,
                ],
              );
            }
          })
        ],
      ),
    );
  }
}

class DirectBenefitTransferScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const DirectBenefitTransferScreen({super.key, this.userData});

  @override
  State<DirectBenefitTransferScreen> createState() => _DirectBenefitTransferScreenState();
}

class _DirectBenefitTransferScreenState extends State<DirectBenefitTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _aadhaarController;
  late final TextEditingController _bankAccountController;
  late final TextEditingController _ifscController;

  String _schemeName = 'PM-Kisan';
  bool _consentAccepted = false;
  bool _isLoading = false;
  final List<LeadModel> _mySubmissions = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.userData?['mobile'] ?? '');
    _aadhaarController = TextEditingController();
    _bankAccountController = TextEditingController();
    _ifscController = TextEditingController();
    _loadSubmissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _aadhaarController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    final userId = int.tryParse(widget.userData?['id']?.toString() ?? '0') ?? 0;
    if (userId == 0) return;
    setState(() => _isLoading = true);
    try {
      final loans = await LeadController().fetchUserLoans(userId, category: LeadCategory.business);
      if (!mounted) return;
      setState(() {
        _mySubmissions.clear();
        _mySubmissions.addAll(loans.where((l) => l.loanType == 'Direct Benefit Transfer'));
      });
    } catch (e) {
      debugPrint('Error loading DBT leads: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _submitLead() async {
    if (!_consentAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the consent checkbox to link Aadhaar for DBT.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final payload = {
      "user_id": widget.userData?['id'] ?? 1,
      "type": "dbt_reg",
      "data": {
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "aadhaar": _aadhaarController.text.trim(),
        "bank_account": _bankAccountController.text.trim(),
        "ifsc": _ifscController.text.trim().toUpperCase(),
        "scheme_name": _schemeName,
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ DBT linking lead generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _aadhaarController.clear();
      _bankAccountController.clear();
      _ifscController.clear();
      setState(() => _consentAccepted = false);
      _loadSubmissions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${result.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DBT Scheme Lead Form'),
        backgroundColor: Colors.amber.withOpacity(0.05),
        elevation: 0,
      ),
      body: ResponsiveScrollBody(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.withOpacity(0.15), Colors.orange.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sync_alt, color: Colors.amber, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Apply for Direct Benefit Transfer linking',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Submit a lead to link your bank account to Aadhaar for receiving government DBT scheme funds (e.g. PM-Kisan, Scholarships, PM-GaribKalyan).',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

            final formWidget = Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DBT Scheme & Bank Account Details',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _formField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (v) => _req(v, 'Name is required'),
                      ),
                      _formField(
                        controller: _phoneController,
                        label: 'Mobile Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.number,
                        validator: _validateMobile,
                      ),
                      _formField(
                        controller: _aadhaarController,
                        label: 'Aadhaar Number (12 digits)',
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        validator: _validateAadhaar,
                      ),
                      _formField(
                        controller: _bankAccountController,
                        label: 'Bank Account Number',
                        icon: Icons.account_balance,
                        keyboardType: TextInputType.number,
                        validator: (v) => _req(v, 'Bank account is required'),
                      ),
                      _formField(
                        controller: _ifscController,
                        label: 'IFSC Code',
                        icon: Icons.domain,
                        validator: (v) => _req(v, 'IFSC code is required'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<String>(
                          value: _schemeName,
                          decoration: _fieldStyle(context, 'Target DBT Scheme', Icons.assignment),
                          items: ['PM-Kisan', 'PM-GaribKalyan', 'PM-Scholarship', 'LPG Subsidy', 'Others']
                              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _schemeName = val);
                          },
                        ),
                      ),
                      CheckboxListTile(
                        value: _consentAccepted,
                        title: const Text(
                          'I authorize the bank to use my Aadhaar details to link with my bank account for receiving DBT benefits.',
                          style: TextStyle(fontSize: 13),
                        ),
                        activeColor: Colors.amber.shade700,
                        onChanged: (val) {
                          if (val != null) setState(() => _consentAccepted = val);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _submitLead,
                          icon: const Icon(Icons.send),
                          label: const Text('Submit Application'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            final listWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Submissions',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
                    : _mySubmissions.isEmpty
                        ? Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  'No previous submissions found.',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _mySubmissions.length,
                            itemBuilder: (context, idx) {
                              final lead = _mySubmissions[idx];
                              final isApproved = lead.status.toLowerCase() == 'approved';
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: (isApproved ? Colors.green : Colors.orange).withOpacity(0.1),
                                    child: Icon(
                                      isApproved ? Icons.check_circle : Icons.hourglass_empty,
                                      color: isApproved ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                  title: Text(
                                    'DBT Link (' + (lead.extraData['scheme_name'] ?? 'N/A') + ')',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'A/C: ' + (lead.extraData['bank_account'] ?? 'N/A') + ' · IFSC: ' + (lead.extraData['ifsc'] ?? 'N/A') + '\nAadhaar: ' + (lead.extraData['aadhaar'] ?? 'N/A'),
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isApproved ? Colors.green : Colors.orange).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      lead.status.toUpperCase(),
                                      style: TextStyle(
                                        color: isApproved ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: formWidget),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: listWidget),
                ],
              );
            } else {
              return Column(
                children: [
                  formWidget,
                  const SizedBox(height: 20),
                  listWidget,
                ],
              );
            }
          }),
        ],
      ),
    );
  }
}

class JanDhanYojnaScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const JanDhanYojnaScreen({super.key, this.userData});

  @override
  State<JanDhanYojnaScreen> createState() => _JanDhanYojnaScreenState();
}

class _JanDhanYojnaScreenState extends State<JanDhanYojnaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _aadhaarController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nomineeController;
  late final TextEditingController _relationController;

  bool _isLoading = false;
  final List<LeadModel> _mySubmissions = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.userData?['mobile'] ?? '');
    _aadhaarController = TextEditingController();
    _nomineeController = TextEditingController();
    _relationController = TextEditingController();
    _loadSubmissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aadhaarController.dispose();
    _phoneController.dispose();
    _nomineeController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    final userId = int.tryParse(widget.userData?['id']?.toString() ?? '0') ?? 0;
    if (userId == 0) return;
    setState(() => _isLoading = true);
    try {
      final loans = await LeadController().fetchUserLoans(userId, category: LeadCategory.business);
      if (!mounted) return;
      setState(() {
        _mySubmissions.clear();
        _mySubmissions.addAll(loans.where((l) => l.loanType == 'Jan Dhan Account'));
      });
    } catch (e) {
      debugPrint('Error loading Jan Dhan leads: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _submitLead() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = {
      "user_id": widget.userData?['id'] ?? 1,
      "type": "jan_dhan_reg",
      "data": {
        "name": _nameController.text.trim(),
        "aadhaar": _aadhaarController.text.trim(),
        "phone": _phoneController.text.trim(),
        "nominee": _nomineeController.text.trim(),
        "relation": _relationController.text.trim(),
        "accNo": 'JDY82910${DateTime.now().millisecond % 10000}',
        "rupayStatus": 'Created',
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ PMJDY Zero-Balance Account Lead generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _aadhaarController.clear();
      _nomineeController.clear();
      _relationController.clear();
      _loadSubmissions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${result.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jan Dhan Yojna Lead Form'),
        backgroundColor: Colors.cyan.withOpacity(0.05),
        elevation: 0,
      ),
      body: ResponsiveScrollBody(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan.withOpacity(0.15), Colors.blue.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_outline, color: Colors.cyan, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'PM Jan Dhan Yojna Accounts',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Submit a lead to open a PMJDY zero-balance savings account with micro overdraft options and RuPay debit card.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            
            final formWidget = Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Open Zero-Balance Account',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _formField(
                        controller: _nameController,
                        label: 'Full Name (as in Aadhaar)',
                        icon: Icons.person,
                        validator: (v) => _req(v, 'Name is required'),
                      ),
                      _formField(
                        controller: _aadhaarController,
                        label: 'Aadhaar Number (12 digits)',
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        validator: _validateAadhaar,
                      ),
                      _formField(
                        controller: _phoneController,
                        label: 'Mobile Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.number,
                        validator: _validateMobile,
                      ),
                      _formField(
                        controller: _nomineeController,
                        label: 'Nominee Name',
                        icon: Icons.face,
                        validator: (v) => _req(v, 'Nominee name is required'),
                      ),
                      _formField(
                        controller: _relationController,
                        label: 'Nominee Relationship (e.g. Spouse)',
                        icon: Icons.family_restroom,
                        validator: (v) => _req(v, 'Nominee relationship is required'),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _submitLead,
                          icon: const Icon(Icons.how_to_reg),
                          label: const Text('Submit Application'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan.shade700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            final listWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Submissions',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
                    : _mySubmissions.isEmpty
                        ? Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  'No previous submissions found.',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _mySubmissions.length,
                            itemBuilder: (context, idx) {
                              final lead = _mySubmissions[idx];
                              final isApproved = lead.status.toLowerCase() == 'approved';
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: (isApproved ? Colors.green : Colors.orange).withOpacity(0.1),
                                    child: Icon(
                                      isApproved ? Icons.check_circle : Icons.hourglass_empty,
                                      color: isApproved ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                  title: Text(
                                    lead.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Nominee: ' + (lead.extraData['nominee'] ?? 'N/A') + ' (' + (lead.extraData['relation'] ?? 'N/A') + ')\nAadhaar: ' + (lead.extraData['aadhaar'] ?? 'N/A') + ' · Mobile: ' + (lead.extraData['phone'] ?? lead.mobile),
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isApproved ? Colors.green : Colors.orange).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      lead.status.toUpperCase(),
                                      style: TextStyle(
                                        color: isApproved ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: formWidget),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: listWidget),
                ],
              );
            } else {
              return Column(
                children: [
                  formWidget,
                  const SizedBox(height: 20),
                  listWidget,
                ],
              );
            }
          }),
        ],
      ),
    );
  }
}
