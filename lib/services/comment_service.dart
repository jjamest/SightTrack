// comment_service.dart
import 'package:sighttrack_app/models/comment.dart';
import 'package:sighttrack_app/settings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Add Comment
Future<Comment?> addComment(String photoId, String user, String content) async {
  final url = '${ApiConstants.baseURL}/addComment';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'photoId': photoId,
        'user': user,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final commentData = responseData['comment'];
      return Comment.fromMap(commentData);
    } else {
      // Handle errors
      print('Failed to add comment: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error adding comment: $e');
  }
  return null;
}

// Get Comments
Future<List<Comment>?> getComments(String photoId) async {
  final url = '${ApiConstants.baseURL}/getComments';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'photoId': photoId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> commentsJson = responseData['comments'];

      return commentsJson.map((json) => Comment.fromMap(json)).toList();
    } else {
      // Handle errors
      print('Failed to retrieve comments: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error retrieving comments: $e');
  }
  return null;
}
