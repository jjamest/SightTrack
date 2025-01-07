import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool? obscureText;
  final TextInputType keyboardType; // Add this property
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction?
      textInputAction; // Optional for customizing input actions
  final ValueChanged<String>? onChanged; // Allow onChanged callback
  final bool? enabled;

  const CustomModernTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText,
    this.keyboardType = TextInputType.text, // Default to text input
    this.inputFormatters,
    this.textInputAction,
    this.onChanged,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled ?? true,
      obscureText: obscureText ?? false,
      controller: controller,
      keyboardType: keyboardType, // Use the keyboardType property
      inputFormatters: inputFormatters, // Apply input formatters
      textInputAction: textInputAction, // Pass textInputAction if provided
      onChanged: onChanged, // Trigger onChanged if provided
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );
  }
}
