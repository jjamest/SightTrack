class Comment {
  final String commentId;
  final String user;
  final DateTime time;
  final String content;

  Comment({
    required this.commentId,
    required this.user,
    required this.time,
    required this.content,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      commentId: map["commentId"] ?? "",
      user: map["user"] ?? "",
      time: DateTime.parse(map["time"] ?? DateTime.now().toIso8601String()),
      content: map["content"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "commentId": commentId,
      "user": user,
      "time": time.toIso8601String(),
      "content": content,
    };
  }
}
