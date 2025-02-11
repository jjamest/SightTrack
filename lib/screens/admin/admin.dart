import "package:flutter/material.dart";
import "package:sighttrack_app/design.dart";
import "package:sighttrack_app/screens/admin/make_announcement.dart";
import "package:sighttrack_app/screens/admin/manage_users.dart";
import "package:sighttrack_app/screens/moderator/moderator.dart";

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: Looks.pagePadding,
            child: Column(
              children: [
                const SizedBox(height: 70),
                Text(
                  "Admin Panel",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "Manage users",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageUsersScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.announcement_outlined, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "Make announcement",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MakeAnnoucementScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                Divider(),
                const SizedBox(height: 15),
                ModeratorScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
