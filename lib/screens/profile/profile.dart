import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sighttrack_app/components/text_link.dart';
import 'package:sighttrack_app/screens/info/faq.dart';
import 'package:sighttrack_app/screens/info/privacy.dart';
import 'package:sighttrack_app/screens/info/terms.dart';
import 'package:sighttrack_app/screens/profile/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
              FirebaseAuth.instance.currentUser!.email ??
                  'Loading email please wait...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Bio or other user details here', // Replace with user's bio or other info
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
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
