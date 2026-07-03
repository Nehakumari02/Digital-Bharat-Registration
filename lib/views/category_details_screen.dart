import 'package:flutter/material.dart';
import '../constants/registration_plan.dart';
import '../controllers/registration_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/responsive_layout.dart';
import 'registration_success_sheet.dart';


class CategoryDetailsScreen extends StatefulWidget {
  final String name;
  final String mobile;
  final String email;
  final String password;
  final String category;
  final String pincode;
  final String district;
  final String city;
  final String state;
  final String registrationType;
  final String? referredPartnerCode;
  final String? referredPartnerMobile;

  const CategoryDetailsScreen({
    super.key,
    required this.name,
    required this.mobile,
    required this.email,
    required this.password,
    required this.category,
    required this.pincode,
    required this.district,
    required this.city,
    required this.state,
    this.registrationType = RegistrationPlan.typeNormal,
    this.referredPartnerCode,
    this.referredPartnerMobile,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final _standardController = TextEditingController();
  final _collegeController = TextEditingController();
  final _gpaController = TextEditingController();

  final _rollNumberController = TextEditingController();
  final _streamController = TextEditingController();
  final _gradYearController = TextEditingController();
  final _skillsController = TextEditingController();

  final _companyNameController = TextEditingController();
  final _gstController = TextEditingController();
  final _turnoverController = TextEditingController();
  final _employeeCountController = TextEditingController();
  final _websiteController = TextEditingController();

  final _bankNameController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _branchController = TextEditingController();
  final _ifscController = TextEditingController();

  final _cropNameController = TextEditingController();
  final _cropPriceController = TextEditingController();
  final _landSizeController = TextEditingController();

  final _highestEducationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _preferredRoleController = TextEditingController();

  final RegistrationController _controller = RegistrationController();
  bool _paymentAcknowledged = false;
  bool _submitting = false;

  int get _registrationFee => RegistrationPlan.feeForType(widget.registrationType);

  bool get _isPartner => widget.registrationType == RegistrationPlan.typePartner;

  void _showMessage(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitData() async {
    if (!_paymentAcknowledged) {
      _showMessage('Please confirm the registration fee payment', Colors.orange);
      return;
    }

    Map<String, dynamic> profile = {
      "name": widget.name,
      "mobile": widget.mobile,
      "email": widget.email,
      "password": widget.password,
      "category": widget.category,
      "pincode": widget.pincode,
      "district": widget.district,
      "city": widget.city,
      "state": widget.state,
    };

    if (widget.category == 'Student') {
      profile.addAll({
        "college_name": _collegeController.text,
        "standard_year": _standardController.text,
        "stream": _streamController.text,
        "roll_number": _rollNumberController.text,
        "gpa": _gpaController.text,
        "graduation_year": _gradYearController.text,
        "skills": _skillsController.text,
      });
    } else if (widget.category == 'Business') {
      profile.addAll({
        "company_name": _companyNameController.text,
        "gst_number": _gstController.text,
        "turnover": _turnoverController.text,
        "employee_count": _employeeCountController.text,
        "business_website": _websiteController.text,
      });
    } else if (widget.category == 'Bank' || widget.category == 'Banking / Financial Services') {
      profile.addAll({
        "bank_name": _bankNameController.text,
        "interest_rate": _interestRateController.text,
        "branch_name": _branchController.text,
        "ifsc_code": _ifscController.text,
      });
    } else if (widget.category == 'Farmers') {
      profile.addAll({
        "crop_name": _cropNameController.text,
        "crop_price": _cropPriceController.text,
        "land_size": _landSizeController.text,
      });
    } else if (widget.category == 'Job Seeker') {
      profile.addAll({
        "highest_education": _highestEducationController.text,
        "years_of_experience": _experienceController.text,
        "preferred_job_role": _preferredRoleController.text,
      });
    }

    // Add common partner/payment fields
    profile.addAll({
      "registration_type": widget.registrationType,
      "is_partner": _isPartner ? 1 : 0,
      "registration_fee": _registrationFee,
      "referred_partner_code": widget.referredPartnerCode,
      "wallet_balance": 0,
    });

    if (widget.referredPartnerMobile != null &&
        widget.referredPartnerMobile!.trim().isNotEmpty) {
      profile['referred_partner_mobile'] = widget.referredPartnerMobile!.trim();
      profile['partner_mobile'] = widget.referredPartnerMobile!.trim();
    }

    final payload = RegistrationController.buildPayload(
      profile: profile,
      registrationType: widget.registrationType,
      referredPartnerCode: widget.referredPartnerCode,
      paymentAcknowledged: _paymentAcknowledged,
    );

    setState(() => _submitting = true);
    try {
      final result = await _controller.registerUser(payload);

      if (!mounted) return;

      if (result.success) {
        showRegistrationSuccessSheet(
          context,
          result: result,
          registrationType: widget.registrationType,
        );
      } else {
        _showMessage(result.message ?? 'Registration failed', Colors.red);
      }
    } catch (e) {
      _showMessage("Could not connect to server.", Colors.red);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.category} · Step 2")),
      body: ResponsiveScrollBody(
        maxWidth: 640,
        children: [
            _feeSummaryCard(),
            const SizedBox(height: 16),
            Text(
              "Complete your profile as a ${widget.category}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            if (widget.category == 'Student') ...[
              CustomTextField(controller: _collegeController, label: "College Name"),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(controller: _standardController, label: "Year/Semester"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _gradYearController,
                      label: "Graduation Year",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              CustomTextField(controller: _streamController, label: "Stream (e.g. B.Tech, B.Com)"),
              const SizedBox(height: 15),
              CustomTextField(controller: _rollNumberController, label: "Roll Number"),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _gpaController,
                label: "Current GPA",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _skillsController,
                label: "Skills (comma separated)",
              ),
            ],

            if (widget.category == 'Business') ...[
              CustomTextField(controller: _companyNameController, label: "Company Name"),
              const SizedBox(height: 15),
              CustomTextField(controller: _gstController, label: "GST Number"),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _turnoverController,
                label: "Annual Turnover (in Lakhs)",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _employeeCountController,
                label: "Number of Employees",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _websiteController,
                label: "Business Website (Optional)",
              ),
            ],

            if (widget.category == 'Bank' || widget.category == 'Banking / Financial Services') ...[
              CustomTextField(controller: _bankNameController, label: "Bank Name"),
              const SizedBox(height: 15),
              CustomTextField(
                  controller: _interestRateController,
                  label: "Interest Rate (%)",
                  keyboardType: TextInputType.number
              ),
              const SizedBox(height: 15),
              CustomTextField(controller: _branchController, label: "Branch Name"),
              const SizedBox(height: 15),
              CustomTextField(controller: _ifscController, label: "IFSC Code"),
            ],

            if (widget.category == 'Farmers') ...[
              CustomTextField(
                  controller: _cropNameController,
                  label: "Main Crop Name (e.g., Wheat, Rice)"
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _cropPriceController,
                label: "Expected Price (per Quintal/kg)",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _landSizeController,
                label: "Land Size (in Acres)",
                keyboardType: TextInputType.number,
              ),
            ],

            const SizedBox(height: 24),
            CheckboxListTile(
              value: _paymentAcknowledged,
              onChanged: (v) => setState(() => _paymentAcknowledged = v ?? false),
              activeColor: const Color(0xFF2196F3),
              title: Text(
                'I agree to pay ${RegistrationPlan.feeLabel(_registrationFee)} registration fee'
                '${_isPartner ? ' (Partner plan)' : ''}',
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            if (!_isPartner && widget.referredPartnerCode != null) ...[
              const SizedBox(height: 8),
              Text(
                'Partner code ${widget.referredPartnerCode} applied — partner earns '
                '₹${RegistrationPlan.cashbackForNormalRegistration().toStringAsFixed(0)} (10%) in wallet.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
            if (_isPartner) ...[
              const SizedBox(height: 8),
              Text(
                'After payment you will receive your unique partner code to share with referrals.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Pay ${RegistrationPlan.feeLabel(_registrationFee)} & Register'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _feeSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isPartner ? 'Partner registration' : 'Normal registration',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Fee: ${RegistrationPlan.feeLabel(_registrationFee)}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
          ),
          if (_isPartner)
            const Text(
              'Includes your partner code & referral wallet.',
              style: TextStyle(fontSize: 13),
            ),
        ],
      ),
    );
  }
}
