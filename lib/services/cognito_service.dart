import "package:sighttrack_app/logging.dart";
import "package:sighttrack_app/models/app_user.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "package:sighttrack_app/global.dart";

Future<List<AppUser>?> getAllUsers() async {
  final url = "${ApiConstants.baseURL}/admin/getAllUsers";

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
    );

    Log.i("Fetching users ... Status code ${response.statusCode}");

    if (response.statusCode == 502) {
      Log.i("Trying to fetch users again");
      return getAllUsers();
    }

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
        "Failed to retrieve users: ${response.statusCode} | Response body: ${response.body}",
      );
    }
  } catch (e) {
    Log.e("Error retrieving users: $e");
  }
  return null;
}

Future<void> updateUserGroups(String username, List<String> groups) async {
  const String apiUrl = "${ApiConstants.baseURL}/admin/addUserToGroup";

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "username": username,
      "groups": groups,
    }),
  );

  if (response.statusCode == 200) {
    Log.i("User groups updated successfully.");
  } else {
    Log.e("Failed to update user groups: ${response.body}");
  }
}
