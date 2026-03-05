import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../controllers/registration_controller.dart';


// --- THIS IS THE CLASS YOU ARE MISSING ---
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

  const CategoryDetailsScreen({
    super.key,
    required this.name,
    required this.mobile,
    required this.email,    // Add this
    required this.password, // Add this
    required this.category,
    required this.pincode,
    required this.district,
    required this.city,
    required this.state,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

// --- THIS IS THE CLASS YOU ALREADY HAVE ---
class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final _standardController = TextEditingController();
  final _collegeController = TextEditingController();
  final _gpaController = TextEditingController();
  final _genericExtraController = TextEditingController();

  // New Student Controllers
  final _rollNumberController = TextEditingController();
  final _streamController = TextEditingController();
  final _gradYearController = TextEditingController();
  final _skillsController = TextEditingController();

  // New Business Controllers
  // Existing Business Controllers
  final _companyNameController = TextEditingController();
  final _gstController = TextEditingController();
  final _turnoverController = TextEditingController();
  final _employeeCountController = TextEditingController();
  final _websiteController = TextEditingController();
  final _establishmentYearController = TextEditingController();

  // --- NEW BANK CONTROLLERS ---
  final _bankNameController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _branchController = TextEditingController();
  final _ifscController = TextEditingController();

  // --- NEW FARMER CONTROLLERS ---
  final _cropNameController = TextEditingController();
  final _cropPriceController = TextEditingController();
  final _landSizeController = TextEditingController(); // Common extra info for farmers

  // 1. ADD THIS LINE: Define the controller
  final RegistrationController _controller = RegistrationController();

  // ... (Keep your existing TextEditingControllers here) ...

  // 2. ADD THIS METHOD: Put this at the very bottom of the class
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

  void _submitData() async {
    // Collect all data into a single Map to send to the Model/API
    Map<String, dynamic> allData = {
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

    // Add category-specific fields based on selection
    if (widget.category == 'Student') {
      allData.addAll({
        "college_name": _collegeController.text,
        "standard_year": _standardController.text,
        "stream": _streamController.text,
        "roll_number": _rollNumberController.text,
        "gpa": _gpaController.text,
        "graduation_year": _gradYearController.text,
        "skills": _skillsController.text,
      });
    } else if (widget.category == 'Business') {
      allData.addAll({
        "company_name": _companyNameController.text,
        "gst_number": _gstController.text,
        "turnover": _turnoverController.text,
        "employee_count": _employeeCountController.text,
        "business_website": _websiteController.text,
      });
    } else if (widget.category == 'Bank') {
      allData.addAll({
        "bank_name": _bankNameController.text,
        "interest_rate": _interestRateController.text,
        "branch_name": _branchController.text,
        "ifsc_code": _ifscController.text,
      });
    } else if (widget.category == 'Farmers') {
      allData.addAll({
        "crop_name": _cropNameController.text,
        "crop_price": _cropPriceController.text,
        "land_size": _landSizeController.text,
      });
    }

    try {
      // Send the map to your controller
      // Make sure your RegistrationController.registerUser can accept this map!
      final response = await _controller.registerUser(allData);

      if (response.statusCode == 201) {
        _showMessage("Registration Successful!", Colors.green);
        if (mounted) {
          // Go back to the very first screen (Login/Welcome)
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        _showMessage("Error: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      _showMessage("Could not connect to server.", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.category} Information")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Complete your profile as a ${widget.category}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // DYNAMIC FIELDS
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

            // --- BUSINESS FIELDS ---
            if (widget.category == 'Business') ...[
              CustomTextField(controller: _companyNameController, label: "Company Name"),
              const SizedBox(height: 15),
              CustomTextField(controller: _gstController, label: "GST Number"),
              const SizedBox(height: 15),

              // New Fields
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

            // --- NEW BANK FIELDS ---
            if (widget.category == 'Bank') ...[
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

            // --- NEW FARMER FIELDS ---
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

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                print("Final Submit for: ${widget.name}");
                _submitData();
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text("Final Submit"),
            ),
          ],
        ),
      ),
    );
  }
}