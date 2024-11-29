import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sighttrack_app/components/small_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 60),
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
            const SizedBox(height: 20),
            CustomSmallButton(onTap: () {}, label: "Change email"),
            const SizedBox(height: 20),
            CustomSmallButton(onTap: () {}, label: "Change password"),
          ],
        ),
      ),
    );
  }
}
