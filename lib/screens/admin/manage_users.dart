import "package:flutter/material.dart";
import "package:sighttrack_app/design.dart";
import "package:sighttrack_app/models/app_user.dart";
import "package:sighttrack_app/screens/admin/edit_user.dart";
import "package:sighttrack_app/services/cognito_service.dart";

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<AppUser>? users;
  bool blurEmails = true;

  void fetchUsers() async {
    List<AppUser>? temp = await getAllUsers();

    if (!mounted) return;
    setState(() {
      users = temp;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Users"),
        actions: [
          Row(
            children: [
              const Text("Blur Emails", style: TextStyle(fontSize: 16)),
              Switch(
                value: blurEmails,
                onChanged: (value) {
                  setState(() {
                    blurEmails = value;
                  });
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchUsers, // Refresh user list
          ),
        ],
      ),
      body: users == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: Looks.pagePadding,
                  child: Column(
                    children: [
                      Text(
                        "There are ${users?.length} total users",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      users!.isEmpty
                          ? const Text(
                              "No users found.",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            )
                          : Column(
                              children: users!
                                  .map((user) => _buildUserTile(user))
                                  .toList(),
                            ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildUserTile(AppUser user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(
          user.username,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          blurEmails
              ? _obfuscateEmail(user.attributes["email"] ?? "No email")
              : user.attributes["email"] ?? "No email",
          style: TextStyle(color: blurEmails ? Colors.grey : Colors.black),
        ),
        trailing: Wrap(
          spacing: 8, // Space between buttons
          children: [
            if (user.groups.contains("Admin"))
              IconButton(
                icon: Icon(Icons.admin_panel_settings_rounded),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Admin"),
                        content: Text(
                          "This user is an admin, and you cannot modify them",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Closes the dialog
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            if (!user.groups.contains("Admin"))
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserScreen(user: user),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Obfuscate email for privacy
  String _obfuscateEmail(String email) {
    if (!email.contains("@")) return email;
    List<String> parts = email.split("@");
    String domain = parts.last;
    return "${parts.first.substring(0, 3)}***@$domain";
  }
}
