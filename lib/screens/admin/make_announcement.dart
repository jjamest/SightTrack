import "package:flutter/material.dart";
import "package:sighttrack_app/design.dart";
import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/services/announcement_service.dart";
import "package:sighttrack_app/util/error_message.dart";

class MakeAnnoucementScreen extends StatefulWidget {
  const MakeAnnoucementScreen({super.key});

  @override
  State<MakeAnnoucementScreen> createState() => _MakeAnnoucementScreenState();
}

class _MakeAnnoucementScreenState extends State<MakeAnnoucementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      try {
        await makeAnnouncement(
          title: _titleController.text,
          content: _contentController.text,
        );

        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: const Text("Announcement submitted successfully!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pop(); // Go back to the previous page
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );

        // Clear form after submission
        _titleController.clear();
        _contentController.clear();
      } catch (e) {
        Log.e(e.toString());
        showErrorMessage(
          context,
          "Oops, that didn't work. Please contact support",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make an Announcement"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: Looks.pagePadding,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Announcement Title",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: "Enter announcement title",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Title cannot be empty";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Announcement Content",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _contentController,
                            decoration: InputDecoration(
                              hintText: "Enter announcement content",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Content cannot be empty";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _submitAnnouncement,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text("Submit Announcement"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
