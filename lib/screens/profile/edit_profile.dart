import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sighttrack_app/components/button.dart';
import 'package:sighttrack_app/components/success.dart';
import 'package:sighttrack_app/components/text_field_modern.dart';
import 'package:sighttrack_app/design.dart';
import 'package:sighttrack_app/logging.dart';
import 'package:sighttrack_app/navigation_bar.dart';
import 'package:sighttrack_app/screens/profile/change_password.dart';
import 'package:sighttrack_app/screens/profile/confirm_email.dart';
import 'package:sighttrack_app/screens/profile/delete_account.dart';
import 'package:sighttrack_app/util/error_message.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController emailController = TextEditingController();

  final userFuture = Amplify.Auth.getCurrentUser();

  String? username;
  String? email;

  Future<void> getCurrentUser() async {
    try {
      final attributesFuture = Amplify.Auth.fetchUserAttributes();

      // Await the username retrieval
      userFuture.then((user) {
        setState(() {
          username = user.username;
        });
      }).catchError((e) {
        if (!mounted) return;
        showErrorMessage(context, 'Error fetching username: $e');
      });

      // Await the attributes retrieval and extract email
      attributesFuture.then((attributes) {
        final emailAttribute = attributes.firstWhere(
          (attr) => attr.userAttributeKey == CognitoUserAttributeKey.email,
          orElse: () => throw Exception('Email not found'),
        );

        setState(() {
          email = emailAttribute.value;
        });
        emailController.text = email!;
      }).catchError((e) {
        if (!mounted) return;
        showErrorMessage(context, 'Error fetching email: $e');
      });
    } catch (e) {
      if (!mounted) return;
      showErrorMessage(context, 'Error: $e');
    }
  }

  Future<void> onSaveChanges() async {
    try {
      final result = await Amplify.Auth.updateUserAttribute(
          userAttributeKey: AuthUserAttributeKey.email,
          value: emailController.text);
      handleUpdateUserAttributeResult(result);
    } on AuthException catch (e) {
      if (!mounted) return;
      showErrorMessage(context, 'Error updating user attribute: ${e.message}');
    }
  }

  void handleUpdateUserAttributeResult(
    UpdateUserAttributeResult result,
  ) {
    switch (result.nextStep.updateAttributeStep) {
      case AuthUpdateAttributeStep.confirmAttributeWithCode:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmEmailScreen(
                destination: codeDeliveryDetails.destination,
                deliveryMedium: codeDeliveryDetails.deliveryMedium.name),
          ),
        );
        break;
      case AuthUpdateAttributeStep.done:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SuccessScreen(
              text: 'Success',
              subText: 'Updated email',
              destination: CustomNavigationBar(),
            ),
          ),
        );
        logger.d('Successfully updated attribute');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  Padding(
                    padding: Looks.pagePadding,
                    child: Column(
                      children: [
                        const Icon(Icons.person, size: 120),
                        const SizedBox(height: 10),
                        Text(
                          username ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomModernTextField(
                          controller: emailController,
                          labelText: 'Email',
                          hintText: email ?? 'Loading...',
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 35),
                        CustomModernTextField(
                          controller: emailController,
                          labelText: 'Password',
                          hintText: '',
                          obscureText: true,
                          enabled: false,
                        ),
                        GestureDetector(
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangePasswordScreen()),
                                );
                              },
                              child: Text('Change Password')),
                        ),

                        // Danger zone
                        const SizedBox(height: 60),
                        Row(
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.red,
                              size: 35,
                            ),
                            const SizedBox(width: 5),
                            Text("Danger Zone",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const DeleteAccountScreen()));
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.red),
                                    const SizedBox(width: 5),
                                    Text("Delete account",
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                                child: Text(
                                  "By deleting your account, you delete all references to you. Meaning your uploads, comments, or any other app interactions will still exist; however, they will then belong to Deleted Account, not you",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 125),
                        CustomButton(
                            onTap: onSaveChanges, label: "Save changes"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
