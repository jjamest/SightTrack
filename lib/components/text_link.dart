import 'package:flutter/material.dart';

class CustomTextLink extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomTextLink({
    super.key,
    required this.text,
    required this.onPressed,
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.open_in_new, // Box with an arrow pointing top-right
            color: Colors.blueAccent,
            size: 20,
          ),
        ],
      ),
    );
  }
}
