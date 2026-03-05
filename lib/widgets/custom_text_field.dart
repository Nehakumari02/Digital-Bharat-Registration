import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        // Text style for the label when it floats or sits inside
        labelStyle: const TextStyle(color: Color(0xFF333333)),
        floatingLabelStyle: const TextStyle(color: Color(0xFFF26522)),

        // Background color of the text field
        filled: true,
        fillColor: Colors.white,

        // Border when the field is NOT selected
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFF26522), width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),

        // Border when the user clicks/taps the field
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFF26522), width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),

        // Border when there is a validation error
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),

        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}