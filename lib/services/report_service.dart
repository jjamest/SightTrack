import "dart:convert";
import "package:http/http.dart" as http;
import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/global.dart";

Future<void> submitReport({
  required String itemId,
  required String reportType,
  required String reporter,
  required String reportReason,
}) async {
  const String apiUrl = "${ApiConstants.baseURL}/submitReport";

  final Map<String, dynamic> payload = {
    "itemId": itemId,
    "reportType": reportType,
    "reporter": reporter,
    "reportReason": reportReason,
  };

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(payload),
  );

  if (response.statusCode == 200) {
    Log.i("Successfully submitted report");
  } else {
    Log.e(
      "Failed to submit report: ${response.statusCode} | Response: ${response.body}",
    );
  }
}

Future<List<dynamic>> fetchAllReports() async {
  const String apiUrl = "${ApiConstants.baseURL}/fetchReports";

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    return jsonData["reports"];
  } else {
    throw Exception("Failed to fetch reports");
  }
}
