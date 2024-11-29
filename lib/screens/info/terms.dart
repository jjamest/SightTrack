import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  TermsAndConditionsScreenState createState() =>
      TermsAndConditionsScreenState();
}

class TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  String termsContent = "Loading Terms and Conditions...";

  @override
  void initState() {
    super.initState();
    loadTerms();
  }

  Future<void> loadTerms() async {
    try {
      // Load the terms.txt file from the assets folder
      final content = await rootBundle.loadString('assets/terms.txt');
      setState(() {
        termsContent = content;
      });
    } catch (e) {
      setState(() {
        termsContent = "Failed to load Terms and Conditions.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms and Conditions"),
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
