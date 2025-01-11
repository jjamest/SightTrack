import "dart:convert";

import "package:http/http.dart" as http;
import "package:sighttrack_app/settings.dart";

Future<Map<String, dynamic>> getDataAnalysis() async {
  final response = await http.get(Uri.parse(ApiConstants.getAnalysis));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("Failed to load analysis data");
  }
}
