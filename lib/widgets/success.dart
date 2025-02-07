import "package:flutter/material.dart";
import "package:sighttrack_app/components/buttons.dart";
import "package:sighttrack_app/design.dart";

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    super.key,
    required this.text,
    this.subText,
    required this.destination,
    this.icon,
  });

  final String text;
  final String? subText;
  final Widget destination;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: Looks.pagePadding,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(20),
                child: Icon(
                  icon ?? Icons.check_circle,
                  color: Colors.green,
                  size: 100,
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
              Text(
                subText ?? "",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              LargeButton(
                onTap: () {
                  // Replace this screen with the destination
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => destination),
                    (route) => false, // Remove all routes except the new one
                  );
                },
                label: "Go Back",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
