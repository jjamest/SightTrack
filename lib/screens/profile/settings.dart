import "package:flutter/material.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:provider/provider.dart";
import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/models/settings_state.dart";
import "package:sighttrack_app/services/settings_service.dart";
import "package:sighttrack_app/models/UserSettings.dart"; // Make sure to import the generated model

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _randomPhotoOffset = false;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      // Retrieve the current user's ID from Amplify Auth.
      final authUser = await Amplify.Auth.getCurrentUser();

      // Query DataStore for existing settings for this user.
      // Adjust the query as needed based on your generated API.
      final settingsList = await Amplify.DataStore.query(
        UserSettings.classType,
        where: UserSettings.USERID.eq(authUser.userId),
      );

      if (settingsList.isNotEmpty) {
        setState(() {
          // Update the local state with the stored value.
          _randomPhotoOffset = settingsList.first.randomPhotoOffset ?? false;
        });
      }
    } catch (e) {
      Log.e("Error retrieving user settings: $e");
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Random Photo Location Offset"),
        content: const Text(
          "When enabled, a small random offset will be applied to the photo's location. "
          "This helps protect your privacy by preventing precise geotagging.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleRandomPhotoOffset(bool newValue) async {
    setState(() {
      _randomPhotoOffset = newValue;
    });
    try {
      final authUser = await Amplify.Auth.getCurrentUser();
      await updateUserSettings(
        userId: authUser.userId,
        randomPhotoOffset: newValue,
      );

      // Update global state
      if (!mounted) return;
      Provider.of<SettingsState>(context, listen: false)
          .setRandomPhotoOffset(newValue);
    } catch (e) {
      Log.e("Error retrieving user or updating settings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              "Photo Settings",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
            ),
          ),
          ListTile(
            title: const Text("Add Random Photo Location Offset"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: "More info",
                  onPressed: _showInfoDialog,
                ),
                Switch(
                  value: _randomPhotoOffset,
                  onChanged: _toggleRandomPhotoOffset,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
