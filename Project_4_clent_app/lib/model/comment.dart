class Comment {
  String id;  // Unique identifier for each comment
  String userAvatarUrl; // URL for the user's avatar image
  String userName; // User's name
  String content; // Comment text
  List<Comment> replies; // List of replies to this comment
  String parentId; // Identifier for the parent comment, empty if it's a top-level comment

  Comment({
    this.id = '',
    required this.userAvatarUrl,
    required this.userName,
    required this.content,
    required this.replies,
    this.parentId = '', // Defaults to an empty string if not provided
  });

  // Factory method to create a Comment from a JSON map
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((replyJson) => Comment.fromJson(replyJson)).toList()
          : [],
      parentId: json['parentId'] as String? ?? '',
    );
  }

  // Method to add a reply to this comment
  void addReply(Comment reply) {
    replies.add(reply);
  }
}
