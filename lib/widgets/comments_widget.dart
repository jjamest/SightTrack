import 'package:flutter/material.dart';
import 'package:sighttrack_app/models/comment.dart';
import 'package:sighttrack_app/services/comment_service.dart';

class CommentsWidget extends StatefulWidget {
  final String photoId;
  final String currentUser;

  const CommentsWidget({
    super.key,
    required this.photoId,
    required this.currentUser,
  });

  @override
  CommentsWidgetState createState() => CommentsWidgetState();
}

class CommentsWidgetState extends State<CommentsWidget> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  // Fetch comments from the backend
  Future<void> _loadComments() async {
    try {
      final comments = await getComments(widget.photoId);
      setState(() {
        _comments = comments ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load comments.';
        _isLoading = false;
      });
    }
  }

  // Add a new comment
  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment cannot be empty')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final newComment =
          await addComment(widget.photoId, widget.currentUser, content);
      if (newComment != null) {
        setState(() {
          _comments.insert(0, newComment); // Add to the top of the list
          _isSubmitting = false;
        });
        _commentController.clear();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comment added successfully')),
        );
      } else {
        setState(() {
          _isSubmitting = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment')),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Text(_errorMessage!)
                : _comments.isEmpty
                    ? Text('No comments yet. Be the first to comment!')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return _buildCommentTile(comment);
                        },
                      ),
        Divider(height: 30, thickness: 1),
        _buildAddCommentSection(),
      ],
    );
  }

  // Widget to display individual comment
  Widget _buildCommentTile(Comment comment) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(comment.user[0].toUpperCase()),
      ),
      title: Text(comment.user),
      subtitle: Text(comment.content),
      trailing: Text(
        '${comment.time.day}/${comment.time.month}/${comment.time.year}',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  // Widget for adding a new comment
  Widget _buildAddCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a Comment',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Enter your comment',
            border: OutlineInputBorder(),
          ),
          minLines: 1,
          maxLines: 5,
        ),
        SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _addComment,
            child: _isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text('Submit'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
