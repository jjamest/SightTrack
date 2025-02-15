import "package:amplify_flutter/amplify_flutter.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:sighttrack_app/components/text.dart";
import "package:sighttrack_app/models/user_state.dart";
import "package:sighttrack_app/screens/info/faq.dart";
import "package:sighttrack_app/screens/info/privacy.dart";
import "package:sighttrack_app/screens/info/terms.dart";
import "package:sighttrack_app/screens/profile/edit_profile.dart";
import "package:sighttrack_app/screens/profile/settings.dart";
import "package:sighttrack_app/screens/upload/upload_gallery.dart";
import "package:sighttrack_app/services/announcement_service.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:intl/intl.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// This flag indicates if there are any unread announcements.
  bool _hasUnreadAnnouncements = false;

  @override
  void initState() {
    super.initState();
    _updateUnreadIndicator();
  }

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
      MaterialPageRoute(
        builder: (context) => const TermsAndConditionsScreen(),
      ),
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
      ),
    );
  }

  /// Retrieves the last-read announcement timestamp from persistent storage.
  Future<DateTime?> _getLastReadTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getString("lastReadAnnouncementTimestamp");
    if (ts != null) return DateTime.tryParse(ts);
    return null;
  }

  /// Saves the provided [timestamp] as the last-read announcement time.
  Future<void> _setLastReadTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "lastReadAnnouncementTimestamp",
      timestamp.toIso8601String(),
    );
  }

  /// Updates the unread indicator based on whether the newest announcement
  /// is later than the last-read timestamp.
  Future<void> _updateUnreadIndicator() async {
    try {
      final announcements = await fetchAnnouncements();
      // Sort announcements descending by 'createdAt'
      announcements.sort((a, b) {
        final dateA = DateTime.parse(a["createdAt"]);
        final dateB = DateTime.parse(b["createdAt"]);
        return dateB.compareTo(dateA);
      });
      if (announcements.isNotEmpty) {
        final newestDate = DateTime.parse(announcements.first["createdAt"]);
        final lastRead = await _getLastReadTimestamp();
        setState(() {
          _hasUnreadAnnouncements =
              (lastRead == null || newestDate.isAfter(lastRead));
        });
      } else {
        setState(() {
          _hasUnreadAnnouncements = false;
        });
      }
    } catch (e) {
      // If there's an error, hide the indicator.
      setState(() {
        _hasUnreadAnnouncements = false;
      });
    }
  }

  /// Displays an AlertDialog with scrollable, sorted announcements.
  /// After the dialog is closed, it marks the announcements as read.
  Future<void> _showAnnouncementsDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Announcements"),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: FutureBuilder<List<dynamic>>(
              future: fetchAnnouncements(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  List<dynamic> announcements = snapshot.data ?? [];
                  // Sort announcements descending by 'createdAt'
                  announcements.sort((a, b) {
                    final dateA = DateTime.parse(a["createdAt"]);
                    final dateB = DateTime.parse(b["createdAt"]);
                    return dateB.compareTo(dateA);
                  });
                  if (announcements.isEmpty) {
                    return const Text("No announcements found.");
                  }
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: announcements.map((announcement) {
                        DateTime createdAt =
                            DateTime.parse(announcement["createdAt"]);
                        String formattedDate =
                            DateFormat("yyyy-MM-dd – HH:mm").format(createdAt);
                        return ListTile(
                          title: Text(announcement["title"] ?? "No Title"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(announcement["content"] ?? "No Content"),
                              const SizedBox(height: 4),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
    // After closing the dialog, update the last-read timestamp.
    try {
      final announcements = await fetchAnnouncements();
      if (announcements.isNotEmpty) {
        announcements.sort((a, b) {
          final dateA = DateTime.parse(a["createdAt"]);
          final dateB = DateTime.parse(b["createdAt"]);
          return dateB.compareTo(dateA);
        });
        final newestDate = DateTime.parse(announcements.first["createdAt"]);
        await _setLastReadTimestamp(newestDate);
      }
    } catch (e) {
      // Optionally handle the error.
    }
    _updateUnreadIndicator();
  }

  /// Builds a custom announcements button with a red unread badge.
  Widget _buildAnnouncementButton() {
    return GestureDetector(
      onTap: _showAnnouncementsDialog,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The circular button with an announcement icon.
          Container(
            padding: const EdgeInsets.all(12.0),
            child: const Icon(
              Icons.announcement_outlined,
              size: 32,
              color: Colors.blue,
            ),
          ),
          // The red dot indicator for unread announcements.
          if (_hasUnreadAnnouncements)
            const Positioned(
              right: -2,
              top: -2,
              child: Icon(
                Icons.brightness_1,
                color: Colors.red,
                size: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            child: const Icon(
              Icons.settings,
              size: 32,
              // color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main profile content.
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 120),
                  CircleAvatar(
                    radius: 60,
                    child: Text(
                      userState.username[0].toUpperCase(),
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userState.username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userState.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userState.roles.join(", "),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
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
                      children: const [
                        Icon(Icons.upload_file, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "View Your Uploads",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    onTap: onPressYourUploads,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: onEditProfile,
                        child: const Text("Edit Profile"),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await Amplify.Auth.signOut();
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 200),
                ],
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: _buildAnnouncementButton(),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: _buildSettingsButton(),
            ),
          ],
        ),
      ),
    );
  }
}
