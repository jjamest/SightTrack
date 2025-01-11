import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:sighttrack_app/components/buttons.dart";
import "package:sighttrack_app/widgets/success.dart";
import "package:sighttrack_app/components/text.dart";
import "package:sighttrack_app/navigation_bar.dart";
import "package:sighttrack_app/util/error_message.dart";

class ConfirmEmailScreen extends StatefulWidget {
  const ConfirmEmailScreen({
    super.key,
    required this.destination,
    required this.deliveryMedium,
  });

  final String? destination;
  final String? deliveryMedium;

  @override
  State<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends State<ConfirmEmailScreen> {
  final TextEditingController codeController = TextEditingController();

  Future<void> onVerify() async {
    try {
      FocusScope.of(context).unfocus();

      await Amplify.Auth.confirmUserAttribute(
        userAttributeKey: AuthUserAttributeKey.email,
        confirmationCode: codeController.text,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SuccessScreen(
            text: "Success",
            subText: "Your email has been changed",
            destination: CustomNavigationBar(),
          ),
        ),
      );
    } on AuthException {
      if (!mounted) return;
      showErrorMessage(context, "Invalid code. Please try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Email"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors
                          .green.shade100, // Subtle background for the logo
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Icon(
                      Icons.email,
                      color: Colors.green,
                      size: 100, // Adjust size as needed
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "A confirmation code has been sent to ${widget.destination}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Subtext
                  Text(
                    "Please check your ${widget.deliveryMedium} for the code",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  LargeTextField(
                    controller: codeController,
                    labelText: "Verification code",
                    hintText: "Enter code here",
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 40),
                  LargeButton(onTap: onVerify, label: "Verify"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
