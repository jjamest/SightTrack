import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:sighttrack_app/design.dart";
import "package:sighttrack_app/models/reported_item.dart";
import "package:sighttrack_app/services/report_service.dart";

class ReportedItemsScreen extends StatefulWidget {
  const ReportedItemsScreen({super.key});

  @override
  State<ReportedItemsScreen> createState() => _ReportedItemsScreenState();
}

class _ReportedItemsScreenState extends State<ReportedItemsScreen> {
  late Future<List<dynamic>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = fetchAllReports();
  }

  void _viewReportDetails(ReportedItem report) {
    // TODO: Show upload photo if type=photo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report Details"),
        content: Text(
          "Ticket ID: ${report.ticketId}\n"
          "Item ID: ${report.itemId}\n"
          "Type: ${report.reportType}\n"
          "Reporter: ${report.reporter}\n"
          "Reason: ${report.reportReason}\n"
          "Created At: ${DateFormat('yyyy-MM-dd HH:mm').format(report.createdAt)}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // Dummy function to handle "Delete Report" button.
  void _deleteReport(ReportedItem report) {
    // TODO: Create delete report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("To be implemented"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<dynamic>>(
          future: _reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Reported Items");
            }
            if (snapshot.hasError) {
              return const Text("Reported Items (Error)");
            }
            final reportsData = snapshot.data ?? [];
            return Text("Reported Items (${reportsData.length})");
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final reportsData = snapshot.data ?? [];
          if (reportsData.isEmpty) {
            return const Center(child: Text("No reports found."));
          }
          // Convert the raw data into ReportedItem models.
          final List<ReportedItem> reports = reportsData
              .map((data) => ReportedItem.fromMap(data as Map<String, dynamic>))
              .toList();

          // Sort reports in descending order by createdAt (most recent first).
          reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return Padding(
            padding: Looks.pagePadding,
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text("Ticket: ${report.ticketId}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Item ID: ${report.itemId}"),
                        Text("Type: ${report.reportType}"),
                        Text("Reporter: ${report.reporter}"),
                        Text("Reason: ${report.reportReason}"),
                        const SizedBox(height: 4),
                        Text(
                          "Reported on: ${DateFormat('yyyy-MM-dd HH:mm').format(report.createdAt)}",
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "view") {
                          _viewReportDetails(report);
                        } else if (value == "delete") {
                          _deleteReport(report);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "view",
                          child: Text("View Details"),
                        ),
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("Delete Report"),
                        ),
                        // TODO: "Take action" function to take down selected report content
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
