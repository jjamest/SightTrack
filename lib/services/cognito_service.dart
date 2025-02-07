import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/models/app_user.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "package:sighttrack_app/settings.dart";

Future<List<AppUser>?> getAllUsers() async {
  final url = "${ApiConstants.baseURL}/admin/getAllUsers";

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
    );

    Log.i("Fetched all users (Status ${response.statusCode})");

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Validate response format
      if (responseData.containsKey("users") && responseData["users"] is List) {
        final List<dynamic> usersJson = responseData["users"];
        return usersJson.map((json) => AppUser.fromMap(json)).toList();
      } else {
        Log.e("Unexpected response format: ${response.body}");
      }
    } else {
      Log.e(
        "Failed to retrieve users: ${response.statusCode}\nResponse body: ${response.body}",
      );
    }
  } catch (e) {
    Log.e("Error retrieving users: $e");
  }
  return null;
}
