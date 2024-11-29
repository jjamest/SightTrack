import 'package:flutter/material.dart';

class CustomSmallButton extends StatelessWidget {
  final Function()? onTap;
  final String label;

  const CustomSmallButton({
    super.key,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        // Ensures width adjusts to text size
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20), // Add padding for better appearance
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
