import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controllers/registration_controller.dart';
import '../models/registration_model.dart';
import '../widgets/custom_text_field.dart'; // Import your new widget
import 'login_screen.dart'; // Ensure this file exists in your lib/views folder

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final RegistrationController _controller = RegistrationController();
  String? _selectedCategory;
  final List<String> _categories = ['Student', 'Business', 'Bank', 'Farmers'];

  void _submitData() async {
    if (_formKey.currentState!.validate()) {


      // Create the model object
      final newUser = RegistrationModel(
        name: _nameController.text,
        mobile: _mobileController.text,
        category: _selectedCategory!,
      );

      try {
        // Send data through the controller
        final response = await _controller.registerUser(newUser);

        if (response.statusCode == 201) {
          _showMessage("Success! Registered in MySQL.", Colors.green);
          _formKey.currentState!.reset();
          _nameController.clear();
          _mobileController.clear();
          // Move to Login Screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          _showMessage("Error: ${response.statusCode}", Colors.red);
        }
      } catch (e) {
        _showMessage("Could not connect to server.", Colors.red);
      } finally {

      }
    }
  }

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
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(controller: _nameController, label: 'Full Name',
                validator: (v) => v!.isEmpty ? "Enter Name" : null,),
              const SizedBox(height: 10),
              CustomTextField(controller: _mobileController, label: 'Mobile Number',
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length < 10 ? "Enter valid mobile" : null,),
              const SizedBox(height: 10),
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((String category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 20),


              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Logic to save data goes here
                    _submitData();
                  }
                },
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}