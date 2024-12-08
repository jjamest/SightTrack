import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sighttrack_app/components/button.dart';
import 'package:sighttrack_app/components/small_button.dart';
import 'package:sighttrack_app/components/text_field_modern.dart';
import 'package:sighttrack_app/screens/profile/change_password.dart';
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
                  Column(
                    children: [
                      const SizedBox(height: 60),
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
                      ),
                      const SizedBox(height: 35),
                      CustomSmallButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordScreen()),
                          );
                        },
                        label: 'Change Password',
                      ),
                      const SizedBox(height: 125),
                      CustomButton(onTap: () {}, label: "Save changes"),
                    ],
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
