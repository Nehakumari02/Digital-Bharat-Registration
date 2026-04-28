import 'package:flutter/material.dart';
import '../controllers/registration_controller.dart';
import '../widgets/custom_text_field.dart';
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
  String? _selectedCategory;
  final List<String> _categories = ['Student', 'Business', 'Bank', 'Farmers'];

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

  // This is the missing tool that Flutter is looking for
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Create Account",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Branding / Progress
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF26522).withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFF26522),
                    child: Icon(Icons.person_add_alt_1, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Step 1 of 2",
                    style: TextStyle(
                      color: Color(0xFFF26522),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Basic Information",
                    style: TextStyle(
                      color: Colors.black54,
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
                    const Text(
                      "Personal Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
                    const Text(
                      "Address & Category",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
                        prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFFF26522), size: 20),
                        filled: true,
                        fillColor: Colors.grey.shade50,
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
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      validator: (v) => v == null ? "Select Category" : null,
                    ),
                    
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryDetailsScreen(
                                  name: _nameController.text,
                                  mobile: _mobileController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  category: _selectedCategory!,
                                  pincode: _pincodeController.text,
                                  district: _districtController.text,
                                  city: _selectedCity == 'Other' ? _cityController.text : _selectedCity!,
                                  state: _selectedState!,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF26522),
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
    );
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFF26522), size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
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
        borderSide: const BorderSide(color: Color(0xFFF26522), width: 1.5),
      ),
    );
  }
}
