import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";
import "package:sighttrack_app/components/buttons.dart";
import "package:sighttrack_app/design.dart";
import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/widgets/success.dart";
import "package:sighttrack_app/components/text.dart";
import "package:sighttrack_app/navigation_bar.dart";
import "package:sighttrack_app/util/error_message.dart";

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String warningMessage = "";

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await Amplify.Auth.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            text: "Success",
            subText: "Your password has been changed",
            destination: CustomNavigationBar(),
          ),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      Log.e("Error updating password: ${e.message}");

      setState(() {
        warningMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: Looks.pagePadding,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 40),
                        LargeTextField(
                          controller: currentPasswordController,
                          labelText: "Current Password",
                          hintText: "Type your current password",
                          obscureText: true,
                        ),
                        const SizedBox(height: 40),
                        LargeTextField(
                          controller: newPasswordController,
                          labelText: "New Password",
                          hintText: "Type your new password",
                          obscureText: true,
                        ),
                        const SizedBox(height: 40),
                        LargeTextField(
                          controller: confirmPasswordController,
                          labelText: "Confirm Password",
                          hintText: "Confirm your password",
                          obscureText: true,
                        ),
                        const SizedBox(height: 40),
                        LargeButton(
                          onTap: () {
                            if (newPasswordController.text ==
                                confirmPasswordController.text) {
                              updatePassword(
                                oldPassword: currentPasswordController.text,
                                newPassword: newPasswordController.text,
                              );
                            } else {
                              showErrorMessage(
                                context,
                                "The passwords must match!",
                              );
                            }
                          },
                          label: "Change Password",
                        ),
                        const SizedBox(height: 40),
                        Text(
                          warningMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
