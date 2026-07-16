import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_digital_registration/controllers/service_controller.dart';
import 'package:the_digital_registration/services/ai_graphics_service.dart';
import 'package:the_digital_registration/views/ai_graphics_screen.dart';
import 'package:the_digital_registration/views/internship_application_screen.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';
import 'package:the_digital_registration/views/quick_content_screens.dart';
import '../controllers/lead_controller.dart';
import '../constants/lead_category.dart';
import '../models/lead_model.dart';

// --- SHARED UI HELPERS ---
Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16, top: 10),
    child: Builder(
      builder: (context) {
        return Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.5));
      }
    ),
  );
}

InputDecoration _inputStyle(BuildContext context, String label, IconData icon) {
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

Widget _loanFormField({
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
          decoration: _inputStyle(context, label, icon),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          inputFormatters: keyboardType == TextInputType.number 
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))] 
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

String? _panOptional(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  final p = v.trim().toUpperCase();
  if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(p)) return 'Enter valid PAN (AAAAA9999A)';
  return null;
}

String? _aadhaarOptional(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  if (!RegExp(r'^\d{12}$').hasMatch(v.trim())) return 'Aadhaar must be 12 digits';
  return null;
}

String? _optPhone(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  if (v.trim().length < 10) return 'Enter a valid 10-digit number';
  return null;
}

String? _optEmail(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  if (!v.contains('@')) return 'Enter a valid email';
  return null;
}

String? _optPin6(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  if (v.trim().length != 6) return 'PIN must be 6 digits';
  return null;
}

String? _ifscOptional(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  final s = v.trim().toUpperCase();
  if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(s)) return 'Invalid IFSC format';
  return null;
}

double? _parseDecimal(String? v) {
  if (v == null) return null;
  final s = v.trim().replaceAll(',', '');
  if (s.isEmpty) return null;
  return double.tryParse(s);
}

String? _requiredDecimal(String? v, [String msg = 'Enter a valid number']) {
  if (v == null || v.trim().isEmpty) return 'Required';
  final n = _parseDecimal(v);
  if (n == null) return msg;
  if (n < 0) return 'Must be 0 or more';
  return null;
}

int? _parseFlexibleInt(String? v) {
  if (v == null) return null;
  final s = v.trim().replaceAll(',', '');
  if (s.isEmpty) return null;
  return int.tryParse(s);
}

String? _requiredInt(String? v, [String msg = 'Enter a valid integer']) {
  if (v == null || v.trim().isEmpty) return 'Required';
  final n = _parseFlexibleInt(v);
  if (n == null) return msg;
  if (n < 0) return 'Must be 0 or more';
  return null;
}

DateTime? _parseFlexibleDate(String? v) {
  if (v == null) return null;
  final s = v.trim();
  if (s.isEmpty) return null;
  try {
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
      final parts = s.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      final dt = DateTime(y, m, d);
      if (dt.year == y && dt.month == m && dt.day == d) return dt;
      return null;
    }
    if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(s)) {
      final parts = s.split('/');
      final d = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final y = int.parse(parts[2]);
      final dt = DateTime(y, m, d);
      if (dt.year == y && dt.month == m && dt.day == d) return dt;
      return null;
    }
    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(s)) {
      final parts = s.split('-');
      final d = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final y = int.parse(parts[2]);
      final dt = DateTime(y, m, d);
      if (dt.year == y && dt.month == m && dt.day == d) return dt;
      return null;
    }
  } catch (_) {
    return null;
  }
  return null;
}

String? _requiredDate(String? v) {
  if (v == null || v.trim().isEmpty) return 'Required';
  if (_parseFlexibleDate(v) == null) return 'Use DD/MM/YYYY';
  return null;
}

String? _toIsoDate(String? v) {
  final d = _parseFlexibleDate(v);
  if (d == null) return null;
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

// --- SHARED INSURANCE FORMS (visible to all user categories) ---

class HealthInsuranceForm extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HealthInsuranceForm({super.key, required this.userData});
  @override
  State<HealthInsuranceForm> createState() => _HealthInsuranceFormState();
}

class _HealthInsuranceFormState extends State<HealthInsuranceForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Personal
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _aadhaar = TextEditingController();
  final _pan = TextEditingController();
  final _dob = TextEditingController();
  String _gender = 'Male';
  final _age = TextEditingController();

  // Address
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();

  // Plan
  String _planType = 'Individual';
  final _sumInsured = TextEditingController();
  final _premiumAmount = TextEditingController();
  final _membersCovered = TextEditingController();
  final _insurerName = TextEditingController();
  String _policyTerm = '1 Year';

  // Medical
  bool _preExistingDisease = false;
  final _diseaseDetails = TextEditingController();

  // Nominee
  final _nomineeName = TextEditingController();
  final _nomineeRelation = TextEditingController();
  final _nomineeDob = TextEditingController();

  @override
  void initState() {
    super.initState();
    final u = widget.userData;
    _name.text = (u['name'] ?? '').toString();
    _mobile.text = (u['mobile'] ?? '').toString();
    _email.text = (u['email'] ?? '').toString();
    _city.text = (u['city'] ?? '').toString();
    _state.text = (u['state'] ?? '').toString();
    _pincode.text = (u['pincode'] ?? '').toString();
  }

  @override
  void dispose() {
    for (final c in [_name, _mobile, _email, _aadhaar, _pan, _dob, _age,
      _address, _city, _state, _pincode, _sumInsured, _premiumAmount,
      _membersCovered, _insurerName, _diseaseDetails,
      _nomineeName, _nomineeRelation, _nomineeDob]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final y = picked.year;
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      ctrl.text = '$y-$m-$d';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final payload = {
      'type': 'health_insurance',
      'user_id': widget.userData['id']?.toString() ?? '0',
      'data': {
        'applicant_name': _name.text.trim(),
        'mobile': _mobile.text.trim(),
        'email': _email.text.trim(),
        'aadhaar': _aadhaar.text.trim(),
        'pan': _pan.text.trim().toUpperCase(),
        'dob': _dob.text.trim(),
        'gender': _gender,
        'age': int.tryParse(_age.text.trim()) ?? 0,
        'address': _address.text.trim(),
        'city': _city.text.trim(),
        'state': _state.text.trim(),
        'pincode': _pincode.text.trim(),
        'plan_type': _planType,
        'sum_insured': double.tryParse(_sumInsured.text.trim()) ?? 0,
        'premium_amount': double.tryParse(_premiumAmount.text.trim()) ?? 0,
        'members_covered': int.tryParse(_membersCovered.text.trim()) ?? 1,
        'insurer_name': _insurerName.text.trim(),
        'policy_term': _policyTerm,
        'pre_existing_disease': _preExistingDisease,
        'disease_details': _preExistingDisease ? _diseaseDetails.text.trim() : '',
        'nominee_name': _nomineeName.text.trim(),
        'nominee_relation': _nomineeRelation.text.trim(),
        'nominee_dob': _nomineeDob.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);
    setState(() => _isSaving = false);
    if (!mounted) return;

    if (result.ok) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 10),
            Text('Application Submitted!'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Health Insurance application has been submitted successfully.'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Name: ${_name.text}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Plan: $_planType · Sum Insured: ₹${_sumInsured.text}'),
                  Text('Term: $_policyTerm'),
                ]),
              ),
              const SizedBox(height: 8),
              const Text('You will be notified once reviewed.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result.errorMessage.isEmpty ? 'Submission failed' : result.errorMessage}'), backgroundColor: Colors.red),
      );
    }
  }

  InputDecoration _dropStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
      filled: true,
      fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text('Health Insurance'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ResponsiveScrollBody(children: [
          // Hero Banner
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              const Icon(Icons.health_and_safety, color: Colors.white, size: 48),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Health Insurance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text('Protect yourself & your family from medical expenses',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
              ])),
            ]),
          ),

          _buildSectionTitle('Personal Details'),
          _loanFormField(controller: _name, label: 'Full Name', icon: Icons.person_outline, validator: (v) => _req(v, 'Enter name')),
          _loanFormField(controller: _mobile, label: 'Mobile Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => _req(v, 'Enter mobile')),
          _loanFormField(controller: _email, label: 'Email Address', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress, validator: _optEmail),
          _loanFormField(controller: _aadhaar, label: 'Aadhaar Number', icon: Icons.credit_card, keyboardType: TextInputType.number, validator: _aadhaarOptional),
          _loanFormField(controller: _pan, label: 'PAN Number (optional)', icon: Icons.badge_outlined, validator: _panOptional),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => _pickDate(_dob),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dob,
                  decoration: _inputStyle(context, 'Date of Birth', Icons.cake_outlined),
                  validator: (v) => _req(v, 'Select DOB'),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<String>(
              value: _gender,
              decoration: _dropStyle('Gender', Icons.wc_outlined),
              items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _gender = v!),
            ),
          ),
          _loanFormField(controller: _age, label: 'Age', icon: Icons.numbers, keyboardType: TextInputType.number, validator: (v) => _req(v, 'Enter age')),

          _buildSectionTitle('Address'),
          _loanFormField(controller: _address, label: 'Full Address', icon: Icons.home_outlined, maxLines: 2, validator: (v) => _req(v, 'Enter address')),
          _loanFormField(controller: _city, label: 'City', icon: Icons.location_city_outlined, validator: (v) => _req(v, 'Enter city')),
          _loanFormField(controller: _state, label: 'State', icon: Icons.map_outlined, validator: (v) => _req(v, 'Enter state')),
          _loanFormField(controller: _pincode, label: 'Pincode', icon: Icons.pin_drop_outlined, keyboardType: TextInputType.number, validator: (v) => _req(v, 'Enter pincode')),

          _buildSectionTitle('Insurance Plan'),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<String>(
              value: _planType,
              decoration: _dropStyle('Plan Type', Icons.assignment_outlined),
              items: ['Individual', 'Family Floater', 'Senior Citizen', 'Critical Illness']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _planType = v!),
            ),
          ),
          _loanFormField(controller: _sumInsured, label: 'Sum Insured (₹)', icon: Icons.shield_outlined, keyboardType: TextInputType.number, validator: (v) => _req(v, 'Enter sum insured')),
          _loanFormField(controller: _premiumAmount, label: 'Estimated Premium (₹)', icon: Icons.currency_rupee, keyboardType: TextInputType.number),
          _loanFormField(controller: _membersCovered, label: 'Members to be Covered', icon: Icons.group_outlined, keyboardType: TextInputType.number, validator: (v) => _req(v, 'Enter count')),
          _loanFormField(controller: _insurerName, label: 'Preferred Insurer (optional)', icon: Icons.business_outlined),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<String>(
              value: _policyTerm,
              decoration: _dropStyle('Policy Term', Icons.calendar_today_outlined),
              items: ['1 Year', '2 Years', '3 Years'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _policyTerm = v!),
            ),
          ),

          _buildSectionTitle('Medical History'),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Pre-existing Disease?', style: TextStyle(fontWeight: FontWeight.w600)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_preExistingDisease ? 'Yes — please describe below' : 'No pre-existing disease'),
                value: _preExistingDisease,
                onChanged: (v) => setState(() => _preExistingDisease = v),
                activeColor: const Color(0xFF2196F3),
              ),
              if (_preExistingDisease)
                TextFormField(
                  controller: _diseaseDetails,
                  decoration: _inputStyle(context, 'Describe the condition(s)', Icons.medical_information_outlined),
                  maxLines: 2,
                  validator: _preExistingDisease ? (v) => _req(v, 'Please describe') : null,
                ),
            ]),
          ),

          _buildSectionTitle('Nominee Details'),
          _loanFormField(controller: _nomineeName, label: 'Nominee Name', icon: Icons.person_pin_outlined, validator: (v) => _req(v, 'Enter nominee name')),
          _loanFormField(controller: _nomineeRelation, label: 'Relation with Nominee', icon: Icons.family_restroom, validator: (v) => _req(v, 'Enter relation')),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: GestureDetector(
              onTap: () => _pickDate(_nomineeDob),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _nomineeDob,
                  decoration: _inputStyle(context, 'Nominee Date of Birth', Icons.cake_outlined),
                ),
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded),
              label: Text(_isSaving ? 'Submitting…' : 'Submit Application'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOTOR INSURANCE FORM
// ─────────────────────────────────────────────────────────────────────────────

class MotorInsuranceForm extends StatefulWidget {
  final Map<String, dynamic> userData;
  const MotorInsuranceForm({super.key, required this.userData});
  @override
  State<MotorInsuranceForm> createState() => _MotorInsuranceFormState();
}

class _MotorInsuranceFormState extends State<MotorInsuranceForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Personal
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _aadhaar = TextEditingController();
  final _pan = TextEditingController();

  // Address
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();

  // Vehicle
  String _vehicleType = 'Four Wheeler';
  final _vehicleMake = TextEditingController();
  final _vehicleModel = TextEditingController();
  final _vehicleYear = TextEditingController();
  final _regNumber = TextEditingController();
  final _engineNumber = TextEditingController();
  final _chassisNumber = TextEditingController();
  final _vehicleValue = TextEditingController();

  // Plan
  String _planType = 'Comprehensive';
  final _insurerName = TextEditingController();
  final _premiumAmount = TextEditingController();
  String _policyTerm = '1 Year';

  // Previous policy
  bool _hasPreviousPolicy = false;
  final _previousPolicyNumber = TextEditingController();
  final _previousInsurer = TextEditingController();
  String _claimHistory = 'No Claim';

  // Nominee
  final _nomineeName = TextEditingController();
  final _nomineeRelation = TextEditingController();

  @override
  void initState() {
    super.initState();
    final u = widget.userData;
    _name.text = (u['name'] ?? '').toString();
    _mobile.text = (u['mobile'] ?? '').toString();
    _email.text = (u['email'] ?? '').toString();
    _city.text = (u['city'] ?? '').toString();
    _state.text = (u['state'] ?? '').toString();
    _pincode.text = (u['pincode'] ?? '').toString();
  }

  @override
  void dispose() {
    for (final c in [_name, _mobile, _email, _aadhaar, _pan,
      _address, _city, _state, _pincode,
      _vehicleMake, _vehicleModel, _vehicleYear, _regNumber,
      _engineNumber, _chassisNumber, _vehicleValue,
      _insurerName, _premiumAmount,
      _previousPolicyNumber, _previousInsurer,
      _nomineeName, _nomineeRelation]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final payload = {
      'type': 'motor_insurance',
      'user_id': widget.userData['id']?.toString() ?? '0',
      'data': {
        'applicant_name': _name.text.trim(),
        'mobile': _mobile.text.trim(),
        'email': _email.text.trim(),
        'aadhaar': _aadhaar.text.trim(),
        'pan': _pan.text.trim().toUpperCase(),
        'address': _address.text.trim(),
        'city': _city.text.trim(),
        'state': _state.text.trim(),
        'pincode': _pincode.text.trim(),
        'vehicle_type': _vehicleType,
        'vehicle_make': _vehicleMake.text.trim(),
        'vehicle_model': _vehicleModel.text.trim(),
        'vehicle_year': _vehicleYear.text.trim(),
        'registration_number': _regNumber.text.trim(),
        'engine_number': _engineNumber.text.trim(),
        'chassis_number': _chassisNumber.text.trim(),
        'vehicle_value': double.tryParse(_vehicleValue.text.trim()) ?? 0,
        'plan_type': _planType,
        'insurer_name': _insurerName.text.trim(),
        'premium_amount': double.tryParse(_premiumAmount.text.trim()) ?? 0,
        'policy_term': _policyTerm,
        'has_previous_policy': _hasPreviousPolicy,
        'previous_policy_number': _hasPreviousPolicy ? _previousPolicyNumber.text.trim() : '',
        'previous_insurer': _hasPreviousPolicy ? _previousInsurer.text.trim() : '',
        'claim_history': _hasPreviousPolicy ? _claimHistory : 'N/A',
        'nominee_name': _nomineeName.text.trim(),
        'nominee_relation': _nomineeRelation.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);
    setState(() => _isSaving = false);
    if (!mounted) return;

    if (result.ok) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 10),
            Text('Application Submitted!'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Motor Insurance application has been submitted successfully.'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Name: ${_name.text}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Vehicle: ${_vehicleMake.text} ${_vehicleModel.text} ($_vehicleType)'),
                  Text('Plan: $_planType · Term: $_policyTerm'),
                ]),
              ),
              const SizedBox(height: 8),
              const Text('You will be notified once reviewed.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result.errorMessage.isEmpty ? 'Submission failed' : result.errorMessage}'), backgroundColor: Colors.red),
      );
    }
  }

  InputDecoration _dropStyle(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
    filled: true,
    fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('Motor Insurance'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ResponsiveScrollBody(children: [
          // Hero Banner
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE65100), Color(0xFFFF9800)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              const Icon(Icons.directions_car, color: Colors.white, size: 48),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Motor Insurance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text('Insure your vehicle against accidents, theft & damage',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
              ])),
            ]),
          ),

          _buildSectionTitle('Personal Details'),
          _loanFormField(controller: _name, label: 'Full Name', icon: Icons.person_outline, validator: (v) => _req(v, 'Enter name')),
          _loanFormField(controller: _mobile, label: 'Mobile Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => _req(v, 'Enter mobile')),
          _loanFormField(controller: _email, label: 'Email Address', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress, validator: _optEmail),
          _loanFormField(controller: _aadhaar, label: 'Aadhaar Number', icon: Icons.credit_card, keyboardType: TextInputType.number, validator: _aadhaarOptional),
          _loanFormField(controller: _pan, label: 'PAN Number (optional)', icon: Icons.badge_outlined, validator: _panOptional),

          _buildSectionTitle('Address'),
          _loanFormField(controller: _address, label: 'Full Address', icon: Icons.home_outlined, maxLines: 2, validator: (v) => _req(v, 'Enter address')),
          _loanFormField(controller: _city, label: 'City', icon: Icons.location_city_outlined, validator: (v) => _req(v, 'Enter city')),
          _loanFormField(controller: _state, label: 'State', icon: Icons.map_outlined, validator: (v) => _req(v, 'Enter state')),
          _loanFormField(controller: _pincode, label: 'Pincode', icon: Icons.pin_drop_outlined, keyboardType: TextInputType.number, validator: (v) => _req(v, 'Enter pincode')),

          _buildSectionTitle('Vehicle Details'),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<String>(
              value: _vehicleType,
              decoration: _dropStyle('Vehicle Type', Icons.directions_car_outlined),
              items: ['Two Wheeler', 'Four Wheeler', 'Commercial Vehicle', 'Three Wheeler']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _vehicleType = v!),
            ),
          ),
          _loanFormField(controller: _vehicleMake, label: 'Vehicle Make (e.g. Maruti)', icon: Icons.branding_watermark_outlined, validator: (v) => _req(v, 'Enter make')),
          _loanFormField(controller: _vehicleModel, label: 'Vehicle Model (e.g. Swift)', icon: Icons.car_repair, validator: (v) => _req(v, 'Enter model')),
          _loanFormField(controller: _vehicleYear, label: 'Year of Manufacture', icon: Icons.calendar_today_outlined, keyboardType: TextInputType.number, validator: (v) => _req(v, 'Enter year')),
          _loanFormField(controller: _regNumber, label: 'Registration Number', icon: Icons.confirmation_number_outlined, validator: (v) => _req(v, 'Enter reg. number')),
          _loanFormField(controller: _engineNumber, label: 'Engine Number', icon: Icons.engineering_outlined),
          _loanFormField(controller: _chassisNumber, label: 'Chassis Number', icon: Icons.linear_scale),
          _loanFormField(controller: _vehicleValue, label: 'Vehicle IDV / Market Value (₹)', icon: Icons.currency_rupee, keyboardType: TextInputType.number, validator: (v) => _req(v, 'Enter vehicle value')),

          _buildSectionTitle('Insurance Plan'),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<String>(
              value: _planType,
              decoration: _dropStyle('Plan Type', Icons.assignment_outlined),
              items: ['Comprehensive', 'Third Party', 'Own Damage']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _planType = v!),
            ),
          ),
          _loanFormField(controller: _insurerName, label: 'Preferred Insurer (optional)', icon: Icons.business_outlined),
          _loanFormField(controller: _premiumAmount, label: 'Estimated Premium (₹)', icon: Icons.currency_rupee, keyboardType: TextInputType.number),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<String>(
              value: _policyTerm,
              decoration: _dropStyle('Policy Term', Icons.calendar_month_outlined),
              items: ['1 Year', '2 Years', '3 Years'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _policyTerm = v!),
            ),
          ),

          _buildSectionTitle('Previous Policy (if any)'),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Have a previous policy?', style: TextStyle(fontWeight: FontWeight.w600)),
                value: _hasPreviousPolicy,
                onChanged: (v) => setState(() => _hasPreviousPolicy = v),
                activeColor: const Color(0xFF2196F3),
              ),
              if (_hasPreviousPolicy) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _previousPolicyNumber,
                  decoration: _inputStyle(context, 'Previous Policy Number', Icons.policy_outlined),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _previousInsurer,
                  decoration: _inputStyle(context, 'Previous Insurer Name', Icons.business_outlined),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _claimHistory,
                  decoration: _dropStyle('Claim History', Icons.history_outlined),
                  items: ['No Claim', '1 Claim', '2 Claims', '3+ Claims']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _claimHistory = v!),
                ),
              ],
            ]),
          ),

          _buildSectionTitle('Nominee Details'),
          _loanFormField(controller: _nomineeName, label: 'Nominee Name', icon: Icons.person_pin_outlined, validator: (v) => _req(v, 'Enter nominee name')),
          _loanFormField(controller: _nomineeRelation, label: 'Relation with Nominee', icon: Icons.family_restroom, validator: (v) => _req(v, 'Enter relation')),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded),
              label: Text(_isSaving ? 'Submitting…' : 'Submit Application'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

// --- 1. STUDENT SERVICES ---

class InternshipScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const InternshipScreen({super.key, required this.userData});

  @override
  State<InternshipScreen> createState() => _InternshipScreenState();
}

class _InternshipScreenState extends State<InternshipScreen> {
  late Future<List<dynamic>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = ServiceController().fetchJobs();
  }

  void _openApplication(dynamic job) {
    if (job is! Map) return;
    final m = Map<String, dynamic>.from(job);
    final idRaw = m['id'];
    if (idRaw == null) return;
    final jobId = int.tryParse(idRaw.toString()) ?? 0;
    if (jobId == 0) return;

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => InternshipApplicationScreen(
          userData: widget.userData,
          jobId: jobId,
          jobTitle: m['job_title']?.toString() ?? 'Internship',
          companyName: m['company_name']?.toString() ?? 'Company',
          salaryRange: m['salary_range']?.toString() ?? 'N/A',
          jobDetails: m,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Available Internships", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
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

          return ResponsiveListView(
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
                    decoration: BoxDecoration(color: const Color(0xFF2196F3).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.laptop_mac, color: Color(0xFF2196F3)),
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
                        const Text("Apply Now", style: TextStyle(color: Color(0xFF2196F3), fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  onTap: () => _openApplication(job),
                ),
              );
            },
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
      body: ResponsiveScrollBody(
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
  final dynamic initialLead;
  const EducationLoanForm({super.key, required this.userData, this.initialLead});

  @override
  State<EducationLoanForm> createState() => _EducationLoanFormState();
}

class _EducationLoanFormState extends State<EducationLoanForm> {
  final _formKey = GlobalKey<FormState>();

  // Applicant & KYC
  final _applicantName = TextEditingController();
  final _dob = TextEditingController();
  final _gender = TextEditingController();
  final _pan = TextEditingController();
  final _aadhaar = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _district = TextEditingController();

  // Course & fees
  final _collegeController = TextEditingController();
  final _courseController = TextEditingController();
  final _yearSemester = TextEditingController();
  final _courseDurationMonths = TextEditingController();
  final _totalCourseFee = TextEditingController();
  final _amountController = TextEditingController();
  final _amountAlreadyPaid = TextEditingController();
  final _moratoriumMonths = TextEditingController();
  final _repaymentTenureMonths = TextEditingController();
  final _preferredEmi = TextEditingController();

  // Co-borrower / guarantor
  final _coName = TextEditingController();
  final _coRelation = TextEditingController();
  final _coDob = TextEditingController();
  final _coPan = TextEditingController();
  final _coOccupation = TextEditingController();
  final _coEmployer = TextEditingController();
  final _coAnnualIncome = TextEditingController();
  final _coMobile = TextEditingController();

  // Existing obligations
  final _existingLoans = TextEditingController();
  final _monthlyEmiExisting = TextEditingController();

  // Banking
  final _accHolderName = TextEditingController();
  final _bankName = TextEditingController();
  final _branch = TextEditingController();
  final _accountNumber = TextEditingController();
  final _ifsc = TextEditingController();

  // References
  final _ref1Name = TextEditingController();
  final _ref1Phone = TextEditingController();
  final _ref2Name = TextEditingController();
  final _ref2Phone = TextEditingController();

  // Collateral & misc
  final _collateralDesc = TextEditingController();
  final _scholarshipAid = TextEditingController();
  bool _declarationAccepted = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.userData;
    _applicantName.text = (u['name'] ?? '').toString();
    _mobile.text = (u['mobile'] ?? '').toString();
    _email.text = (u['email'] ?? '').toString();
    _pincode.text = (u['pincode'] ?? '').toString();
    _city.text = (u['city'] ?? '').toString();
    _state.text = (u['state'] ?? '').toString();
    _district.text = (u['district'] ?? '').toString();
  }

  @override
  void dispose() {
    _applicantName.dispose();
    _dob.dispose();
    _gender.dispose();
    _pan.dispose();
    _aadhaar.dispose();
    _mobile.dispose();
    _email.dispose();
    _address.dispose();
    _pincode.dispose();
    _city.dispose();
    _state.dispose();
    _district.dispose();
    _collegeController.dispose();
    _courseController.dispose();
    _yearSemester.dispose();
    _courseDurationMonths.dispose();
    _totalCourseFee.dispose();
    _amountController.dispose();
    _amountAlreadyPaid.dispose();
    _moratoriumMonths.dispose();
    _repaymentTenureMonths.dispose();
    _preferredEmi.dispose();
    _coName.dispose();
    _coRelation.dispose();
    _coDob.dispose();
    _coPan.dispose();
    _coOccupation.dispose();
    _coEmployer.dispose();
    _coAnnualIncome.dispose();
    _coMobile.dispose();
    _existingLoans.dispose();
    _monthlyEmiExisting.dispose();
    _accHolderName.dispose();
    _bankName.dispose();
    _branch.dispose();
    _accountNumber.dispose();
    _ifsc.dispose();
    _ref1Name.dispose();
    _ref1Phone.dispose();
    _ref2Name.dispose();
    _ref2Phone.dispose();
    _collateralDesc.dispose();
    _scholarshipAid.dispose();
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
      "user_id": widget.userData['id'],
      "type": "edu_loan",
      "data": {
        "loan_product": "Education Loan",
        "applicant_name": _applicantName.text.trim(),
        "dob": _dob.text.trim(),
        "gender": _gender.text.trim(),
        "pan": _pan.text.trim().toUpperCase(),
        "aadhaar": _aadhaar.text.trim(),
        "mobile": _mobile.text.trim(),
        "email": _email.text.trim(),
        "address": _address.text.trim(),
        "pincode": _pincode.text.trim(),
        "city": _city.text.trim(),
        "state": _state.text.trim(),
        "district": _district.text.trim(),
        "college_name": _collegeController.text.trim(),
        "course_name": _courseController.text.trim(),
        "year_semester": _yearSemester.text.trim(),
        "course_duration_months": _courseDurationMonths.text.trim(),
        "total_course_fee": _totalCourseFee.text.trim(),
        "amount": _amountController.text.trim(),
        "amount_already_paid": _amountAlreadyPaid.text.trim(),
        "moratorium_months": _moratoriumMonths.text.trim(),
        "repayment_tenure_months": _repaymentTenureMonths.text.trim(),
        "preferred_emi": _preferredEmi.text.trim(),
        "co_borrower_name": _coName.text.trim(),
        "co_borrower_relation": _coRelation.text.trim(),
        "co_borrower_dob": _coDob.text.trim(),
        "co_borrower_pan": _coPan.text.trim().toUpperCase(),
        "co_borrower_occupation": _coOccupation.text.trim(),
        "co_borrower_employer": _coEmployer.text.trim(),
        "co_borrower_annual_income": _coAnnualIncome.text.trim(),
        "co_borrower_mobile": _coMobile.text.trim(),
        "existing_loans_summary": _existingLoans.text.trim(),
        "monthly_emi_existing": _monthlyEmiExisting.text.trim(),
        "account_holder_name": _accHolderName.text.trim(),
        "bank_name": _bankName.text.trim(),
        "branch": _branch.text.trim(),
        "account_number": _accountNumber.text.trim(),
        "ifsc": _ifsc.text.trim().toUpperCase(),
        "reference1_name": _ref1Name.text.trim(),
        "reference1_phone": _ref1Phone.text.trim(),
        "reference2_name": _ref2Name.text.trim(),
        "reference2_phone": _ref2Phone.text.trim(),
        "collateral_description": _collateralDesc.text.trim(),
        "scholarship_or_aid": _scholarshipAid.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.ok) {
      final extra = result.infoMessage.isNotEmpty ? ' ${result.infoMessage}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Education loan application submitted.$extra')),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Education loan application',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        centerTitle: true,
      ),
      body: ResponsiveFormScroll(
        formKey: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fill what you know; name, mobile, college, course, and loan amount are required.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Applicant & KYC'),
              _loanFormField(
                controller: _applicantName,
                label: 'Full name (as on PAN)',
                icon: Icons.person,
                validator: _req,
              ),
              _loanFormField(
                controller: _dob,
                label: 'Date of birth (DD/MM/YYYY)',
                icon: Icons.cake,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _gender,
                label: 'Gender',
                icon: Icons.wc,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _pan,
                label: 'PAN',
                icon: Icons.badge,
                validator: _panOptional,
              ),
              _loanFormField(
                controller: _aadhaar,
                label: 'Aadhaar number (optional)',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: _aadhaarOptional,
              ),
              _loanFormField(
                controller: _mobile,
                label: 'Mobile',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.length < 10) ? 'Valid mobile required' : null,
              ),
              _loanFormField(
                controller: _email,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: _optEmail,
              ),
              _loanFormField(
                controller: _address,
                label: 'Current residential address',
                icon: Icons.home,
                maxLines: 2,
                validator: (_) => null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _pincode,
                      label: 'PIN code',
                      icon: Icons.pin,
                      keyboardType: TextInputType.number,
                      validator: _optPin6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _city,
                      label: 'City',
                      icon: Icons.location_city,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _district,
                      label: 'District',
                      icon: Icons.map,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _state,
                      label: 'State',
                      icon: Icons.flag,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _buildSectionTitle('Course & institution'),
              _loanFormField(
                controller: _collegeController,
                label: 'College / university name',
                icon: Icons.school,
                validator: _req,
              ),
              _loanFormField(
                controller: _courseController,
                label: 'Course / degree (e.g. B.Tech, MBBS)',
                icon: Icons.book,
                validator: _req,
              ),
              _loanFormField(
                controller: _yearSemester,
                label: 'Current year / semester',
                icon: Icons.calendar_view_month,
                validator: (_) => null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _courseDurationMonths,
                      label: 'Total course duration (months)',
                      icon: Icons.timelapse,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _totalCourseFee,
                      label: 'Total course fee (₹)',
                      icon: Icons.payments,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _buildSectionTitle('Loan requested'),
              _loanFormField(
                controller: _amountController,
                label: 'Loan amount required (₹)',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: _requiredDecimal,
              ),
              _loanFormField(
                controller: _amountAlreadyPaid,
                label: 'Fee already paid by family (₹, if any)',
                icon: Icons.savings,
                keyboardType: TextInputType.number,
                validator: (_) => null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _moratoriumMonths,
                      label: 'Study period / moratorium (months)',
                      icon: Icons.hourglass_empty,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _repaymentTenureMonths,
                      label: 'Repayment tenure after moratorium (months)',
                      icon: Icons.date_range,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _preferredEmi,
                label: 'Preferred EMI range (₹ / month, optional)',
                icon: Icons.trending_flat,
                keyboardType: TextInputType.number,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _scholarshipAid,
                label: 'Scholarship / education loan from other source (if any)',
                icon: Icons.card_giftcard,
                validator: (_) => null,
              ),
              _buildSectionTitle('Co-borrower / guarantor (usually parent)'),
              _loanFormField(
                controller: _coName,
                label: 'Co-borrower full name',
                icon: Icons.family_restroom,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _coRelation,
                label: 'Relationship to applicant',
                icon: Icons.link,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _coDob,
                label: 'Co-borrower DOB (DD/MM/YYYY)',
                icon: Icons.cake_outlined,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _coPan,
                label: 'Co-borrower PAN',
                icon: Icons.badge_outlined,
                validator: _panOptional,
              ),
              _loanFormField(
                controller: _coOccupation,
                label: 'Occupation',
                icon: Icons.work_outline,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _coEmployer,
                label: 'Employer / business name',
                icon: Icons.business,
                validator: (_) => null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _coAnnualIncome,
                      label: 'Gross annual income (₹)',
                      icon: Icons.account_balance_wallet,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _coMobile,
                      label: 'Co-borrower mobile',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      validator: _optPhone,
                    ),
                  ),
                ],
              ),
              _buildSectionTitle('Existing loans & obligations'),
              _loanFormField(
                controller: _existingLoans,
                label: 'Existing loans (lender, outstanding, EMI) — or type None',
                icon: Icons.list_alt,
                maxLines: 2,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _monthlyEmiExisting,
                label: 'Total existing EMI (₹ / month)',
                icon: Icons.money_off,
                keyboardType: TextInputType.number,
                validator: (_) => null,
              ),
              _buildSectionTitle('Disbursement bank account'),
              _loanFormField(
                controller: _accHolderName,
                label: 'Account holder name',
                icon: Icons.person_outline,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _bankName,
                label: 'Bank name',
                icon: Icons.account_balance,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _branch,
                label: 'Branch',
                icon: Icons.store_mall_directory,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _accountNumber,
                label: 'Account number',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _ifsc,
                label: 'IFSC code',
                icon: Icons.alt_route,
                validator: _ifscOptional,
              ),
              _buildSectionTitle('References (non-family)'),
              _loanFormField(
                controller: _ref1Name,
                label: 'Reference 1 — name',
                icon: Icons.contact_page,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _ref1Phone,
                label: 'Reference 1 — mobile',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: _optPhone,
              ),
              _loanFormField(
                controller: _ref2Name,
                label: 'Reference 2 — name',
                icon: Icons.contact_page_outlined,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _ref2Phone,
                label: 'Reference 2 — mobile',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: _optPhone,
              ),
              _buildSectionTitle('Security / collateral (if offered)'),
              _loanFormField(
                controller: _collateralDesc,
                label: 'Property / FD / other collateral (brief)',
                icon: Icons.home_work,
                maxLines: 3,
                validator: (_) => null,
              ),
              CheckboxListTile(
                value: _declarationAccepted,
                onChanged: (v) => setState(() => _declarationAccepted = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I declare that the information provided is true to the best of my knowledge and I consent to verification by the bank.',
                  style: TextStyle(fontSize: 13, height: 1.35),
                ),
              ),
              const SizedBox(height: 16),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF2196F3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFF2196F3).withOpacity(0.5),
                        ),
                        child: const Text(
                          'SUBMIT APPLICATION',
                          style: TextStyle(
                            fontSize: 16,
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
}

// --- 2. BUSINESS SERVICES ---

class BusinessLoanForm extends StatefulWidget {
  final Map<String, dynamic> userData;
  final dynamic initialLead;
  const BusinessLoanForm({super.key, required this.userData, this.initialLead});

  @override
  State<BusinessLoanForm> createState() => _BusinessLoanFormState();
}

class _BusinessLoanFormState extends State<BusinessLoanForm> {
  final _formKey = GlobalKey<FormState>();

  // Business identity
  final _legalName = TextEditingController();
  final _tradeName = TextEditingController();
  final _entityType = TextEditingController();
  final _industry = TextEditingController();
  final _dateIncorp = TextEditingController();
  final _udyamMsme = TextEditingController();
  final _cinLlpin = TextEditingController();
  final _panBusiness = TextEditingController();
  final _gst = TextEditingController();
  final _bizAddress = TextEditingController();
  final _bizPincode = TextEditingController();
  final _bizCity = TextEditingController();
  final _bizState = TextEditingController();
  final _yearsInBusiness = TextEditingController();
  final _numEmployees = TextEditingController();

  // Financials
  final _annualTurnover = TextEditingController();
  final _annualProfit = TextEditingController();
  final _existingBankLimit = TextEditingController();
  final _monthlyObligations = TextEditingController();
  final _avgBankBalance = TextEditingController();

  // Loan
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _tenureController = TextEditingController();
  final _collateralOffered = TextEditingController();
  final _expectedDisbursementDate = TextEditingController();

  // Promoter / applicant
  final _promoterName = TextEditingController();
  final _designation = TextEditingController();
  final _promoterPan = TextEditingController();
  final _promoterMobile = TextEditingController();
  final _promoterEmail = TextEditingController();
  final _residentialAddress = TextEditingController();

  // Banking
  final _accHolderName = TextEditingController();
  final _bankName = TextEditingController();
  final _branch = TextEditingController();
  final _accountNumber = TextEditingController();
  final _ifsc = TextEditingController();

  // References
  final _ref1Name = TextEditingController();
  final _ref1Phone = TextEditingController();
  final _ref2Name = TextEditingController();
  final _ref2Phone = TextEditingController();

  bool _declarationAccepted = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.userData;
    if (widget.initialLead != null) {
      final extra = widget.initialLead.extraData;
      _legalName.text = (extra['legal_business_name'] ?? '').toString();
      _tradeName.text = (extra['trade_name'] ?? '').toString();
      _entityType.text = (extra['entity_type'] ?? '').toString();
      _industry.text = (extra['industry_sector'] ?? '').toString();
      _dateIncorp.text = (extra['date_of_incorporation'] ?? '').toString();
      _udyamMsme.text = (extra['udyam_msme_number'] ?? '').toString();
      _cinLlpin.text = (extra['cin_llpin'] ?? '').toString();
      _panBusiness.text = (extra['business_pan'] ?? '').toString();
      _gst.text = (extra['gst_number'] ?? '').toString();
      _bizAddress.text = (extra['registered_office_address'] ?? '').toString();
      _bizPincode.text = (extra['business_pincode'] ?? '').toString();
      _bizCity.text = (extra['business_city'] ?? '').toString();
      _bizState.text = (extra['business_state'] ?? '').toString();
      _yearsInBusiness.text = (extra['years_in_business'] ?? '').toString();
      _numEmployees.text = (extra['number_of_employees'] ?? '').toString();
      _annualTurnover.text = (extra['annual_turnover'] ?? '').toString();
      _annualProfit.text = (extra['annual_profit'] ?? '').toString();
      _existingBankLimit.text = (extra['existing_bank_limit'] ?? '').toString();
      _monthlyObligations.text = (extra['monthly_emi_obligations'] ?? '').toString();
      _avgBankBalance.text = (extra['average_bank_balance'] ?? '').toString();
      _amountController.text = (extra['requested_loan_amount'] ?? '').toString();
      _purposeController.text = (extra['loan_purpose'] ?? '').toString();
      _tenureController.text = (extra['preferred_tenure_months'] ?? '').toString();
      _collateralOffered.text = (extra['collateral_offered'] ?? '').toString();
      _expectedDisbursementDate.text = (extra['expected_disbursement_date'] ?? '').toString();
      
      _promoterName.text = (extra['promoter_name'] ?? '').toString();
      _designation.text = (extra['designation'] ?? '').toString();
      _promoterPan.text = (extra['promoter_pan'] ?? '').toString();
      _promoterMobile.text = (extra['promoter_mobile'] ?? '').toString();
      _promoterEmail.text = (extra['promoter_email'] ?? '').toString();
      _residentialAddress.text = (extra['residential_address'] ?? '').toString();
      
      _accHolderName.text = (extra['account_holder_name'] ?? '').toString();
      _bankName.text = (extra['bank_name'] ?? '').toString();
      _branch.text = (extra['branch'] ?? '').toString();
      _accountNumber.text = (extra['account_number'] ?? '').toString();
      _ifsc.text = (extra['ifsc'] ?? '').toString();
      
      _ref1Name.text = (extra['reference1_name'] ?? '').toString();
      _ref1Phone.text = (extra['reference1_phone'] ?? '').toString();
      _ref2Name.text = (extra['reference2_name'] ?? '').toString();
      _ref2Phone.text = (extra['reference2_phone'] ?? '').toString();
    } else {
      _legalName.text = (u['company_name'] ?? '').toString();
      _gst.text = (u['gst_number'] ?? '').toString();
      _annualTurnover.text = (u['turnover'] ?? '').toString();
      _numEmployees.text = (u['employee_count'] ?? '').toString();
      _promoterName.text = (u['name'] ?? '').toString();
      _promoterMobile.text = (u['mobile'] ?? '').toString();
      _promoterEmail.text = (u['email'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _legalName.dispose();
    _tradeName.dispose();
    _entityType.dispose();
    _industry.dispose();
    _dateIncorp.dispose();
    _udyamMsme.dispose();
    _cinLlpin.dispose();
    _panBusiness.dispose();
    _gst.dispose();
    _bizAddress.dispose();
    _bizPincode.dispose();
    _bizCity.dispose();
    _bizState.dispose();
    _yearsInBusiness.dispose();
    _numEmployees.dispose();
    _annualTurnover.dispose();
    _annualProfit.dispose();
    _existingBankLimit.dispose();
    _monthlyObligations.dispose();
    _avgBankBalance.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    _tenureController.dispose();
    _collateralOffered.dispose();
    _expectedDisbursementDate.dispose();
    _promoterName.dispose();
    _designation.dispose();
    _promoterPan.dispose();
    _promoterMobile.dispose();
    _promoterEmail.dispose();
    _residentialAddress.dispose();
    _accHolderName.dispose();
    _bankName.dispose();
    _branch.dispose();
    _accountNumber.dispose();
    _ifsc.dispose();
    _ref1Name.dispose();
    _ref1Phone.dispose();
    _ref2Name.dispose();
    _ref2Phone.dispose();
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
      "user_id": widget.userData['id'],
      "type": "biz_loan",
      if (widget.initialLead != null) "lead_id": widget.initialLead.id,
      "data": {
        if (widget.initialLead != null) "id": widget.initialLead.id,
        "loan_product": "Business / MSME Loan",
        "legal_business_name": _legalName.text.trim(),
        "trade_name": _tradeName.text.trim(),
        "entity_type": _entityType.text.trim(),
        "industry_sector": _industry.text.trim(),
        "date_of_incorporation": _dateIncorp.text.trim(),
        "udyam_msme_number": _udyamMsme.text.trim(),
        "cin_llpin": _cinLlpin.text.trim(),
        "business_pan": _panBusiness.text.trim().toUpperCase(),
        "gst_number": _gst.text.trim().toUpperCase(),
        "registered_office_address": _bizAddress.text.trim(),
        "business_pincode": _bizPincode.text.trim(),
        "business_city": _bizCity.text.trim(),
        "business_state": _bizState.text.trim(),
        "years_in_business": _yearsInBusiness.text.trim(),
        "number_of_employees": _numEmployees.text.trim(),
        "annual_turnover": _annualTurnover.text.trim(),
        "annual_profit_pat": _annualProfit.text.trim(),
        "existing_bank_facility_limit": _existingBankLimit.text.trim(),
        "monthly_obligations_emi": _monthlyObligations.text.trim(),
        "average_bank_balance": _avgBankBalance.text.trim(),
        "amount": _amountController.text.trim(),
        "purpose": _purposeController.text.trim(),
        "tenure": _tenureController.text.trim(),
        "collateral_offered": _collateralOffered.text.trim(),
        "expected_disbursement_timeline": _expectedDisbursementDate.text.trim(),
        "promoter_applicant_name": _promoterName.text.trim(),
        "promoter_designation": _designation.text.trim(),
        "promoter_pan": _promoterPan.text.trim().toUpperCase(),
        "promoter_mobile": _promoterMobile.text.trim(),
        "promoter_email": _promoterEmail.text.trim(),
        "promoter_residential_address": _residentialAddress.text.trim(),
        "account_holder_name": _accHolderName.text.trim(),
        "bank_name": _bankName.text.trim(),
        "branch": _branch.text.trim(),
        "account_number": _accountNumber.text.trim(),
        "ifsc": _ifsc.text.trim().toUpperCase(),
        "reference1_name": _ref1Name.text.trim(),
        "reference1_phone": _ref1Phone.text.trim(),
        "reference2_name": _ref2Name.text.trim(),
        "reference2_phone": _ref2Phone.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.ok) {
      final extra = result.infoMessage.isNotEmpty ? ' ${result.infoMessage}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Business loan application submitted.$extra')),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Business loan application',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        centerTitle: true,
      ),
      body: ResponsiveFormScroll(
        formKey: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fill what you know; legal name, constitution, loan amount, purpose, and promoter contact are required.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Business identity'),
              _loanFormField(
                controller: _legalName,
                label: 'Legal name of business',
                icon: Icons.business,
                validator: _req,
              ),
              _loanFormField(
                controller: _tradeName,
                label: 'Trade / brand name (if different)',
                icon: Icons.storefront,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _entityType,
                label: 'Constitution (Pvt Ltd / LLP / Partnership / Proprietorship)',
                icon: Icons.account_tree,
                validator: _req,
              ),
              _loanFormField(
                controller: _industry,
                label: 'Industry / activity',
                icon: Icons.category,
                validator: (_) => null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _dateIncorp,
                      label: 'Date of incorporation / start (DD/MM/YYYY)',
                      icon: Icons.event,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _yearsInBusiness,
                      label: 'Years in current business',
                      icon: Icons.history,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _udyamMsme,
                label: 'UDYAM / MSME registration number (if applicable)',
                icon: Icons.numbers,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _cinLlpin,
                label: 'CIN / LLPIN (if company / LLP)',
                icon: Icons.fingerprint,
                validator: (_) => null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _panBusiness,
                      label: 'Business PAN',
                      icon: Icons.badge,
                      validator: _panOptional,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _gst,
                      label: 'GSTIN',
                      icon: Icons.receipt_long,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _numEmployees,
                label: 'Number of employees',
                icon: Icons.groups,
                keyboardType: TextInputType.number,
                validator: (_) => null,
              ),
              _buildSectionTitle('Registered office / principal place'),
              _loanFormField(
                controller: _bizAddress,
                label: 'Complete address',
                icon: Icons.location_on,
                maxLines: 2,
                validator: (_) => null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _bizPincode,
                      label: 'PIN code',
                      icon: Icons.pin,
                      keyboardType: TextInputType.number,
                      validator: _optPin6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _bizCity,
                      label: 'City',
                      icon: Icons.location_city,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _bizState,
                label: 'State',
                icon: Icons.flag,
                validator: (_) => null,
              ),
              _buildSectionTitle('Financial position (as per books)'),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _annualTurnover,
                      label: 'Annual turnover (₹)',
                      icon: Icons.trending_up,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _annualProfit,
                      label: 'Net profit / PAT last FY (₹)',
                      icon: Icons.savings,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _existingBankLimit,
                label: 'Existing bank / WC limits (₹) — or None',
                icon: Icons.account_balance_wallet,
                validator: (_) => null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _monthlyObligations,
                      label: 'Total monthly EMI / obligations (₹)',
                      icon: Icons.payments,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _avgBankBalance,
                      label: 'Avg. monthly bank balance (₹, approx.)',
                      icon: Icons.account_balance,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _buildSectionTitle('Loan request'),
              _loanFormField(
                controller: _amountController,
                label: 'Loan amount required (₹)',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: _requiredDecimal,
              ),
              _loanFormField(
                controller: _purposeController,
                label: 'Purpose (WC, machinery, expansion, etc.)',
                icon: Icons.business_center,
                maxLines: 2,
                validator: _req,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _tenureController,
                      label: 'Tenure (months)',
                      icon: Icons.calendar_month,
                      keyboardType: TextInputType.number,
                      validator: _requiredInt,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _expectedDisbursementDate,
                      label: 'Funds needed by (DD/MM/YYYY)',
                      icon: Icons.event_available,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _collateralOffered,
                label: 'Primary security offered (property / FD / stock hypothecation)',
                icon: Icons.home_work,
                maxLines: 3,
                validator: (_) => null,
              ),
              _buildSectionTitle('Authorised signatory / promoter'),
              _loanFormField(
                controller: _promoterName,
                label: 'Full name',
                icon: Icons.person,
                validator: _req,
              ),
              _loanFormField(
                controller: _designation,
                label: 'Designation',
                icon: Icons.work,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _promoterPan,
                label: 'Personal PAN',
                icon: Icons.badge_outlined,
                validator: _panOptional,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _promoterMobile,
                      label: 'Mobile',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.length < 10) ? 'Valid mobile' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _promoterEmail,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _optEmail,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _residentialAddress,
                label: 'Residential address of promoter',
                icon: Icons.home,
                maxLines: 2,
                validator: (_) => null,
              ),
              _buildSectionTitle('Operating / disbursement account'),
              _loanFormField(
                controller: _accHolderName,
                label: 'Account holder name',
                icon: Icons.person_outline,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _bankName,
                label: 'Bank name',
                icon: Icons.account_balance,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _branch,
                label: 'Branch',
                icon: Icons.store_mall_directory,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _accountNumber,
                label: 'Account number',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _ifsc,
                label: 'IFSC',
                icon: Icons.alt_route,
                validator: _ifscOptional,
              ),
              _buildSectionTitle('Trade references'),
              _loanFormField(
                controller: _ref1Name,
                label: 'Reference 1 — business / supplier name',
                icon: Icons.contact_page,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _ref1Phone,
                label: 'Reference 1 — phone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: _optPhone,
              ),
              _loanFormField(
                controller: _ref2Name,
                label: 'Reference 2 — name',
                icon: Icons.contact_page_outlined,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _ref2Phone,
                label: 'Reference 2 — phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: _optPhone,
              ),
              CheckboxListTile(
                value: _declarationAccepted,
                onChanged: (v) => setState(() => _declarationAccepted = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I confirm particulars are true and authorise the bank to obtain credit information and verify documents.',
                  style: TextStyle(fontSize: 13, height: 1.35),
                ),
              ),
              const SizedBox(height: 16),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF2196F3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFF2196F3).withOpacity(0.5),
                        ),
                        child: const Text(
                          'SUBMIT APPLICATION',
                          style: TextStyle(
                            fontSize: 16,
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
}

class PostJobScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic>? initialJob;
  const PostJobScreen({super.key, required this.userData, this.initialJob});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _salaryController = TextEditingController();
  final _companyController = TextEditingController();
  final _departmentController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _skillsController = TextEditingController();
  final _openingsController = TextEditingController(text: '1');
  final _deadlineController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _benefitsController = TextEditingController();

  String _jobType = 'Internship';
  String _workMode = 'On-site';
  bool _isSaving = false;

  static const _jobTypes = [
    'Internship',
    'Full-time',
    'Part-time',
    'Contract',
    'Freelance',
  ];

  static const _workModes = ['On-site', 'Remote', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    final u = widget.userData;
    
    if (widget.initialJob != null) {
      final job = widget.initialJob!;
      _titleController.text = _str(job['job_title']);
      _descController.text = _str(job['description']);
      _salaryController.text = _str(job['salary_range']);
      _companyController.text = _str(job['company_name']);
      _departmentController.text = _str(job['department']);
      _locationController.text = _str(job['location']);
      _experienceController.text = _str(job['experience_required']);
      _qualificationController.text = _str(job['qualification']);
      _skillsController.text = _str(job['skills_required']);
      _openingsController.text = _str(job['openings'] ?? '1');
      _deadlineController.text = _str(job['application_deadline']);
      _contactEmailController.text = _str(job['contact_email']);
      _contactPhoneController.text = _str(job['contact_phone']);
      _benefitsController.text = _str(job['benefits']);
      
      if (_jobTypes.contains(job['job_type'])) _jobType = job['job_type'];
      if (_workModes.contains(job['work_mode'])) _workMode = job['work_mode'];
    } else {
      _companyController.text = _str(u['company_name']);
      _locationController.text = [
        _str(u['city']),
        _str(u['district']),
        _str(u['state']),
      ].where((s) => s.isNotEmpty).join(', ');
      _contactEmailController.text = _str(u['email']);
      _contactPhoneController.text = _str(u['mobile']);
    }
  }

  String _str(dynamic v) {
    if (v == null) return '';
    final s = v.toString().trim();
    return s.isEmpty || s == 'null' ? '' : s;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _salaryController.dispose();
    _companyController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    _qualificationController.dispose();
    _skillsController.dispose();
    _openingsController.dispose();
    _deadlineController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  void _openAiGraphics() {
    final company = _companyController.text.trim();
    final title = _titleController.text.trim();
    final prompt = AiGraphicsService.jobPostingPrompt(
      company: company.isEmpty ? 'Company' : company,
      jobTitle: title.isEmpty ? 'Job opening' : title,
      jobType: _jobType,
      location: _locationController.text.trim(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AiGraphicsScreen(
          userData: widget.userData,
          initialPrompt: prompt,
          initialSizeKey: 'job',
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      final y = picked.year;
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      _deadlineController.text = '$y-$m-$d';
    }
  }

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final payload = {
      'user_id': widget.userData['id'],
      'type': widget.initialJob != null ? 'job_update' : 'job_post',
      'data': {
        if (widget.initialJob != null) 'id': widget.initialJob!['id'],
        'job_title': _titleController.text.trim(),
        'company_name': _companyController.text.trim(),
        'description': _descController.text.trim(),
        'salary_range': _salaryController.text.trim(),
        'job_type': _jobType,
        'work_mode': _workMode,
        'department': _departmentController.text.trim(),
        'location': _locationController.text.trim(),
        'experience_required': _experienceController.text.trim(),
        'qualification': _qualificationController.text.trim(),
        'skills_required': _skillsController.text.trim(),
        'openings': _openingsController.text.trim(),
        'application_deadline': _deadlineController.text.trim(),
        'contact_email': _contactEmailController.text.trim(),
        'contact_phone': _contactPhoneController.text.trim(),
        'benefits': _benefitsController.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.ok) {
      final extra = result.infoMessage.isNotEmpty ? ' ${result.infoMessage}' : '';
      final actionWord = widget.initialJob != null ? 'updated' : 'posted';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job $actionWord successfully.$extra')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage.isEmpty
                ? 'Failed (HTTP ${result.statusCode}).'
                : result.errorMessage,
          ),
        ),
      );
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: _inputStyle(context, label, icon),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        onTap: onTap,
        readOnly: readOnly,
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: _inputStyle(context, label, icon),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.initialJob != null ? 'Update Job' : 'Post a New Job',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        centerTitle: true,
      ),
      body: ResponsiveFormScroll(
        formKey: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Company & role'),
            _field(
              controller: _companyController,
              label: 'Company name *',
              icon: Icons.business,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            _field(
              controller: _titleController,
              label: 'Job title *',
              icon: Icons.work,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OutlinedButton.icon(
                onPressed: _openAiGraphics,
                icon: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF2196F3),
                ),
                label: const Text('Generate hiring graphic with AI'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF2196F3)),
                ),
              ),
            ),
            _field(
              controller: _departmentController,
              label: 'Department / function',
              icon: Icons.apartment,
            ),
            _dropdown(
              label: 'Job type',
              icon: Icons.badge_outlined,
              value: _jobType,
              items: _jobTypes,
              onChanged: (v) {
                if (v != null) setState(() => _jobType = v);
              },
            ),
            _dropdown(
              label: 'Work mode',
              icon: Icons.laptop_chromebook,
              value: _workMode,
              items: _workModes,
              onChanged: (v) {
                if (v != null) setState(() => _workMode = v);
              },
            ),
            _buildSectionTitle('Job details'),
            _field(
              controller: _descController,
              label: 'Job description *',
              icon: Icons.description,
              maxLines: 4,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            _field(
              controller: _salaryController,
              label: 'Salary / stipend range *',
              icon: Icons.payments,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            _field(
              controller: _locationController,
              label: 'Job location',
              icon: Icons.location_on_outlined,
            ),
            _field(
              controller: _experienceController,
              label: 'Experience required',
              icon: Icons.timeline,
            ),
            _field(
              controller: _qualificationController,
              label: 'Qualification / education',
              icon: Icons.school_outlined,
            ),
            _field(
              controller: _skillsController,
              label: 'Skills required (comma separated)',
              icon: Icons.psychology_outlined,
            ),
            _field(
              controller: _openingsController,
              label: 'Number of openings',
              icon: Icons.groups_outlined,
              keyboardType: TextInputType.number,
            ),
            _field(
              controller: _benefitsController,
              label: 'Perks & benefits (optional)',
              icon: Icons.card_giftcard_outlined,
              maxLines: 2,
            ),
            _buildSectionTitle('Application'),
            _field(
              controller: _deadlineController,
              label: 'Application deadline',
              icon: Icons.event,
              readOnly: true,
              onTap: _pickDeadline,
            ),
            _field(
              controller: _contactEmailController,
              label: 'HR contact email *',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            _field(
              controller: _contactPhoneController,
              label: 'HR contact phone',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        shadowColor: const Color(0xFF2196F3).withOpacity(0.5),
                      ),
                      child: const Text(
                        'POST JOB',
                        style: TextStyle(
                          fontSize: 16,
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
}

class MyJobsScreen extends StatefulWidget {
  final int userId;
  const MyJobsScreen({super.key, required this.userId});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  late Future<List<dynamic>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = ServiceController().fetchBusinessJobs(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Posted Jobs")),
      body: FutureBuilder<List<dynamic>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) return const Center(child: Text("You haven't posted any jobs yet."));
          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.work, color: Color(0xFF2196F3)),
                  title: Text(job['job_title'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Salary: ${job['salary_range'] ?? 'N/A'}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'view') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(job['job_title'] ?? 'Job Details'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: (() {
                                  final m = job as Map<String, dynamic>;
                                  Map<String, dynamic> details = {};
                                  if (m['details'] is String) {
                                    try { details = jsonDecode(m['details']); } catch (_) {}
                                  } else if (m['details'] is Map) {
                                    details = Map<String, dynamic>.from(m['details']);
                                  }
                                  
                                  Widget row(String k, dynamic v) {
                                    if (v == null || v.toString().trim().isEmpty) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                                          children: [
                                            TextSpan(text: '$k: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            TextSpan(text: v.toString()),
                                          ]
                                        )
                                      ),
                                    );
                                  }
                                  
                                  return [
                                    row('Company', details['company_name'] ?? m['company_name']),
                                    row('Location', details['location'] ?? m['location']),
                                    row('Job Type', details['job_type'] ?? m['job_type']),
                                    row('Work Mode', details['work_mode'] ?? m['work_mode']),
                                    row('Salary', details['salary_range'] ?? m['salary_range']),
                                    row('Openings', details['openings']),
                                    row('Description', details['description'] ?? m['description']),
                                    row('Contact Email', details['contact_email']),
                                    row('Contact Phone', details['contact_phone']),
                                  ];
                                })(),
                              ),
                            ),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                          ),
                        );
                      } else if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostJobScreen(
                              userData: {'id': widget.userId},
                              initialJob: job as Map<String, dynamic>,
                            ),
                          ),
                        ).then((_) => setState(() {
                              _jobsFuture = ServiceController().fetchBusinessJobs(widget.userId);
                            }));
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text('View Details')),
                      const PopupMenuItem(value: 'edit', child: Text('Edit / Update')),
                    ],
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

class ApplicantsScreen extends StatefulWidget {
  final int userId;
  const ApplicantsScreen({super.key, required this.userId});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  late Future<List<dynamic>> _applicantsFuture;

  @override
  void initState() {
    super.initState();
    _applicantsFuture = ServiceController().fetchBusinessApplicants(widget.userId);
  }

  void _showApplicantDetails(Map<String, dynamic> app) {
    Map<String, dynamic> details = {};
    final d = app['details'];
    if (d is Map) {
      details = Map<String, dynamic>.from(d);
    } else if (d is String) {
      try {
        details = jsonDecode(d);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            Widget infoRow(String label, String? val) {
              if (val == null || val.trim().isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(val, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(app['applicant_name'] ?? 'Applicant', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(app['applicant_email'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
                  Text(app['applicant_mobile'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text("Application Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  if (details.isEmpty)
                    const Text("No additional details were provided.")
                  else ...[
                    infoRow("Education", "${details['degree_program'] ?? ''} in ${details['branch_major'] ?? ''} from ${details['institution'] ?? ''}"),
                    infoRow("CGPA / Percentage", details['cgpa_or_percentage']),
                    infoRow("Graduation Year", details['graduation_year']),
                    infoRow("Skills", details['skills']),
                    infoRow("Experience", details['work_experience_internships']),
                    infoRow("Projects", details['projects']),
                    infoRow("LinkedIn", details['linkedin_url']),
                    infoRow("Portfolio / GitHub", [details['portfolio_url'], details['github_url']].where((e) => e != null && e.toString().isNotEmpty).join(' | ')),
                    infoRow("Expected Stipend", details['expected_stipend']),
                    infoRow("Cover Letter", details['cover_letter']),
                    infoRow("Why this role?", details['why_this_role']),
                    if ((details['resume_link']?.toString() ?? '').isNotEmpty)
                      infoRow("Resume Link", details['resume_link']),
                    if ((details['resume_base64']?.toString() ?? '').isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 20),
                        child: Text("📎 PDF Resume is attached to this application (Base64).", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Applicants")),
      body: FutureBuilder<List<dynamic>>(
        future: _applicantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          final applicants = snapshot.data ?? [];
          if (applicants.isEmpty) return const Center(child: Text("No students have applied to your jobs yet."));
          return ListView.builder(
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              final app = applicants[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFF2196F3), child: Icon(Icons.person, color: Colors.white)),
                  title: Text(app['applicant_name'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Applied for: ${app['job_title'] ?? 'Job'}"),
                  trailing: Text(app['status'] ?? "Pending", style: const TextStyle(color: Colors.blue)),
                  onTap: () => _showApplicantDetails(app),
                ),
              );
            },
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
  final _formKey = GlobalKey<FormState>();

  static const int _maxPhotoBytes = 600000;

  // Farmer & location
  final _farmerName = TextEditingController();
  final _mobile = TextEditingController();
  final _village = TextEditingController();
  final _tehsil = TextEditingController();
  final _district = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _khataFarmerId = TextEditingController();

  // Land
  final _surveyNumber = TextEditingController();
  final _khasraNumber = TextEditingController();
  final _landParcelArea = TextEditingController();
  final _soilType = TextEditingController();

  // Crop
  final _cropName = TextEditingController();
  final _variety = TextEditingController();
  final _sowingDate = TextEditingController();
  final _expectedHarvest = TextEditingController();
  final _areaSownAcres = TextEditingController();
  final _expectedYieldQuintal = TextEditingController();
  final _priceController = TextEditingController();
  final _seedSource = TextEditingController();
  final _fertilizerPlan = TextEditingController();
  final _irrigationSchedule = TextEditingController();
  final _pestManagement = TextEditingController();
  final _nearestApmc = TextEditingController();
  final _remarks = TextEditingController();

  String _season = 'Kharif';
  String _irrigationSource = 'Tubewell / borewell';
  String _landTenure = 'Own';
  bool _certifiedSeed = false;
  bool _organicClaim = false;
  bool _declaration = false;

  String? _photoFileName;
  List<int>? _photoBytes;
  String? _photoError;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.userData;
    _farmerName.text = (u['name'] ?? '').toString();
    _mobile.text = (u['mobile'] ?? '').toString();
    _district.text = (u['district'] ?? '').toString();
    _state.text = (u['state'] ?? '').toString();
    _pincode.text = (u['pincode'] ?? '').toString();
    _cropName.text = (u['crop_name'] ?? '').toString();
    _priceController.text = (u['crop_price'] ?? '').toString();
  }

  @override
  void dispose() {
    _farmerName.dispose();
    _mobile.dispose();
    _village.dispose();
    _tehsil.dispose();
    _district.dispose();
    _state.dispose();
    _pincode.dispose();
    _khataFarmerId.dispose();
    _surveyNumber.dispose();
    _khasraNumber.dispose();
    _landParcelArea.dispose();
    _soilType.dispose();
    _cropName.dispose();
    _variety.dispose();
    _sowingDate.dispose();
    _expectedHarvest.dispose();
    _areaSownAcres.dispose();
    _expectedYieldQuintal.dispose();
    _priceController.dispose();
    _seedSource.dispose();
    _fertilizerPlan.dispose();
    _irrigationSchedule.dispose();
    _pestManagement.dispose();
    _nearestApmc.dispose();
    _remarks.dispose();
    super.dispose();
  }

  Future<void> _pickCropPhoto() async {
    setState(() => _photoError = null);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final f = result.files.single;
      final bytes = f.bytes;
      if (bytes == null) {
        setState(() {
          _photoError = 'Could not read image. Try another photo.';
        });
        return;
      }
      if (bytes.length > _maxPhotoBytes) {
        setState(() {
          _photoError =
              'Image too large (max ~${(_maxPhotoBytes / 1000000).toStringAsFixed(1)}MB). Compress or take a smaller photo.';
        });
        return;
      }
      setState(() {
        _photoFileName = f.name;
        _photoBytes = bytes.toList();
        _photoError = null;
      });
    } catch (e) {
      setState(() => _photoError = 'Pick failed: $e');
    }
  }

  void _clearPhoto() {
    setState(() {
      _photoFileName = null;
      _photoBytes = null;
      _photoError = null;
    });
  }

  Future<void> _saveCrop() async {
    if (!_declaration) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the declaration')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final landParcelArea = _parseDecimal(_landParcelArea.text);
    final areaSown = _parseDecimal(_areaSownAcres.text);
    final expectedYield = _parseDecimal(_expectedYieldQuintal.text);
    final expectedPrice = _parseDecimal(_priceController.text);
    final sowingDateIso = _toIsoDate(_sowingDate.text);
    final harvestDateIso = _toIsoDate(_expectedHarvest.text);
    if ([landParcelArea, areaSown, expectedYield, expectedPrice].any((v) => v == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numeric values for area, yield, and price.')),
      );
      return;
    }
    if (sowingDateIso == null || harvestDateIso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid dates in DD/MM/YYYY format.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final hasPhoto = _photoBytes != null && _photoBytes!.isNotEmpty;

    final data = <String, dynamic>{
      'registration_type': 'crop_sowing_market_intent',
      'farmer_name': _farmerName.text.trim(),
      'mobile': _mobile.text.trim(),
      'village': _village.text.trim(),
      'tehsil_block': _tehsil.text.trim(),
      'district': _district.text.trim(),
      'state': _state.text.trim(),
      'pincode': _pincode.text.trim(),
      'khata_farmer_id_note': _khataFarmerId.text.trim(),
      'survey_number': _surveyNumber.text.trim(),
      'khasra_plot': _khasraNumber.text.trim(),
      'land_parcel_total_area_acres': landParcelArea,
      'land_tenure': _landTenure,
      'soil_type': _soilType.text.trim(),
      'crop_name': _cropName.text.trim(),
      'price': expectedPrice,
      'variety_hybrid': _variety.text.trim(),
      'season': _season,
      'sowing_date': sowingDateIso,
      'expected_harvest_date': harvestDateIso,
      'area_sown_acres': areaSown,
      'irrigation_source': _irrigationSource,
      'irrigation_schedule_notes': _irrigationSchedule.text.trim(),
      'certified_seed_used': _certifiedSeed,
      'seed_source_lot': _seedSource.text.trim(),
      'fertilizer_plan': _fertilizerPlan.text.trim(),
      'pest_disease_management': _pestManagement.text.trim(),
      'organic_farming_claim': _organicClaim,
      'expected_yield_quintals': expectedYield,
      'expected_price_per_quintal': expectedPrice,
      'nearest_apmc_mandi': _nearestApmc.text.trim(),
      'remarks': _remarks.text.trim(),
      'crop_photo_filename': _photoFileName ?? '',
      if (hasPhoto) 'crop_photo_base64': base64Encode(_photoBytes!),
    };

    final payload = {
      'user_id': widget.userData['id'],
      'type': 'crop_reg',
      'data': data,
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.ok) {
      final extra = result.infoMessage.isNotEmpty ? ' ${result.infoMessage}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Crop registration submitted.$extra')),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Crop registration',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        centerTitle: true,
      ),
      body: ResponsiveFormScroll(
        formKey: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Provide details as typically required for government / mandi crop registration and traceability.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Farmer & contact'),
              _loanFormField(
                controller: _farmerName,
                label: 'Farmer full name',
                icon: Icons.person,
                validator: _req,
              ),
              _loanFormField(
                controller: _mobile,
                label: 'Mobile number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.length < 10) ? 'Valid mobile required' : null,
              ),
              _loanFormField(
                controller: _village,
                label: 'Village / revenue village',
                icon: Icons.home,
                validator: _req,
              ),
              _loanFormField(
                controller: _tehsil,
                label: 'Tehsil / block',
                icon: Icons.map,
                validator: _req,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _district,
                      label: 'District',
                      icon: Icons.location_city,
                      validator: _req,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _state,
                      label: 'State',
                      icon: Icons.flag,
                      validator: _req,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _pincode,
                label: 'PIN code',
                icon: Icons.pin,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().length != 6) ? '6-digit PIN' : null,
              ),
              _loanFormField(
                controller: _khataFarmerId,
                label: 'Khata / farmer ID on land records (if any)',
                icon: Icons.badge_outlined,
                validator: (_) => null,
              ),
              _buildSectionTitle('Land parcel'),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _surveyNumber,
                      label: 'Survey number',
                      icon: Icons.explore,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _khasraNumber,
                      label: 'Khasra / plot no.',
                      icon: Icons.grid_on,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _landParcelArea,
                label: 'Total field area for this crop (acres)',
                icon: Icons.landscape,
                keyboardType: TextInputType.number,
                validator: (v) => _requiredDecimal(v, 'Enter valid acres'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _landTenure,
                decoration: _inputStyle(context, 'Land tenure', Icons.handshake),
                items: const [
                  DropdownMenuItem(value: 'Own', child: Text('Own')),
                  DropdownMenuItem(value: 'Lease', child: Text('Lease')),
                  DropdownMenuItem(value: 'Sharecropping', child: Text('Sharecropping')),
                ],
                onChanged: (v) => setState(() => _landTenure = v ?? 'Own'),
              ),
              const SizedBox(height: 8),
              _loanFormField(
                controller: _soilType,
                label: 'Soil type (optional, e.g. loam / clay)',
                icon: Icons.layers,
                validator: (_) => null,
              ),
              _buildSectionTitle('Crop & season'),
              _loanFormField(
                controller: _cropName,
                label: 'Crop name',
                icon: Icons.grass,
                validator: _req,
              ),
              _loanFormField(
                controller: _variety,
                label: 'Variety / hybrid name',
                icon: Icons.eco,
                validator: _req,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _season,
                decoration: _inputStyle(context, 'Season', Icons.calendar_month),
                items: const [
                  DropdownMenuItem(value: 'Kharif', child: Text('Kharif')),
                  DropdownMenuItem(value: 'Rabi', child: Text('Rabi')),
                  DropdownMenuItem(value: 'Zaid', child: Text('Zaid')),
                ],
                onChanged: (v) => setState(() => _season = v ?? 'Kharif'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _sowingDate,
                      label: 'Sowing date (DD/MM/YYYY)',
                      icon: Icons.event,
                      validator: _requiredDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _expectedHarvest,
                      label: 'Expected harvest (DD/MM/YYYY)',
                      icon: Icons.event_available,
                      validator: _requiredDate,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _areaSownAcres,
                label: 'Area sown under this crop (acres)',
                icon: Icons.square_foot,
                keyboardType: TextInputType.number,
                validator: (v) => _requiredDecimal(v, 'Enter valid acres'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _irrigationSource,
                decoration: _inputStyle(context, 'Primary irrigation', Icons.water),
                items: const [
                  DropdownMenuItem(
                    value: 'Tubewell / borewell',
                    child: Text('Tubewell / borewell'),
                  ),
                  DropdownMenuItem(value: 'Canal', child: Text('Canal')),
                  DropdownMenuItem(value: 'Drip / sprinkler', child: Text('Drip / sprinkler')),
                  DropdownMenuItem(value: 'Rainfed', child: Text('Rainfed')),
                  DropdownMenuItem(value: 'Mixed', child: Text('Mixed')),
                ],
                onChanged: (v) =>
                    setState(() => _irrigationSource = v ?? 'Tubewell / borewell'),
              ),
              const SizedBox(height: 8),
              _loanFormField(
                controller: _irrigationSchedule,
                label: 'Irrigation rounds / notes (optional)',
                icon: Icons.opacity,
                maxLines: 2,
                validator: (_) => null,
              ),
              SwitchListTile(
                title: const Text('Certified / quality seed used'),
                value: _certifiedSeed,
                onChanged: (v) => setState(() => _certifiedSeed = v),
                activeColor: const Color(0xFF2196F3),
              ),
              _loanFormField(
                controller: _seedSource,
                label: 'Seed source & batch / lot (if known)',
                icon: Icons.agriculture,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _fertilizerPlan,
                label: 'Fertilizer & nutrient plan (brief)',
                icon: Icons.science,
                maxLines: 3,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _pestManagement,
                label: 'Pest / disease control plan (optional)',
                icon: Icons.bug_report,
                maxLines: 2,
                validator: (_) => null,
              ),
              SwitchListTile(
                title: const Text('Organic farming claim (subject to verification)'),
                value: _organicClaim,
                onChanged: (v) => setState(() => _organicClaim = v),
                activeColor: const Color(0xFF2196F3),
              ),
              _buildSectionTitle('Expected output & price'),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _expectedYieldQuintal,
                      label: 'Expected yield (quintals)',
                      icon: Icons.scale,
                      keyboardType: TextInputType.number,
                      validator: (v) => _requiredDecimal(v, 'Enter valid yield'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _priceController,
                      label: 'Expected price (₹ / quintal)',
                      icon: Icons.sell,
                      keyboardType: TextInputType.number,
                      validator: (v) => _requiredDecimal(v, 'Enter valid price'),
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _nearestApmc,
                label: 'Preferred APMC / mandi (optional)',
                icon: Icons.store,
                validator: (_) => null,
              ),
              _buildSectionTitle('Crop field photo (optional)'),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _pickCropPhoto,
                icon: const Icon(Icons.add_a_photo),
                label: Text(
                  _photoFileName == null ? 'Attach field / crop photo' : 'Change photo',
                ),
              ),
              if (_photoFileName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text(_photoFileName!)),
                    TextButton(onPressed: _clearPhoto, child: const Text('Remove')),
                  ],
                ),
              ],
              if (_photoError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_photoError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),
              _buildSectionTitle('Other remarks'),
              _loanFormField(
                controller: _remarks,
                label: 'Any other information for officials / buyers',
                icon: Icons.notes,
                maxLines: 3,
                validator: (_) => null,
              ),
              CheckboxListTile(
                value: _declaration,
                onChanged: (v) => setState(() => _declaration = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I declare that the crop, area, and location details are correct to the best of my knowledge.',
                  style: TextStyle(fontSize: 13, height: 1.35),
                ),
              ),
              const SizedBox(height: 20),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveCrop,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF2196F3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFF2196F3).withOpacity(0.5),
                        ),
                        child: const Text(
                          'SUBMIT REGISTRATION',
                          style: TextStyle(
                            fontSize: 16,
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
}

// --- FARMER LOAN FORM (KCC) ---
class FarmerLoanForm extends StatefulWidget {
  final Map<String, dynamic> userData;
  final dynamic initialLead;
  const FarmerLoanForm({super.key, required this.userData, this.initialLead});

  @override
  State<FarmerLoanForm> createState() => _FarmerLoanFormState();
}

class _FarmerLoanFormState extends State<FarmerLoanForm> {
  final _formKey = GlobalKey<FormState>();

  // Applicant
  final _applicantName = TextEditingController();
  final _fatherName = TextEditingController();
  final _dob = TextEditingController();
  final _pan = TextEditingController();
  final _aadhaar = TextEditingController();
  final _mobile = TextEditingController();
  final _village = TextEditingController();
  final _tehsil = TextEditingController();
  final _district = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();

  // Land & cultivation
  final _landSizeController = TextEditingController();
  final _khasraController = TextEditingController();
  final _khataNumber = TextEditingController();
  final _surveyNumber = TextEditingController();
  final _ownershipType = TextEditingController();
  final _irrigatedArea = TextEditingController();
  final _unirrigatedArea = TextEditingController();
  final _mainCrops = TextEditingController();
  final _irrigationSource = TextEditingController();

  // Loan
  final _amountController = TextEditingController();
  final _loanPurpose = TextEditingController();
  final _tenureMonths = TextEditingController();
  final _existingKccOutstanding = TextEditingController();

  // Income
  final _agriIncomeAnnual = TextEditingController();
  final _otherIncome = TextEditingController();

  // Banking & references
  final _accHolderName = TextEditingController();
  final _bankName = TextEditingController();
  final _branch = TextEditingController();
  final _accountNumber = TextEditingController();
  final _ifsc = TextEditingController();
  final _ref1Name = TextEditingController();
  final _ref1Phone = TextEditingController();
  final _ref2Name = TextEditingController();
  final _ref2Phone = TextEditingController();

  bool _declarationAccepted = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.userData;
    _applicantName.text = (u['name'] ?? '').toString();
    _mobile.text = (u['mobile'] ?? '').toString();
    _district.text = (u['district'] ?? '').toString();
    _state.text = (u['state'] ?? '').toString();
    _pincode.text = (u['pincode'] ?? '').toString();
  }

  @override
  void dispose() {
    _applicantName.dispose();
    _fatherName.dispose();
    _dob.dispose();
    _pan.dispose();
    _aadhaar.dispose();
    _mobile.dispose();
    _village.dispose();
    _tehsil.dispose();
    _district.dispose();
    _state.dispose();
    _pincode.dispose();
    _landSizeController.dispose();
    _khasraController.dispose();
    _khataNumber.dispose();
    _surveyNumber.dispose();
    _ownershipType.dispose();
    _irrigatedArea.dispose();
    _unirrigatedArea.dispose();
    _mainCrops.dispose();
    _irrigationSource.dispose();
    _amountController.dispose();
    _loanPurpose.dispose();
    _tenureMonths.dispose();
    _existingKccOutstanding.dispose();
    _agriIncomeAnnual.dispose();
    _otherIncome.dispose();
    _accHolderName.dispose();
    _bankName.dispose();
    _branch.dispose();
    _accountNumber.dispose();
    _ifsc.dispose();
    _ref1Name.dispose();
    _ref1Phone.dispose();
    _ref2Name.dispose();
    _ref2Phone.dispose();
    super.dispose();
  }

  void _applyForLoan() async {
    if (!_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the declaration')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = {
      "user_id": widget.userData['id'],
      "type": "kisan_loan",
      "data": {
        "loan_product": "Kisan / Agri term loan",
        "applicant_name": _applicantName.text.trim(),
        "father_name": _fatherName.text.trim(),
        "dob": _dob.text.trim(),
        "pan": _pan.text.trim().toUpperCase(),
        "aadhaar": _aadhaar.text.trim(),
        "mobile": _mobile.text.trim(),
        "village": _village.text.trim(),
        "tehsil": _tehsil.text.trim(),
        "district": _district.text.trim(),
        "state": _state.text.trim(),
        "pincode": _pincode.text.trim(),
        "land_size": _landSizeController.text.trim().isEmpty ? "0" : _landSizeController.text.trim(),
        "khasra_number": _khasraController.text.trim().isEmpty ? "N/A" : _khasraController.text.trim(),
        "khata_number": _khataNumber.text.trim(),
        "survey_number": _surveyNumber.text.trim(),
        "ownership_type": _ownershipType.text.trim(),
        "irrigated_area_acres": _irrigatedArea.text.trim(),
        "unirrigated_area_acres": _unirrigatedArea.text.trim(),
        "main_crops": _mainCrops.text.trim(),
        "irrigation_source": _irrigationSource.text.trim(),
        "amount": _amountController.text.trim(),
        "loan_purpose": _loanPurpose.text.trim(),
        "tenure_months": _tenureMonths.text.trim(),
        "existing_kcc_outstanding": _existingKccOutstanding.text.trim(),
        "annual_agri_income": _agriIncomeAnnual.text.trim(),
        "other_income_annual": _otherIncome.text.trim(),
        "account_holder_name": _accHolderName.text.trim(),
        "bank_name": _bankName.text.trim(),
        "branch": _branch.text.trim(),
        "account_number": _accountNumber.text.trim(),
        "ifsc": _ifsc.text.trim().toUpperCase(),
        "reference1_name": _ref1Name.text.trim(),
        "reference1_phone": _ref1Phone.text.trim(),
        "reference2_name": _ref2Name.text.trim(),
        "reference2_phone": _ref2Phone.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.ok) {
      final extra = result.infoMessage.isNotEmpty ? ' ${result.infoMessage}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loan application submitted successfully.$extra')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage.isEmpty
                ? 'Failed (HTTP ${result.statusCode}).'
                : result.errorMessage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Kisan loan application',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        centerTitle: true,
      ),
      body: ResponsiveFormScroll(
        formKey: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fill what you know; only name, mobile, loan amount, and purpose are required here.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Applicant'),
              _loanFormField(
                controller: _applicantName,
                label: 'Full name (as on land records)',
                icon: Icons.person,
                validator: _req,
              ),
              _loanFormField(
                controller: _fatherName,
                label: "Father's / husband's name",
                icon: Icons.family_restroom,
                validator: (_) => null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _dob,
                      label: 'Date of birth (DD/MM/YYYY)',
                      icon: Icons.cake,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _mobile,
                      label: 'Mobile',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.length < 10) ? 'Valid mobile' : null,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _pan,
                label: 'PAN',
                icon: Icons.badge,
                validator: _panOptional,
              ),
              _loanFormField(
                controller: _aadhaar,
                label: 'Aadhaar (optional)',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: _aadhaarOptional,
              ),
              _buildSectionTitle('Address'),
              _loanFormField(
                controller: _village,
                label: 'Village / locality',
                icon: Icons.home,
                validator: (_) => null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _tehsil,
                      label: 'Tehsil / block',
                      icon: Icons.map,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _district,
                      label: 'District',
                      icon: Icons.location_city,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _state,
                      label: 'State',
                      icon: Icons.flag,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _pincode,
                      label: 'PIN code',
                      icon: Icons.pin,
                      keyboardType: TextInputType.number,
                      validator: _optPin6,
                    ),
                  ),
                ],
              ),
              _buildSectionTitle('Land & cultivation'),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _landSizeController,
                      label: 'Total land holding (acres)',
                      icon: Icons.landscape,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _ownershipType,
                      label: 'Ownership (Own / Lease / Share)',
                      icon: Icons.how_to_reg,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _khasraController,
                label: 'Khasra / plot numbers (as on record)',
                icon: Icons.grid_on,
                validator: (_) => null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _khataNumber,
                      label: 'Khata number',
                      icon: Icons.numbers,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _surveyNumber,
                      label: 'Survey number',
                      icon: Icons.explore,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _irrigatedArea,
                      label: 'Irrigated area (acres)',
                      icon: Icons.water,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _unirrigatedArea,
                      label: 'Rainfed area (acres)',
                      icon: Icons.wb_sunny,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _loanFormField(
                controller: _mainCrops,
                label: 'Main crops (last & current season)',
                icon: Icons.grass,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _irrigationSource,
                label: 'Irrigation source (canal / borewell / drip / rainfed)',
                icon: Icons.opacity,
                validator: (_) => null,
              ),
              _buildSectionTitle('Loan details'),
              _loanFormField(
                controller: _amountController,
                label: 'Amount required (₹)',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: _requiredDecimal,
              ),
              _loanFormField(
                controller: _loanPurpose,
                label: 'Purpose (KCC crop / term loan / dairy / farm equipment)',
                icon: Icons.request_quote,
                maxLines: 2,
                validator: _req,
              ),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _tenureMonths,
                      label: 'Tenure (months)',
                      icon: Icons.calendar_month,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _existingKccOutstanding,
                      label: 'Existing KCC / loan outstanding (₹) — or 0',
                      icon: Icons.account_balance,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _buildSectionTitle('Income'),
              Row(
                children: [
                  Expanded(
                    child: _loanFormField(
                      controller: _agriIncomeAnnual,
                      label: 'Annual farm income (₹, estimate)',
                      icon: Icons.trending_up,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _loanFormField(
                      controller: _otherIncome,
                      label: 'Other annual income (₹)',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              _buildSectionTitle('Bank account'),
              _loanFormField(
                controller: _accHolderName,
                label: 'Account holder name',
                icon: Icons.person_outline,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _bankName,
                label: 'Bank name',
                icon: Icons.account_balance,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _branch,
                label: 'Branch',
                icon: Icons.store_mall_directory,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _accountNumber,
                label: 'Account number',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _ifsc,
                label: 'IFSC',
                icon: Icons.alt_route,
                validator: _ifscOptional,
              ),
              _buildSectionTitle('References'),
              _loanFormField(
                controller: _ref1Name,
                label: 'Reference 1 — name',
                icon: Icons.contact_page,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _ref1Phone,
                label: 'Reference 1 — mobile',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: _optPhone,
              ),
              _loanFormField(
                controller: _ref2Name,
                label: 'Reference 2 — name',
                icon: Icons.contact_page_outlined,
                validator: (_) => null,
              ),
              _loanFormField(
                controller: _ref2Phone,
                label: 'Reference 2 — mobile',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: _optPhone,
              ),
              CheckboxListTile(
                value: _declarationAccepted,
                onChanged: (v) => setState(() => _declarationAccepted = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I declare land and income details are true to the best of my knowledge.',
                  style: TextStyle(fontSize: 13, height: 1.35),
                ),
              ),
              const SizedBox(height: 16),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _applyForLoan,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF2196F3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFF2196F3).withOpacity(0.5),
                        ),
                        child: const Text(
                          'SUBMIT APPLICATION',
                          style: TextStyle(
                            fontSize: 16,
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
}

class BimaYojanaScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const BimaYojanaScreen({super.key, required this.userData});

  @override
  State<BimaYojanaScreen> createState() => _BimaYojanaScreenState();
}

class _BimaYojanaScreenState extends State<BimaYojanaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal
  final _farmerName = TextEditingController();
  final _fatherName = TextEditingController();
  final _mobile = TextEditingController();
  final _aadhaar = TextEditingController();

  // Location
  final _village = TextEditingController();
  final _tehsil = TextEditingController();
  final _district = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();

  // Land
  final _landSize = TextEditingController();
  final _khasraNumber = TextEditingController();
  final _surveyNumber = TextEditingController();

  // Crop
  final _cropName = TextEditingController();
  String _season = 'Kharif';
  final _sowingDate = TextEditingController();
  final _expectedHarvest = TextEditingController();

  // Insurance
  final _sumInsured = TextEditingController();
  final _premiumAmount = TextEditingController();

  // Bank
  final _bankName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _ifsc = TextEditingController();

  bool _declarationAccepted = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.userData;
    _farmerName.text = (u['name'] ?? '').toString();
    _mobile.text = (u['mobile'] ?? '').toString();
    _district.text = (u['district'] ?? u['city'] ?? '').toString();
    _state.text = (u['state'] ?? '').toString();
    _pincode.text = (u['pincode'] ?? '').toString();
  }

  @override
  void dispose() {
    _farmerName.dispose(); _fatherName.dispose(); _mobile.dispose();
    _aadhaar.dispose(); _village.dispose(); _tehsil.dispose();
    _district.dispose(); _state.dispose(); _pincode.dispose();
    _landSize.dispose(); _khasraNumber.dispose(); _surveyNumber.dispose();
    _cropName.dispose(); _sowingDate.dispose(); _expectedHarvest.dispose();
    _sumInsured.dispose(); _premiumAmount.dispose();
    _bankName.dispose(); _accountNumber.dispose(); _ifsc.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final y = picked.year;
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      ctrl.text = '$y-$m-$d';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the declaration to proceed')),
      );
      return;
    }
    setState(() => _isSaving = true);

    final payload = {
      'type': 'farmer_insurance',
      'user_id': widget.userData['id']?.toString() ?? '0',
      'data': {
        'farmer_name': _farmerName.text.trim(),
        'father_name': _fatherName.text.trim(),
        'mobile': _mobile.text.trim(),
        'aadhaar': _aadhaar.text.trim(),
        'village': _village.text.trim(),
        'tehsil': _tehsil.text.trim(),
        'district': _district.text.trim(),
        'state': _state.text.trim(),
        'pincode': _pincode.text.trim(),
        'land_size': _landSize.text.trim(),
        'khasra_number': _khasraNumber.text.trim(),
        'survey_number': _surveyNumber.text.trim(),
        'crop_name': _cropName.text.trim(),
        'season': _season,
        'sowing_date': _sowingDate.text.trim(),
        'expected_harvest': _expectedHarvest.text.trim(),
        'sum_insured': double.tryParse(_sumInsured.text.trim()) ?? 0,
        'premium_amount': double.tryParse(_premiumAmount.text.trim()) ?? 0,
        'bank_name': _bankName.text.trim(),
        'account_number': _accountNumber.text.trim(),
        'ifsc': _ifsc.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);
    setState(() => _isSaving = false);

    if (!mounted) return;
    if (result.ok) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 10),
            const Text('Application Submitted!'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your PMFBY Crop Insurance application has been submitted successfully.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Farmer: ${_farmerName.text}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Crop: ${_cropName.text} (${_season})'),
                    Text('Sum Insured: ₹${_sumInsured.text}'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('You will be notified once reviewed.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // form screen
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${result.errorMessage.isEmpty ? 'Submission failed' : result.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF5),
      appBar: AppBar(
        title: const Text('PMFBY — Crop Insurance'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ResponsiveScrollBody(
          children: [
            // Hero Banner
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.white, size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pradhan Mantri Fasal Bima Yojana',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Protect your crops against natural calamities',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Section 1: Personal Details ---
            _buildSectionTitle('Personal Details'),
            _loanFormField(controller: _farmerName, label: 'Farmer Full Name', icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            _loanFormField(controller: _fatherName, label: "Father's / Husband's Name", icon: Icons.people),
            _loanFormField(controller: _mobile, label: 'Mobile Number', icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            _loanFormField(controller: _aadhaar, label: 'Aadhaar Number', icon: Icons.credit_card,
                keyboardType: TextInputType.number),

            // --- Section 2: Location ---
            _buildSectionTitle('Location Details'),
            _loanFormField(controller: _village, label: 'Village / Gram Panchayat', icon: Icons.location_on),
            _loanFormField(controller: _tehsil, label: 'Tehsil / Block', icon: Icons.map),
            _loanFormField(controller: _district, label: 'District', icon: Icons.location_city,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            _loanFormField(controller: _state, label: 'State', icon: Icons.flag),
            _loanFormField(controller: _pincode, label: 'Pincode', icon: Icons.pin,
                keyboardType: TextInputType.number),

            // --- Section 3: Land Details ---
            _buildSectionTitle('Land Details'),
            _loanFormField(controller: _landSize, label: 'Land Size (in Acres)', icon: Icons.crop_square,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            _loanFormField(controller: _khasraNumber, label: 'Khasra / Gata Number', icon: Icons.tag),
            _loanFormField(controller: _surveyNumber, label: 'Survey Number', icon: Icons.article),

            // --- Section 4: Crop Details ---
            _buildSectionTitle('Crop Details'),
            _loanFormField(controller: _cropName, label: 'Crop Name', icon: Icons.grass,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            // Season dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: _season,
                decoration: _inputStyle(context, 'Crop Season', Icons.wb_sunny),
                items: ['Kharif', 'Rabi', 'Zaid']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _season = v ?? 'Kharif'),
              ),
            ),
            // Sowing date
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _sowingDate,
                readOnly: true,
                onTap: () => _pickDate(_sowingDate),
                decoration: _inputStyle(context, 'Sowing Date', Icons.calendar_today),
              ),
            ),
            // Expected harvest date
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _expectedHarvest,
                readOnly: true,
                onTap: () => _pickDate(_expectedHarvest),
                decoration: _inputStyle(context, 'Expected Harvest Date', Icons.event_available),
              ),
            ),

            // --- Section 5: Insurance ---
            _buildSectionTitle('Insurance Details'),
            _loanFormField(controller: _sumInsured, label: 'Sum Insured (₹)', icon: Icons.monetization_on,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            _loanFormField(controller: _premiumAmount, label: 'Premium Amount (₹)', icon: Icons.receipt_long,
                keyboardType: TextInputType.number),

            // --- Section 6: Bank Details ---
            _buildSectionTitle('Bank Details'),
            _loanFormField(controller: _bankName, label: 'Bank Name', icon: Icons.account_balance),
            _loanFormField(controller: _accountNumber, label: 'Account Number', icon: Icons.numbers,
                keyboardType: TextInputType.number),
            _loanFormField(controller: _ifsc, label: 'IFSC Code', icon: Icons.qr_code),

            const SizedBox(height: 16),

            // Declaration
            CheckboxListTile(
              value: _declarationAccepted,
              onChanged: (v) => setState(() => _declarationAccepted = v ?? false),
              title: const Text(
                'I hereby declare that all information provided is correct and I am eligible for PM Fasal Bima Yojana.',
                style: TextStyle(fontSize: 13),
              ),
              activeColor: Colors.green.shade700,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(_isSaving ? 'Submitting...' : 'Submit Application'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}


class SubsidyScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const SubsidyScreen({super.key, required this.userData});

  @override
  State<SubsidyScreen> createState() => _SubsidyScreenState();
}

class _SubsidyScreenState extends State<SubsidyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal
  final _applicantName = TextEditingController();
  final _fatherName = TextEditingController();
  final _mobile = TextEditingController();
  final _aadhaar = TextEditingController();

  // Location
  final _village = TextEditingController();
  final _tehsil = TextEditingController();
  final _district = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();

  // Subsidy
  String _subsidyType = 'Fertilizer Subsidy';
  final _schemeName = TextEditingController();
  final _purpose = TextEditingController();

  // Land
  final _landSize = TextEditingController();
  final _khasraNumber = TextEditingController();

  // Bank
  final _bankName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _ifsc = TextEditingController();

  bool _declarationAccepted = false;
  bool _isSaving = false;

  static const _subsidyTypes = [
    'Fertilizer Subsidy',
    'Solar Pump Scheme (PM-KUSUM)',
    'Seed Subsidy',
    'Irrigation Equipment',
    'Tractor / Farm Equipment',
    'Drip / Sprinkler Irrigation',
    'Other Government Scheme',
  ];

  static const _schemeMap = {
    'Fertilizer Subsidy': 'Direct Benefit Transfer (DBT)',
    'Solar Pump Scheme (PM-KUSUM)': 'PM-KUSUM',
    'Seed Subsidy': 'Kharif / Rabi Seed Scheme',
    'Irrigation Equipment': 'PMKSY',
    'Tractor / Farm Equipment': 'Farm Mechanization Scheme',
    'Drip / Sprinkler Irrigation': 'Per Drop More Crop',
    'Other Government Scheme': '',
  };

  @override
  void initState() {
    super.initState();
    final u = widget.userData;
    _applicantName.text = (u['name'] ?? '').toString();
    _mobile.text = (u['mobile'] ?? '').toString();
    _district.text = (u['district'] ?? u['city'] ?? '').toString();
    _state.text = (u['state'] ?? '').toString();
    _pincode.text = (u['pincode'] ?? '').toString();
    _schemeName.text = _schemeMap[_subsidyType] ?? '';
  }

  @override
  void dispose() {
    _applicantName.dispose(); _fatherName.dispose(); _mobile.dispose();
    _aadhaar.dispose(); _village.dispose(); _tehsil.dispose();
    _district.dispose(); _state.dispose(); _pincode.dispose();
    _schemeName.dispose(); _purpose.dispose();
    _landSize.dispose(); _khasraNumber.dispose();
    _bankName.dispose(); _accountNumber.dispose(); _ifsc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the declaration to proceed')),
      );
      return;
    }
    setState(() => _isSaving = true);

    final payload = {
      'type': 'subsidy_application',
      'user_id': widget.userData['id']?.toString() ?? '0',
      'data': {
        'applicant_name': _applicantName.text.trim(),
        'father_name': _fatherName.text.trim(),
        'mobile': _mobile.text.trim(),
        'aadhaar': _aadhaar.text.trim(),
        'village': _village.text.trim(),
        'tehsil': _tehsil.text.trim(),
        'district': _district.text.trim(),
        'state': _state.text.trim(),
        'pincode': _pincode.text.trim(),
        'subsidy_type': _subsidyType,
        'scheme_name': _schemeName.text.trim(),
        'purpose': _purpose.text.trim(),
        'land_size': _landSize.text.trim(),
        'khasra_number': _khasraNumber.text.trim(),
        'bank_name': _bankName.text.trim(),
        'account_number': _accountNumber.text.trim(),
        'ifsc': _ifsc.text.trim(),
      },
    };

    final result = await ServiceController().submitData(payload);
    setState(() => _isSaving = false);

    if (!mounted) return;

    if (result.ok) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            const Icon(Icons.check_circle, color: Colors.orange, size: 32),
            const SizedBox(width: 10),
            const Text('Application Submitted!'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your subsidy application has been submitted successfully.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Applicant: ${_applicantName.text}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Subsidy: $_subsidyType'),
                    Text('Scheme: ${_schemeName.text}'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('You will be notified once reviewed.',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${result.errorMessage.isEmpty ? 'Submission failed' : result.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      appBar: AppBar(
        title: const Text('Government Subsidy Application'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ResponsiveScrollBody(
          children: [
            // Hero Banner
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFFFFAB40)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.white, size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Government Subsidy Scheme',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Apply for fertilizer, solar pump, seed & more benefits',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Section 1: Subsidy Type ---
            _buildSectionTitle('Subsidy Details'),
            // Subsidy type dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: _subsidyType,
                decoration: _inputStyle(context, 'Subsidy Type', Icons.category),
                isExpanded: true,
                items: _subsidyTypes
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _subsidyType = v ?? _subsidyTypes.first;
                    _schemeName.text = _schemeMap[_subsidyType] ?? '';
                  });
                },
                validator: (v) => v == null || v.isEmpty ? 'Please select subsidy type' : null,
              ),
            ),
            _loanFormField(
              controller: _schemeName,
              label: 'Scheme / Programme Name',
              icon: Icons.assignment,
            ),
            _loanFormField(
              controller: _purpose,
              label: 'Purpose / Reason for Application',
              icon: Icons.description,
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),

            // --- Section 2: Personal Details ---
            _buildSectionTitle('Personal Details'),
            _loanFormField(controller: _applicantName, label: 'Applicant Full Name', icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            _loanFormField(controller: _fatherName, label: "Father's / Husband's Name", icon: Icons.people),
            _loanFormField(controller: _mobile, label: 'Mobile Number', icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            _loanFormField(controller: _aadhaar, label: 'Aadhaar Number', icon: Icons.credit_card,
                keyboardType: TextInputType.number),

            // --- Section 3: Location ---
            _buildSectionTitle('Location Details'),
            _loanFormField(controller: _village, label: 'Village / Gram Panchayat', icon: Icons.location_on),
            _loanFormField(controller: _tehsil, label: 'Tehsil / Block', icon: Icons.map),
            _loanFormField(controller: _district, label: 'District', icon: Icons.location_city,
                validator: (v) => v!.isEmpty ? 'Required' : null),
            _loanFormField(controller: _state, label: 'State', icon: Icons.flag),
            _loanFormField(controller: _pincode, label: 'Pincode', icon: Icons.pin,
                keyboardType: TextInputType.number),

            // --- Section 4: Land Details ---
            _buildSectionTitle('Land Details'),
            _loanFormField(controller: _landSize, label: 'Land Size (in Acres)', icon: Icons.crop_square,
                keyboardType: TextInputType.number),
            _loanFormField(controller: _khasraNumber, label: 'Khasra / Gata Number', icon: Icons.tag),

            // --- Section 5: Bank Details ---
            _buildSectionTitle('Bank Details'),
            _loanFormField(controller: _bankName, label: 'Bank Name', icon: Icons.account_balance),
            _loanFormField(controller: _accountNumber, label: 'Account Number', icon: Icons.numbers,
                keyboardType: TextInputType.number),
            _loanFormField(controller: _ifsc, label: 'IFSC Code', icon: Icons.qr_code),

            const SizedBox(height: 16),

            // Declaration
            CheckboxListTile(
              value: _declarationAccepted,
              onChanged: (v) => setState(() => _declarationAccepted = v ?? false),
              title: const Text(
                'I hereby declare that all information provided is correct and I am eligible for the selected government subsidy scheme.',
                style: TextStyle(fontSize: 13),
              ),
              activeColor: const Color(0xFF2196F3),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(_isSaving ? 'Submitting...' : 'Submit Application'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}


// --- 4. BANK SERVICES ---

class AllLeadsScreen extends StatefulWidget {
  final int currentBankUserId;
  final LeadCategory category;
  final String? filterType;

  const AllLeadsScreen({
    super.key,
    required this.currentBankUserId,
    required this.category,
    this.filterType,
  });

  @override
  State<AllLeadsScreen> createState() => _AllLeadsScreenState();
}

class _AllLeadsScreenState extends State<AllLeadsScreen> {
  final LeadController _leadController = LeadController();
  int? _overrideId; // For debugging

  Key _refreshKey = UniqueKey(); // Used to force refresh the list

  void _handleClaim(int id, String tableName) async {
    final int effectiveId = _overrideId ?? widget.currentBankUserId;
    bool success = await _leadController.updateLeadStatus(id, "Approved", effectiveId, tableName);

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
    final category = widget.category;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filterType ?? category.title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          if (widget.filterType != null)
            TextButton.icon(
              onPressed: () {
                Widget formScreen;
                final mockUserData = {
                  "id": widget.currentBankUserId.toString(),
                  "name": "Bank Tester",
                  "mobile": "9999999999",
                  "email": "banktest@gmail.com",
                  "category": "Business",
                };
                switch (widget.filterType) {
                  case 'Online Banking':
                    formScreen = OnlineBankingScreen(userData: mockUserData);
                    break;
                  case 'UPI Payments':
                    formScreen = UpiPaymentScreen(userData: mockUserData);
                    break;
                  case 'Direct Benefit Transfer':
                    formScreen = DirectBenefitTransferScreen(userData: mockUserData);
                    break;
                  case 'Jan Dhan Account':
                    formScreen = JanDhanYojnaScreen(userData: mockUserData);
                    break;
                  default:
                    return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => formScreen),
                ).then((_) {
                  setState(() => _refreshKey = UniqueKey());
                });
              },
              icon: const Icon(Icons.add, color: Colors.blue),
              label: const Text("Open Form", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _refreshKey = UniqueKey()),
          )
        ],
      ),
      body: FutureBuilder<List<LeadModel>>(
        key: _refreshKey,
        future: _leadController.fetchLeads(effectiveId, category: category),
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
          if (widget.filterType != null) {
            leads = leads.where((lead) => lead.loanType == widget.filterType).toList();
          }

          final String debugInfo =
              "User ID: $effectiveId\nCategory: ${category.title}\n"
              "Table: ${category.tableName}\n"
              "URL: ${LeadController.baseUrl}/leads?bank_user_id=$effectiveId"
              "&type=${Uri.encodeComponent(category.apiType)}"
              "&table=${Uri.encodeComponent(category.tableName)}";
          debugPrint(debugInfo);

          if (leads.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                        child: const Text("Switch to Test ID (1)", style: TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.horizontalPadding(context)),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: leads.map((lead) {
                    return InkWell(
                      onTap: () => _showLeadDetail(lead),
                      child: _leadItem(lead),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLeadDetail(LeadModel lead) {
    ResponsiveDialog.show(
      context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(lead.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 16),
              _detailRow(Icons.category, "Loan Type", lead.loanType),
              const Divider(),
              _detailRow(Icons.currency_rupee, "Requested Amount", lead.amount),
              const Divider(),
              _detailRow(Icons.phone, "Mobile Number", lead.mobile),
              if (lead.extraData.isNotEmpty) ...[
                const Divider(),
                ...lead.extraData.entries.map((e) {
                  final String val = e.value?.toString() ?? 'N/A';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _detailRow(Icons.label_important_outline, e.key, val),
                  );
                }).toList(),
              ],
              const Divider(),
              _detailRow(Icons.info_outline, "Status", lead.status.toUpperCase()),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close", style: TextStyle(color: Colors.grey)),
                  ),
                  if (lead.status.toLowerCase() == "pending") ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleClaim(lead.id, lead.tableName);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                      child: const Text("Approve & Claim", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _leadItem(LeadModel lead) {
    final effectiveId = _overrideId ?? widget.currentBankUserId;
    // Claimed by THIS bank user
    final bool claimedByMe = lead.claimedBy != null && lead.claimedBy == effectiveId;
    // Claimed by ANY bank (status is approved/claimed OR claimedBy is a valid bank ID > 0)
    final bool isClaimed = lead.status.toLowerCase() == "approved" ||
        lead.status.toLowerCase() == "claimed" ||
        (lead.claimedBy != null && lead.claimedBy! > 0);

    String displayType = lead.loanType;
    if (displayType == "Business Loan") displayType = "Business";
    if (displayType == "Education Loan") displayType = "Student";
    if (displayType == "Farmer Loan") displayType = "Farmer";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Name + Amount
            Row(
              children: [
                Expanded(
                  child: Text(
                    lead.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${lead.amount}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3), fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: Category + Phone
            Row(
              children: [
                Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(displayType, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    lead.mobile,
                    style: TextStyle(color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row 3: Status badge + CLAIM button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: !isClaimed
                        ? Colors.orange.shade50
                        : claimedByMe
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isClaimed && !claimedByMe)
                        Icon(Icons.lock, size: 11, color: Colors.red.shade700),
                      if (isClaimed && !claimedByMe)
                        const SizedBox(width: 4),
                      Text(
                        !isClaimed
                            ? lead.status.toUpperCase()
                            : claimedByMe
                                ? "✓ CLAIMED BY YOU"
                                : "ALREADY CLAIMED",
                        style: TextStyle(
                          fontSize: 11,
                          color: !isClaimed
                              ? Colors.orange.shade700
                              : claimedByMe
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Custom action button (avoids Material 3 theme conflicts)
                GestureDetector(
                  onTap: isClaimed ? null : () => _handleClaim(lead.id, lead.tableName),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isClaimed
                          ? (claimedByMe ? Colors.green.shade200 : Colors.grey.shade300)
                          : const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isClaimed
                          ? (claimedByMe ? "CLAIMED" : "TAKEN")
                          : "CLAIM",
                      style: TextStyle(
                        color: isClaimed
                            ? (claimedByMe ? Colors.green.shade900 : Colors.grey.shade600)
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class AcceptedLeadsScreen extends StatefulWidget {
  final int currentBankUserId;
  final LeadCategory? category;

  const AcceptedLeadsScreen({
    super.key,
    required this.currentBankUserId,
    this.category,
  });

  @override
  State<AcceptedLeadsScreen> createState() => _AcceptedLeadsScreenState();
}

class _AcceptedLeadsScreenState extends State<AcceptedLeadsScreen> {
  final LeadController _leadController = LeadController();

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final title = category == null
        ? 'My Approved Loans'
        : 'Approved ${category.title}';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<LeadModel>>(
        future: _leadController.fetchMyLeads(
          widget.currentBankUserId,
          category: category,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final leads = snapshot.data ?? [];

          if (leads.isEmpty) {
            return const Center(child: Text("You haven't approved any loans yet."));
          }

          return ResponsiveListView(
            maxWidth: 720,
            itemCount: leads.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified, color: Colors.green),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(leads[index].name, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(leads[index].mobile),
                          Text(leads[index].loanType, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      leads[index].amount,
                      style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late Future<List<dynamic>> _cropsFuture;

  @override
  void initState() {
    super.initState();
    _cropsFuture = ServiceController().fetchMarketCrops();
  }

  void _showCropDetails(Map<String, dynamic> crop) {
    Map<String, dynamic> details = {};
    final d = crop['details'];
    if (d is Map) {
      details = Map<String, dynamic>.from(d);
    } else if (d is String) {
      try {
        details = jsonDecode(d);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            Widget infoRow(String label, String? val) {
              if (val == null || val.trim().isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(val, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(crop['crop_name'] ?? 'Crop', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Price/Quintal: ${crop['price'] ?? 'N/A'}', style: const TextStyle(color: Color(0xFF2196F3), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text("Farmer Contact", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(backgroundColor: Color(0xFF2196F3), child: Icon(Icons.person, color: Colors.white)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(crop['farmer_name'] ?? 'Farmer', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(crop['farmer_mobile'] ?? 'N/A', style: TextStyle(color: Colors.grey.shade600)),
                          Text(crop['farmer_city'] ?? 'Location N/A', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text("Crop Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (details.isEmpty)
                    const Text("No additional details were provided.")
                  else ...[
                    infoRow("Quantity Available", details['quantity']),
                    infoRow("Crop Quality", details['quality']),
                    infoRow("Variety", details['variety']),
                    infoRow("Harvest Date", details['harvest_date']),
                    infoRow("Farming Methods", details['farming_methods']),
                    infoRow("Certifications", details['certifications']),
                    infoRow("Pickup Location", details['pickup_location']),
                    if ((details['additional_notes']?.toString() ?? '').isNotEmpty)
                      infoRow("Additional Notes", details['additional_notes']),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Crop Market", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _cropsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          final crops = snapshot.data ?? [];
          if (crops.isEmpty) return const Center(child: Text("No crops available in the market right now."));
          
          return ResponsiveContent(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.gridColumns(context, maxColumns: 4),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: Responsive.isDesktop(context) ? 0.85 : 0.75,
              ),
              itemCount: crops.length,
              itemBuilder: (context, index) {
                final crop = crops[index];
                return InkWell(
                  onTap: () => _showCropDetails(crop),
                  child: Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            color: const Color(0xFFE8F5E9),
                            child: const Center(
                              child: Icon(Icons.grass, size: 50, color: Colors.green),
                            ),
                          ),
                        ),
                        Container(
                          color: Theme.of(context).cardColor,
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crop['crop_name']?.toString() ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${crop['price']?.toString() ?? 'N/A'} / Qtl',
                                style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                crop['farmer_name']?.toString() ?? 'Farmer',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}