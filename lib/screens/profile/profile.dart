import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sighttrack_app/components/text_link.dart';
import 'package:sighttrack_app/screens/info/faq.dart';
import 'package:sighttrack_app/screens/info/privacy.dart';
import 'package:sighttrack_app/screens/info/terms.dart';
import 'package:sighttrack_app/screens/profile/edit_profile.dart';
import 'package:sighttrack_app/util/error_message.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? username;
  String? email;

  void onEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
  }

  void onPressFAQ() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FAQScreen()),
    );
  }

  void onPressTerms() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
    );
  }

  void onPressPrivacy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  Future<void> getCurrentUser() async {
    try {
      // Start fetching username and email concurrently
      final usernameFuture = Amplify.Auth.getCurrentUser();
      final attributesFuture = Amplify.Auth.fetchUserAttributes();

      // Await the username retrieval
      usernameFuture.then((user) {
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
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 120),
            const Icon(
              Icons.person,
              size: 120,
            ),
            const SizedBox(height: 10),
            Text(
              username ?? 'Loading...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              email ?? 'Loading...', // Replace with user's bio or other info
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            CustomTextLink(text: "FAQ", onPressed: onPressFAQ),
            const SizedBox(height: 10),
            CustomTextLink(text: "Terms & Conditions", onPressed: onPressTerms),
            const SizedBox(height: 10),
            CustomTextLink(text: "Privacy Policy", onPressed: onPressPrivacy),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onEditProfile,
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 20),
            // SignOutButton()
            ElevatedButton(
              onPressed: () async {
                await Amplify.Auth.signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
