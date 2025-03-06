import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sighttrack/models/User.dart';
import 'package:sighttrack/screens/profile/profile_picture.dart';
import 'package:sighttrack/widgets/button.dart'; // Your custom SightTrackButton

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? user;
  bool isLoading = true;

  Future<void> fetchCurrentUser() async {
    try {
      final currentUser = await Amplify.Auth.getCurrentUser();
      final userId = currentUser.userId;

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
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToEditPage(String field, String? currentValue) {
    if (user == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFieldPage(
          field: field,
          currentValue: currentValue,
          user: user!,
        ),
      ),
    ).then((_) {
      fetchCurrentUser();
    });
  }

  void _navigateToChangeProfilePicture() {
    if (user == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeProfilePictureScreen(user: user!),
      ),
    ).then((_) {
      fetchCurrentUser();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text("No profile found."))
              : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        "Profile Settings",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: user!.profilePicture != null
                            ? NetworkImage(user!.profilePicture!)
                            : null,
                        backgroundColor: user!.profilePicture == null
                            ? Colors.grey
                            : Colors.transparent,
                        child: user!.profilePicture == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: const Text("Profile Picture"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _navigateToChangeProfilePicture,
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      title: const Text("Username"),
                      subtitle: Text(user!.username),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          _navigateToEditPage("Username", user!.username),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      title: const Text("Email"),
                      subtitle: Text(user!.email),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _navigateToEditPage("Email", user!.email),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      title: const Text("Country"),
                      subtitle: Text(
                        user!.country != null && user!.country!.isNotEmpty
                            ? user!.country!
                            : "Not set",
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          _navigateToEditPage("Country", user!.country),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      title: const Text("Bio"),
                      subtitle: Text(
                        user!.bio != null && user!.bio!.isNotEmpty
                            ? user!.bio!
                            : "Not set",
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _navigateToEditPage("Bio", user!.bio),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        "App Settings",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text("Notifications"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NotificationsSettingsPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      title: const Text("Privacy"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacySettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
    );
  }
}

// ===================
// EDIT FIELD PAGE
// ===================
class EditFieldPage extends StatefulWidget {
  final String field;
  final String? currentValue;
  final User user;

  const EditFieldPage({
    super.key,
    required this.field,
    this.currentValue,
    required this.user,
  });

  @override
  State<EditFieldPage> createState() => _EditFieldPageState();
}

class _EditFieldPageState extends State<EditFieldPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue ?? "");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveField() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSaving = true;
      });
      try {
        final newValue = _controller.text.trim();
        User updatedUser;
        switch (widget.field) {
          case "Username":
            updatedUser = widget.user.copyWith(username: newValue);
            break;
          case "Email":
            updatedUser = widget.user.copyWith(email: newValue);
            break;
          case "Country":
            updatedUser = widget.user.copyWith(country: newValue);
            break;
          case "Bio":
            updatedUser = widget.user.copyWith(bio: newValue);
            break;
          default:
            updatedUser = widget.user;
            break;
        }
        await Amplify.DataStore.save(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Field updated successfully!")),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating field: $e")),
        );
      } finally {
        if (mounted) {
          setState(() {
            isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${widget.field}"),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: widget.field,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (widget.field == "Username" || widget.field == "Email") {
                    if (value == null || value.trim().isEmpty) {
                      return "${widget.field} cannot be empty";
                    }
                  }
                  if (widget.field == "Email" &&
                      value != null &&
                      value.trim().isNotEmpty &&
                      !RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(value.trim())) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SightTrackButton(
                text: "Save",
                onPressed: isSaving ? null : _saveField,
                loading: isSaving,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text("Notifications settings go here."),
      ),
    );
  }
}

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy"),
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text("Privacy settings go here."),
      ),
    );
  }
}
