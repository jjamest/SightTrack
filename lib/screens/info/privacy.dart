import "package:flutter/material.dart";
import "package:flutter/services.dart" show rootBundle;

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  PrivacyPolicyScreenState createState() => PrivacyPolicyScreenState();
}

class PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String termsContent = "Loading Privacy Policy...";

  @override
  void initState() {
    super.initState();
    loadTerms();
  }

  Future<void> loadTerms() async {
    try {
      // Load the terms.txt file from the assets folder
      final content = await rootBundle.loadString("assets/privacy.txt");
      setState(() {
        termsContent = content;
      });
    } catch (e) {
      setState(() {
        termsContent = "Failed to load Privacy Policy.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            termsContent,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
