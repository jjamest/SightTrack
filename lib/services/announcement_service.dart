import "dart:convert";
import "package:http/http.dart" as http;
import "package:sighttrack_app/global.dart";

/// Submits an announcement with the given [title] and [content].
///
/// Throws an [Exception] if the announcement submission fails.
Future<void> makeAnnouncement({
  required String title,
  required String content,
}) async {
  final String url = "${ApiConstants.baseURL}/makeAnnouncement";

  // Build the JSON payload.
  final payload = jsonEncode({
    "title": title,
    "content": content,
  });

  // Make the POST request.
  final response = await http.post(
    Uri.parse(url),
    headers: {
      "Content-Type": "application/json",
    },
    body: payload,
  );

  // Check if the submission was successful.
  if (response.statusCode != 200) {
    throw Exception("Failed to submit announcement: ${response.body}");
  }
}

/// Fetches announcements from the backend.
///
/// Expects the backend endpoint to return a JSON object like:
/// {
///   "announcements": [ { /* announcement object */ }, ... ]
/// }
///
/// Returns a [List] of dynamic objects (or convert these to a model as needed).
Future<List<dynamic>> fetchAnnouncements() async {
  final String url = "${ApiConstants.baseURL}/fetchAnnouncements";
  final uri = Uri.parse(url);

  // Perform the GET request.
  final response = await http.get(
    uri,
    headers: {
      "Content-Type": "application/json",
    },
  );

  // Check if the request was successful.
  if (response.statusCode != 200) {
    throw Exception("Failed to fetch announcements: ${response.body}");
  }

  // Decode the JSON response.
  final Map<String, dynamic> jsonData = jsonDecode(response.body);

  // Return the announcements list.
  return jsonData["announcements"] as List<dynamic>;
}
