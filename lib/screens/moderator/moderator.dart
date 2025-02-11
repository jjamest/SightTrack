import "package:flutter/material.dart";
import "package:sighttrack_app/screens/moderator/reported_items.dart";

class ModeratorScreen extends StatefulWidget {
  const ModeratorScreen({super.key});

  @override
  State<ModeratorScreen> createState() => _ModeratorScreenState();
}

class _ModeratorScreenState extends State<ModeratorScreen> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.report, size: 24),
          SizedBox(width: 8),
          Text(
            "Reported Items",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReportedItemsScreen(),
          ),
        );
      },
    );
  }
}
