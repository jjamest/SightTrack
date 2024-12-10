import 'package:flutter/material.dart';
import 'package:sighttrack_app/components/button.dart';

class SuccessScreen extends StatelessWidget {
  final String text;
  final String subText;
  final Widget destination;

  const SuccessScreen(
      {super.key,
      required this.text,
      required this.subText,
      required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to a clean white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100, // Subtle background for the logo
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100, // Adjust size as needed
              ),
            ),
            const SizedBox(height: 20),
            Text(
              text,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Subtext
            Text(
              subText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            CustomButton(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => destination,
                    ),
                    (route) => true, // Removes all previous routes
                  );
                },
                label: 'Go Back'),
          ],
        ),
      ),
    );
  }
}
