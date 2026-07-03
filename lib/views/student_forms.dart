import 'package:flutter/material.dart';
import '../widgets/responsive_layout.dart';
import '../controllers/service_controller.dart';

class AdmissionFormScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AdmissionFormScreen({super.key, required this.userData});
  @override State<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}
class _AdmissionFormScreenState extends State<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  final _course = TextEditingController();
  final _college = TextEditingController();
  final _previousMarks = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final payload = {
      'user_id': widget.userData['id'],
      'type': 'student_admission',
      'data': {
        'course': _course.text,
        'college': _college.text,
        'previous_marks': _previousMarks.text,
      }
    };
    final res = await ServiceController().submitData(payload);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (res.ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admission form submitted successfully.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorMessage.isEmpty ? 'Failed' : res.errorMessage)));
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admission Form')),
      body: ResponsiveFormScroll(
        formKey: _formKey,
        child: Column(
          children: [
            TextFormField(controller: _course, decoration: const InputDecoration(labelText: 'Desired Course'), validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _college, decoration: const InputDecoration(labelText: 'Desired College/University'), validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _previousMarks, decoration: const InputDecoration(labelText: 'Previous Degree Marks (%)'), validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving ? const CircularProgressIndicator() : const Text('Submit Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScholarshipFormScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ScholarshipFormScreen({super.key, required this.userData});
  @override State<ScholarshipFormScreen> createState() => _ScholarshipFormScreenState();
}
class _ScholarshipFormScreenState extends State<ScholarshipFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  final _scheme = TextEditingController();
  final _income = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final payload = {
      'user_id': widget.userData['id'],
      'type': 'student_scholarship',
      'data': {'scheme': _scheme.text, 'family_income': _income.text}
    };
    final res = await ServiceController().submitData(payload);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (res.ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scholarship form submitted successfully.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorMessage.isEmpty ? 'Failed' : res.errorMessage)));
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scholarship Application')),
      body: ResponsiveFormScroll(
        formKey: _formKey,
        child: Column(
          children: [
            TextFormField(controller: _scheme, decoration: const InputDecoration(labelText: 'Scholarship Scheme Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _income, decoration: const InputDecoration(labelText: 'Annual Family Income'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving ? const CircularProgressIndicator() : const Text('Submit Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InternshipFormScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const InternshipFormScreen({super.key, required this.userData});
  @override State<InternshipFormScreen> createState() => _InternshipFormScreenState();
}
class _InternshipFormScreenState extends State<InternshipFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  final _field = TextEditingController();
  final _duration = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final payload = {
      'user_id': widget.userData['id'],
      'type': 'student_internship',
      'data': {'field_of_interest': _field.text, 'duration_months': _duration.text}
    };
    final res = await ServiceController().submitData(payload);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (res.ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Internship form submitted.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorMessage.isEmpty ? 'Failed' : res.errorMessage)));
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Internship Application')),
      body: ResponsiveFormScroll(
        formKey: _formKey,
        child: Column(
          children: [
            TextFormField(controller: _field, decoration: const InputDecoration(labelText: 'Field of Interest'), validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _duration, decoration: const InputDecoration(labelText: 'Available Duration (Months)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving ? const CircularProgressIndicator() : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobApplicationFormScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const JobApplicationFormScreen({super.key, required this.userData});
  @override State<JobApplicationFormScreen> createState() => _JobApplicationFormScreenState();
}
class _JobApplicationFormScreenState extends State<JobApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  final _role = TextEditingController();
  final _skills = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final payload = {
      'user_id': widget.userData['id'],
      'type': 'student_job_application',
      'data': {'role_applied': _role.text, 'skills': _skills.text}
    };
    final res = await ServiceController().submitData(payload);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (res.ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job Application submitted.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.errorMessage.isEmpty ? 'Failed' : res.errorMessage)));
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Application')),
      body: ResponsiveFormScroll(
        formKey: _formKey,
        child: Column(
          children: [
            TextFormField(controller: _role, decoration: const InputDecoration(labelText: 'Role Applying For'), validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _skills, decoration: const InputDecoration(labelText: 'Key Skills'), validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving ? const CircularProgressIndicator() : const Text('Submit Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
