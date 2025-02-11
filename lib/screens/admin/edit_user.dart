import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:sighttrack_app/design.dart";
import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/models/app_user.dart";
import "package:sighttrack_app/models/user_state.dart";
import "package:sighttrack_app/services/cognito_service.dart";

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  /// Local state variable to hold the current user info.
  late AppUser currentUser;

  /// The list of all possible groups.
  final List<String> allGroups = ["Admin", "Moderator"];

  /// This list is used for the UI outside the dialog.
  late List<bool> selectedGroups;

  @override
  void initState() {
    super.initState();
    // Copy the provided user into our state variable.
    currentUser = widget.user;
    // Initialize the checkboxes based on the current user's groups.
    selectedGroups =
        allGroups.map((group) => currentUser.groups.contains(group)).toList();
  }

  Future<void> _updateGroups(List<String> newGroups) async {
    try {
      // Call your backend update function.
      await updateUserGroups(currentUser.username, newGroups);
    } catch (e) {
      Log.e("Failed to update user groups: $e");
      return;
    }
    // Update local state first.
    setState(() {
      currentUser = AppUser(
        username: currentUser.username,
        status: currentUser.status,
        createdAt: currentUser.createdAt,
        lastModifiedAt: DateTime.now(), // Update as needed
        attributes: currentUser.attributes,
        groups: newGroups,
      );
      selectedGroups =
          allGroups.map((group) => newGroups.contains(group)).toList();
    });

    // Now update the global (singleton) state.
    if (!mounted) return;
    Provider.of<UserState>(context, listen: false)
        .updateState(roles: newGroups);
  }

  /// Shows the dialog to edit groups.
  void _showGroupDialog() {
    // Make a local copy of the current checkbox state.
    List<bool> dialogSelectedGroups = List.from(selectedGroups);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to maintain state inside the dialog.
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit User Groups"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(allGroups.length, (index) {
                  return CheckboxListTile(
                    title: Text(allGroups[index]),
                    value: dialogSelectedGroups[index],
                    onChanged: (bool? value) {
                      setStateDialog(() {
                        dialogSelectedGroups[index] = value ?? false;
                      });
                    },
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(), // Cancel dialog.
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    // Build a new list of groups from the dialog selections.
                    List<String> newGroups = [];
                    for (int i = 0; i < allGroups.length; i++) {
                      if (dialogSelectedGroups[i]) {
                        newGroups.add(allGroups[i]);
                      }
                    }
                    // Update the backend and the local state.
                    await _updateGroups(newGroups);

                    // Close the dialog.
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit User")),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: Looks.pagePadding,
            child: Column(
              children: [
                Text(
                  currentUser.username,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  currentUser.attributes["email"],
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentUser.groups.isNotEmpty
                          ? currentUser.groups.join(", ")
                          : "No privileges",
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    IconButton(
                      onPressed: _showGroupDialog,
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Status: ${currentUser.status}",
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Divider(),
                const SizedBox(height: 5),
                Text(
                  "Account created: ${currentUser.createdAt.toLocal().year}-${currentUser.createdAt.toLocal().month}-${currentUser.createdAt.toLocal().day}",
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Last modified: ${currentUser.lastModifiedAt.toLocal().year}-${currentUser.lastModifiedAt.toLocal().month}-${currentUser.lastModifiedAt.toLocal().day}",
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 50),
                // TODO: Implement deactivate user
                // SmallButton(onTap: () {}, label: "Deactivate User"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
