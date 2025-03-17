import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:sighttrack/models/User.dart';
import 'package:sighttrack/widgets/button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

  static Future<String> loadProfilePicture(String path) async {
    final result = await Amplify.Storage.getUrl(
      path: StoragePath.fromString(path),
      options: const StorageGetUrlOptions(
        pluginOptions: S3GetUrlPluginOptions(
          validateObjectExistence: true,
          expiresIn: Duration(hours: 2),
        ),
      ),
    ).result;
    return result.url.toString();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? userDatastore;
  String? cognitoUsername;
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
          userDatastore = users.first;
        }
        isLoading = false;
        cognitoUsername = currentUser.username; // Store the username
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
      if (userDatastore != null && event.item.id == userDatastore!.id) {
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
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userDatastore == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(child: Text('No profile found')),
                    const SizedBox(height: 30),
                    SightTrackButton(
                      text: 'Logout',
                      width: 100,
                      onPressed: () {
                        Amplify.Auth.signOut();
                      },
                    )
                  ],
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      (userDatastore!.profilePicture != null &&
                              userDatastore!.profilePicture!.isNotEmpty)
                          ? FutureBuilder<String?>(
                              future: ProfileScreen.loadProfilePicture(
                                  userDatastore!.profilePicture!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError ||
                                    !snapshot.hasData) {
                                  return CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Colors.grey,
                                    child: const Icon(
                                      Icons.person,
                                      size: 70,
                                      color: Colors.white,
                                    ),
                                  );
                                } else {
                                  return CircleAvatar(
                                    radius: 70,
                                    backgroundImage:
                                        NetworkImage(snapshot.data!),
                                  );
                                }
                              },
                            )
                          : CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.grey,
                              child: const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                      const SizedBox(height: 20),
                      // Cognito Username display
                      Text(
                        cognitoUsername!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      // Display username
                      Text(
                        userDatastore!.display_username,
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
                            userDatastore!.email,
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
                            userDatastore!.country!.isNotEmpty
                                ? userDatastore!.country!
                                : 'Location not set',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        userDatastore!.bio!.isNotEmpty
                            ? userDatastore!.bio!
                            : 'No bio',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 100),
                      SightTrackButton(
                        text: 'Logout',
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Logout'),
                                  content: Text('Are you sure?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Amplify.Auth.signOut();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Logout'),
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
