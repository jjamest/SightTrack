import "package:flutter/material.dart";
import "package:flutter/services.dart";

class SmallTextBox extends StatelessWidget {
  const SmallTextBox({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.maxLines = 1,
    this.minLines = 1,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;
  final int minLines;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 16, color: Colors.grey[600]),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2.0,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(fontSize: 16, color: Colors.black),
    );
  }
}

class LargeTextField extends StatelessWidget {
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

  const LargeTextField({
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

class TextLinkAndIcon extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool? icon;

  const TextLinkAndIcon({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 8),
          if (icon ?? true)
            const Icon(
              Icons.open_in_new,
              color: Colors.blueAccent,
              size: 20,
            ),
        ],
      ),
    );
  }
}
