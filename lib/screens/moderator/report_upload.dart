import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:sighttrack_app/design.dart";
import "package:sighttrack_app/models/photomarker.dart";
import "package:sighttrack_app/models/user_state.dart";
import "package:sighttrack_app/services/report_service.dart";

class ReportUploadScreen extends StatefulWidget {
  final PhotoMarker photoMarker;

  const ReportUploadScreen({super.key, required this.photoMarker});

  @override
  ReportUploadScreenState createState() => ReportUploadScreenState();
}

class ReportUploadScreenState extends State<ReportUploadScreen> {
  final TextEditingController _reportController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _submitReport() async {
    if (_reportController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please enter a reason for reporting.";
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final userState = Provider.of<UserState>(context, listen: false);

      // Simulate network call delay (replace with your actual submission logic)
      await submitReport(
        itemId: widget.photoMarker.photoId,
        reportType: "photo",
        reporter: userState.username,
        reportReason: _reportController.text,
      );

      if (!mounted) return;
      // Show a modern confirmation dialog on success.
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Report Submitted",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: const Text(
              "Thank you for your report. We will review it shortly.",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close confirmation dialog.
                  Navigator.of(context).pop(); // Return to the previous screen.
                },
                child: const Text(
                  "OK",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        },
      );
    } catch (error) {
      setState(() {
        _errorMessage = "Failed to submit report. Please try again later.";
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a light background for a modern, clean look.
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Report Upload",
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Padding(
        padding: Looks.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please provide details about why you are reporting this upload:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                // A subtle shadow for a modern elevated card look.
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).toInt()),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                controller: _reportController,
                maxLines: 5,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  hintText: "Enter your report reason here...",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    backgroundColor: Colors.teal, // Modern primary color.
                  ),
                  onPressed: _isSubmitting ? null : _submitReport,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Submit Report",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
