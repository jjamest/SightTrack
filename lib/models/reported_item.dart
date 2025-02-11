import "package:uuid/uuid.dart";

class ReportedItem {
  final String ticketId;
  final String itemId; // The ID of the reported photo or comment.
  final String reportType; // e.g., "photo" or "comment".
  final String reporter; // The user ID or username who is reporting.
  final String reportReason;
  final DateTime createdAt;

  ReportedItem({
    required this.ticketId,
    required this.itemId,
    required this.reportType,
    required this.reporter,
    required this.reportReason,
    required this.createdAt,
  });

  /// Convenience constructor for creating a new report.
  factory ReportedItem.create({
    required String itemId,
    required String reportType,
    required String reporter,
    required String reportReason,
  }) {
    return ReportedItem(
      ticketId: const Uuid().v4(), // Generates a unique report ID.
      itemId: itemId,
      reportType: reportType,
      reporter: reporter,
      reportReason: reportReason,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a ReportedItem instance from a Map.
  factory ReportedItem.fromMap(Map<String, dynamic> map) {
    return ReportedItem(
      ticketId: map["ticketId"] as String,
      itemId: map["itemId"] as String,
      reportType: map["reportType"] as String,
      reporter: map["reporter"] as String,
      reportReason: map["reportReason"] as String,
      createdAt: DateTime.parse(map["createdAt"] as String),
    );
  }

  /// Converts this ReportedItem into a Map.
  Map<String, dynamic> toMap() {
    return {
      "ticketId": ticketId,
      "itemId": itemId,
      "reportType": reportType,
      "reporter": reporter,
      "reportReason": reportReason,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
