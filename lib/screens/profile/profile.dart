import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:sighttrack_app/components/text.dart";
import "package:sighttrack_app/models/user_state.dart";
import "package:sighttrack_app/screens/info/faq.dart";
import "package:sighttrack_app/screens/info/privacy.dart";
import "package:sighttrack_app/screens/info/terms.dart";
import "package:sighttrack_app/screens/profile/edit_profile.dart";
import "package:sighttrack_app/screens/upload/upload_gallery.dart";

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

  void onPressYourUploads() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UploadGalleryScreen(
          global: false,
        ),
      ), // Replace with your actual page
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 120),
            CircleAvatar(
              radius: 60,
              child: Text(
                userState.username[0].toUpperCase(),
                style: TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              userState.username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              userState.email,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextLinkAndIcon(text: "FAQ", onPressed: onPressFAQ),
            const SizedBox(height: 10),
            TextLinkAndIcon(
              text: "Terms & Conditions",
              onPressed: onPressTerms,
            ),
            const SizedBox(height: 10),
            TextLinkAndIcon(
              text: "Privacy Policy",
              onPressed: onPressPrivacy,
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    "View Your Uploads",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              onTap: onPressYourUploads,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onEditProfile,
              child: const Text("Edit Profile"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Amplify.Auth.signOut();
              },
              child: const Text("Logout"),
            ),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}
