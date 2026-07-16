import 'package:flutter/material.dart';
import '../constants/registration_plan.dart';
import '../controllers/registration_controller.dart';
import '../models/partner_code_validation.dart';
import '../utils/partner_code_util.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/registration_plan_card.dart';
import '../widgets/responsive_layout.dart';
import 'category_details_screen.dart';
import '../data/india_data.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // New Address controllers
  final _pincodeController = TextEditingController();
  final _cityController = TextEditingController(); // Used for manual 'Other' city
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();

  final RegistrationController _controller = RegistrationController();
  String _registrationType = RegistrationPlan.typeNormal;
  final _partnerCodeController = TextEditingController();
  final _partnerMobileController = TextEditingController();
  PartnerCodeValidation? _partnerValidation;
  bool _validatingPartnerCode = false;

  String? _selectedCategory;
  String? _selectedAgentSubCategory;
  final List<String> _categories = ['Student', 'Business', 'Banking / Financial Services', 'Farmers', 'Job Seeker', 'Agent'];
  final List<String> _agentSubCategories = [
    'Real Estate',
    'Insurance',
    'Travel Agent',
    'Digital Services',
    'CA / Document Agent',
    'Institute/College'
  ];
  String? _selectedBusinessSubCategory;
  final List<String> _businessSubCategories = [
    'Solo Proprietor',
    'Partnership',
    'Private Limited',
    'LLP',
    'Other'
  ];
  String? _selectedStudentSubCategory;
  final List<String> _studentSubCategories = [
    'School',
    'High School',
    'Under Graduate',
    'Post Graduate',
    'Diploma'
  ];
  String? _selectedJobSeekerSubCategory;
  final List<String> _jobSeekerSubCategories = [
    'Jobs',
    'Internship'
  ];

  String? _selectedState;
  String? _selectedCity;

  final Map<String, List<String>> _stateCityData = indiaStateCityData;

  // void _submitData() async {
  //   if (_formKey.currentState!.validate()) {
  //
  //
  //     // Create the model object
  //     final newUser = RegistrationModel(
  //       name: _nameController.text,
  //       mobile: _mobileController.text,
  //       category: _selectedCategory!,
  //       pincode: _pincodeController.text,     // Add this
  //       district: _districtController.text,   // Add this
  //       city: _cityController.text,           // Add this
  //       state: _stateController.text,         // Add this
  //
  //     );
  //
  //     try {
  //       // Send data through the controller
  //       final response = await _controller.registerUser(newUser);
  //
  //       if (response.statusCode == 201) {
  //         _showMessage("Success! Registered in MySQL.", Colors.green);
  //         _formKey.currentState!.reset();
  //         _nameController.clear();
  //         _mobileController.clear();
  //         // Move to Login Screen
  //         if (mounted) {
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(builder: (context) => const LoginScreen()),
  //           );
  //         }
  //       } else {
  //         _showMessage("Error: ${response.statusCode}", Colors.red);
  //       }
  //     } catch (e) {
  //       _showMessage("Could not connect to server.", Colors.red);
  //     } finally {
  //
  //     }
  //   }
  // }

  @override
  void dispose() {
    _partnerCodeController.dispose();
    _partnerMobileController.dispose();
    super.dispose();
  }

  Future<void> _validatePartnerCode() async {
    final code = PartnerCodeUtil.normalizeInput(_partnerCodeController.text);
    if (code == null) {
      setState(() => _partnerValidation = PartnerCodeValidation.invalid('Enter a partner code'));
      return;
    }
    setState(() {
      _validatingPartnerCode = true;
      _partnerValidation = null;
    });
    final result = await _controller.validatePartnerCode(
      code,
      partnerMobile: _partnerMobileController.text,
    );
    if (mounted) {
      setState(() {
        _partnerValidation = result;
        _validatingPartnerCode = false;
      });
    }
  }

  bool _partnerCodeFormatOk() {
    final code = PartnerCodeUtil.normalizeInput(_partnerCodeController.text);
    if (code == null) return true;
    return PartnerCodeUtil.isWellFormed(code);
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Future<void> registerUser() async {
  //   // Use 10.0.2.2 for Android Emulator
  //   final url = Uri.parse('http://10.0.2.2:8000/api/register');
  //   print("Step 2: Sending to $url"); // ADD THIS LINE
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         "name": _nameController.text,
  //         "mobile": _mobileController.text,
  //         "category": _selectedCategory,
  //         "state": "Punjab", // Example: replace with your controller
  //         "city": "Chandigarh", // Example: replace with your controller
  //         // Add other fields here...
  //       }),
  //     );
  //     // --- PRINT THE RESPONSE HERE ---
  //     print("Status Code: ${response.statusCode}");
  //     print("Response Body: ${response.body}");
  //
  //     if (response.statusCode == 201) {
  //       print("Success! Check TablePlus now.");
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Account",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 0,
      ),
      body: ResponsiveBody(
        maxWidth: Responsive.isDesktop(context) ? 800 : 640,
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.horizontalPadding(context),
          vertical: Responsive.isDesktop(context) ? 32 : 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Top Branding / Progress
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF2196F3),
                    child: Icon(Icons.person_add_alt_1, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Step 1 of 2",
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Basic Information",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Personal Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? "Enter Name" : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => !v!.contains('@') ? "Enter a valid email" : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      prefixIcon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.length < 10 ? "Enter valid mobile" : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (v) => v!.length < 6 ? "Password must be 6+ characters" : null,
                    ),
                    
                    const SizedBox(height: 32),
                    Text(
                      "Registration plan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RegistrationPlanCard(
                      title: 'Normal',
                      subtitle: 'Standard access · optional partner code',
                      feeInr: RegistrationPlan.normalFeeInr,
                      selected: _registrationType == RegistrationPlan.typeNormal,
                      onTap: () => setState(() => _registrationType = RegistrationPlan.typeNormal),
                    ),
                    const SizedBox(height: 12),
                    RegistrationPlanCard(
                      title: 'Partner',
                      subtitle: 'Get your own referral code & wallet',
                      feeInr: RegistrationPlan.partnerFeeInr,
                      selected: _registrationType == RegistrationPlan.typePartner,
                      onTap: () => setState(() => _registrationType = RegistrationPlan.typePartner),
                      badge: 'PARTNER',
                    ),
                    if (_registrationType == RegistrationPlan.typeNormal) ...[
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _partnerCodeController,
                        label: 'Partner code (optional, e.g. PRT-ABC123)',
                        prefixIcon: Icons.card_giftcard_outlined,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (_) => setState(() => _partnerValidation = null),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _partnerMobileController,
                        label: 'Partner mobile (optional, helps verify)',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => setState(() => _partnerValidation = null),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Partner earns ${(RegistrationPlan.referralCashbackRate * 100).toInt()}% (₹${RegistrationPlan.cashbackForNormalRegistration().toStringAsFixed(0)}) in wallet',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ),
                          TextButton(
                            onPressed: _validatingPartnerCode ? null : _validatePartnerCode,
                            child: _validatingPartnerCode
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Verify'),
                          ),
                        ],
                      ),
                      if (_partnerValidation != null)
                        Text(
                          _partnerValidation!.valid
                              ? (_partnerValidation!.partnerName != null
                                  ? 'Valid — ${_partnerValidation!.partnerName}'
                                  : (_partnerValidation!.message ?? 'Valid partner code'))
                              : (_partnerValidation!.message ?? 'Invalid code'),
                          style: TextStyle(
                            fontSize: 12,
                            color: _partnerValidation!.valid ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                    ],
                    const SizedBox(height: 32),
                    Text(
                      "Address & Category",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _pincodeController,
                      label: 'Pincode',
                      prefixIcon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.length != 6 ? "Enter 6-digit pincode" : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _districtController,
                      label: 'District',
                      prefixIcon: Icons.location_city_outlined,
                      validator: (v) => v!.isEmpty ? "Enter District" : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _selectedState,
                            decoration: _dropdownDecoration('State', Icons.map_outlined),
                            items: _stateCityData.keys.map((String state) {
                              return DropdownMenuItem(
                                value: state, 
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(state, style: const TextStyle(fontSize: 13))
                                )
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedState = value;
                                _selectedCity = null;
                              });
                            },
                            validator: (v) => v == null ? "Select State" : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _selectedCity,
                            decoration: _dropdownDecoration('City', Icons.location_city_outlined),
                            disabledHint: const Text("Select State"),
                            items: _selectedState == null 
                              ? [] 
                              : [..._stateCityData[_selectedState]!, 'Other'].map((String city) {
                                  return DropdownMenuItem(
                                    value: city, 
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(city, style: const TextStyle(fontSize: 13))
                                    )
                                  );
                                }).toList(),
                            onChanged: (value) => setState(() => _selectedCity = value),
                            validator: (v) => v == null ? "Select City" : null,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedCity == 'Other') ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _cityController,
                        label: 'Enter City Name',
                        prefixIcon: Icons.edit_location_alt_outlined,
                        validator: (v) => v!.isEmpty ? "Enter City Name" : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF2196F3), size: 20),
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          if (value != 'Agent') {
                            _selectedAgentSubCategory = null;
                          }
                          if (value != 'Business') {
                            _selectedBusinessSubCategory = null;
                          }
                        });
                      },
                      validator: (v) => v == null ? "Select Category" : null,
                    ),
                    if (_selectedCategory == 'Agent') const SizedBox(height: 16),
                    if (_selectedCategory == 'Agent') DropdownButtonFormField<String>(
                        value: _selectedAgentSubCategory,
                        decoration: InputDecoration(
                          labelText: 'Agent Type',
                          prefixIcon: const Icon(Icons.support_agent, color: Color(0xFF2196F3), size: 20),
                          filled: true,
                          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        items: _agentSubCategories.map((String sub) {
                          return DropdownMenuItem(
                            value: sub,
                            child: Text(sub),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedAgentSubCategory = value),
                        validator: (v) => v == null ? "Select Agent Type" : null,
                      ),
                      
                    if (_selectedCategory == 'Business') const SizedBox(height: 16),
                    if (_selectedCategory == 'Business') DropdownButtonFormField<String>(
                        value: _selectedBusinessSubCategory,
                        decoration: InputDecoration(
                          labelText: 'Business Type',
                          prefixIcon: const Icon(Icons.business_center_outlined, color: Color(0xFF2196F3), size: 20),
                          filled: true,
                          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        items: _businessSubCategories.map((String sub) {
                          return DropdownMenuItem(
                            value: sub,
                            child: Text(sub),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedBusinessSubCategory = value),
                        validator: (v) => v == null ? "Select Business Type" : null,
                      ),

                    if (_selectedCategory == 'Student') const SizedBox(height: 16),
                    if (_selectedCategory == 'Student') DropdownButtonFormField<String>(
                        value: _selectedStudentSubCategory,
                        decoration: InputDecoration(
                          labelText: 'Education Level',
                          prefixIcon: const Icon(Icons.school_outlined, color: Color(0xFF2196F3), size: 20),
                          filled: true,
                          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        items: _studentSubCategories.map((String sub) {
                          return DropdownMenuItem(
                            value: sub,
                            child: Text(sub),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedStudentSubCategory = value),
                        validator: (v) => v == null ? "Select Education Level" : null,
                      ),

                    if (_selectedCategory == 'Job Seeker') const SizedBox(height: 16),
                    if (_selectedCategory == 'Job Seeker') DropdownButtonFormField<String>(
                        value: _selectedJobSeekerSubCategory,
                        decoration: InputDecoration(
                          labelText: 'Looking For',
                          prefixIcon: const Icon(Icons.work_outline, color: Color(0xFF2196F3), size: 20),
                          filled: true,
                          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        items: _jobSeekerSubCategories.map((String sub) {
                          return DropdownMenuItem(
                            value: sub,
                            child: Text(sub),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedJobSeekerSubCategory = value),
                        validator: (v) => v == null ? "Select what you are looking for" : null,
                      ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final code = PartnerCodeUtil.normalizeInput(_partnerCodeController.text);
                          if (_registrationType == RegistrationPlan.typeNormal &&
                              code != null &&
                              !_partnerCodeFormatOk()) {
                            _showMessage('Partner code must look like PRT-ABC123', Colors.red);
                            return;
                          }
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailsScreen(
                                name: _nameController.text,
                                mobile: _mobileController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                category: _selectedCategory == 'Agent'
                                    ? 'Agent - $_selectedAgentSubCategory'
                                    : _selectedCategory == 'Business'
                                        ? 'Business - $_selectedBusinessSubCategory'
                                        : _selectedCategory == 'Student'
                                            ? 'Student - $_selectedStudentSubCategory'
                                            : _selectedCategory == 'Job Seeker'
                                                ? 'Job Seeker - $_selectedJobSeekerSubCategory'
                                                : _selectedCategory!,
                                pincode: _pincodeController.text,
                                district: _districtController.text,
                                city: _selectedCity == 'Other' ? _cityController.text : _selectedCity!,
                                state: _selectedState!,
                                registrationType: _registrationType,
                                referredPartnerCode: _registrationType == RegistrationPlan.typeNormal
                                    ? code
                                    : null,
                                referredPartnerMobile:
                                    _registrationType == RegistrationPlan.typeNormal
                                        ? _partnerMobileController.text.trim()
                                        : null,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "CONTINUE",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2196F3), size: 20),
      filled: true,
      fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
      ),
    );
  }
}
