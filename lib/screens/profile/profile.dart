import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sighttrack/models/User.dart';
import 'package:sighttrack/screens/profile/settings.dart' as profile_settings;
import 'package:sighttrack/widgets/button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  bool isLoading = true;
  late StreamSubscription subscription;

  Future<void> fetchCurrentUser() async {
    try {
      // Get the current authenticated user.
      final currentUser = await Amplify.Auth.getCurrentUser();
      final userId = currentUser.userId;

      // Query DataStore for the current user record.
      final users = await Amplify.DataStore.query(
        User.classType,
        where: User.ID.eq(userId),
      );

      setState(() {
        if (users.isNotEmpty) {
          user = users.first;
        }
        isLoading = false;
      });
    } catch (e) {
      // Optionally log or handle errors here.
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();

    // Subscribe to DataStore changes for User.
    subscription = Amplify.DataStore.observe(User.classType).listen((event) {
      // If the changed record matches the current user, refresh the data.
      if (user != null && event.item.id == user!.id) {
        fetchCurrentUser();
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        const profile_settings.SettingsScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text("No profile found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile picture or default icon
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user!.profilePicture != null
                            ? NetworkImage(user!.profilePicture!)
                            : null,
                        backgroundColor: user!.profilePicture == null
                            ? Colors.grey
                            : Colors.transparent,
                        child: user!.profilePicture == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 20),
                      // Username
                      Text(
                        user!.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Email with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.email, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            user!.email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pin_drop, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            user!.country!.isNotEmpty
                                ? user!.country!
                                : "Location not set",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        user!.bio!.isNotEmpty ? user!.bio! : "No bio",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 100),
                      SightTrackButton(
                        text: "Logout",
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Logout"),
                                  content: Text("Are you sure?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Amplify.Auth.signOut();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Logout"),
                                    ),
                                  ],
                                );
                              });
                        },
                        width: 100,
                      ),
                    ],
                  ),
                ),
    );
  }
}
