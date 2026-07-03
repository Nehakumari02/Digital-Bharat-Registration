import 'package:flutter/material.dart';
import '../../controllers/registration_controller.dart';
import '../../services/auth_session.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = RegistrationController();
  
  bool _isLoading = false;
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.userData);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final id = _formData['id']?.toString() ?? _formData['_id']?.toString() ?? '';
      if (id.isEmpty) throw Exception('User ID not found');

      final response = await _controller.updateProfile(id, _formData);
      
      if (response['status'] == 'success') {
        final updatedUser = response['user'] as Map<String, dynamic>;
        
        // Merge the updated user data with the current session token if needed
        final sessionData = Map<String, dynamic>.from(widget.userData);
        updatedUser.forEach((key, value) {
          sessionData[key] = value;
        });

        await AuthSession.save(sessionData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          // Return the updated data to the dashboard
          Navigator.pop(context, sessionData);
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to update');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String label, String key, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _formData[key]?.toString() ?? '',
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).colorScheme.surface,
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onSaved: (val) {
          _formData[key] = val?.trim() ?? '';
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.userData['category']?.toString();
    final isJobSeeker = category == 'Job Seeker';
    final isFarmer = category == 'Farmers' || category == 'Farmer';
    final isBusiness = category == 'Business';
    final isStudent = category == 'Student';
    final isBanker = category == 'Bank' || category == 'Banking / Financial Services' || category == 'Banker';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                    const SizedBox(height: 16),
                    _buildTextField('Full Name', 'name'),
                    _buildTextField('Mobile Number', 'mobile', isNumber: true),
                    _buildTextField('Email Address', 'email'),
                    
                    const SizedBox(height: 24),
                    const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                    const SizedBox(height: 16),
                    _buildTextField('City', 'city'),
                    _buildTextField('State', 'state'),
                    _buildTextField('Pincode', 'pincode', isNumber: true),

                    if (isJobSeeker) ...[
                      const SizedBox(height: 24),
                      const Text('Professional Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                      const SizedBox(height: 16),
                      _buildTextField('Years of Experience', 'years_of_experience', isNumber: true),
                      _buildTextField('Highest Education', 'highest_education'),
                      _buildTextField('Preferred Job Role (Career Focus)', 'preferred_job_role'),
                    ],

                    if (isFarmer) ...[
                      const SizedBox(height: 24),
                      const Text('Farm Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                      const SizedBox(height: 16),
                      _buildTextField('Crop Name', 'crop_name'),
                      _buildTextField('Land Size (Acres)', 'land_size'),
                    ],

                    if (isBusiness) ...[
                      const SizedBox(height: 24),
                      const Text('Business Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                      const SizedBox(height: 16),
                      _buildTextField('Company Name', 'company_name'),
                      _buildTextField('GST Number', 'gst_number'),
                      _buildTextField('Turnover', 'turnover', isNumber: true),
                    ],

                    if (isStudent) ...[
                      const SizedBox(height: 24),
                      const Text('Education Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                      const SizedBox(height: 16),
                      _buildTextField('College Name', 'college_name'),
                      _buildTextField('Standard/Year', 'standard_year'),
                      _buildTextField('Stream', 'stream'),
                    ],

                    if (isBanker) ...[
                      const SizedBox(height: 24),
                      const Text('Bank Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                      const SizedBox(height: 16),
                      _buildTextField('Bank Name', 'bank_name'),
                      _buildTextField('Branch Name', 'branch_name'),
                    ],

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
