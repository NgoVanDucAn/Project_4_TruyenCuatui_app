import 'package:flutter/material.dart';
import 'package:truyencuatui/model/comment.dart';
import 'package:truyencuatui/model/readstory.dart';
import 'package:truyencuatui/service/commentService.dart';
import 'package:truyencuatui/service/readService.dart';

class ReadComicPage extends StatefulWidget {
  final String chapterId;

  const ReadComicPage({super.key, required this.chapterId});

  @override
  _ReadComicPageState createState() => _ReadComicPageState();
}

class _ReadComicPageState extends State<ReadComicPage> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  List<Comment> _comments = [];
  bool _isCommentSectionVisible = false;
  late Future<List<ReadPage>> pagesFuture; // Future to hold the list of pages
  String? _replyTo; // To track which comment is being replied to

  @override
  void initState() {
    super.initState();
    pagesFuture = ReadService().fetchPagesByChapterId(widget.chapterId);
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _loadComments() async {
    try {
      List<Comment> loadedComments = await CommentService().fetchComments();
      setState(() {
        _comments = loadedComments;
      });
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  void _addComment({String? replyTo}) {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        Comment newComment = Comment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userAvatarUrl: 'https://via.placeholder.com/150',
          userName: 'User Name',
          content: _commentController.text,
          replies: [],
          parentId: replyTo ?? '',
        );
        if (replyTo != null) {
          Comment? parentComment = _findCommentById(replyTo);
          parentComment?.addReply(newComment);
        } else {
          _comments.add(newComment);
        }
        _commentController.clear();
        _replyTo =
            null; // Reset the replyTo to ensure the state is ready for a new comment
      });
    }
  }

  Comment? _findCommentById(String id) {
    return _findCommentByIdRecursive(_comments, id);
  }

  Comment? _findCommentByIdRecursive(List<Comment> comments, String id) {
    for (var comment in comments) {
      if (comment.id == id) {
        return comment;
      }
      if (comment.replies.isNotEmpty) {
        Comment? found = _findCommentByIdRecursive(comment.replies, id);
        if (found != null) return found;
      }
    }
    return null;
  }

  Widget _buildCommentList(List<Comment> comments) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: comments.length,
      itemBuilder: (context, index) {
        Comment comment = comments[index];
        return Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(comment.userAvatarUrl),
              ),
              title: Text(comment.userName),
              subtitle: Text(comment.content),
              trailing: IconButton(
                icon: const Icon(Icons.reply),
                onPressed: () => _startReplyTo(comment.id),
              ),
            ),
            if (comment.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: _buildCommentList(comment.replies),
              ),
          ],
        );
      },
    );
  }

  void _startReplyTo(String commentId) {
    Comment? parentComment = _findCommentById(commentId);
    if (parentComment != null) {
      setState(() {
        _replyTo = parentComment.id;
        _commentController.text = '@${parentComment.userName} ';
        _commentController.selection = TextSelection.fromPosition(
            TextPosition(offset: _commentController.text.length));
      });
    }
  }

  void _toggleCommentSection() {
    setState(() {
      _isCommentSectionVisible = !_isCommentSectionVisible;
      if (!_isCommentSectionVisible) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 6,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Page'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<ReadPage>>(
              future: pagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator(); // Shows the loading indicator while waiting
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    physics: const ClampingScrollPhysics(), // Fix for scroll issue
                    shrinkWrap: true, // Fixes unbounded height issue
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var page = snapshot.data![index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.network(
                          page.images,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                                'Unable to load image'); // Display text when image cannot be loaded
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("No data available"));
                }
              },
            ),
          ),
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! > 0) {
                _toggleCommentSection();
              }
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _toggleCommentSection,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isCommentSectionVisible
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8.0),
                          const Text('Comments',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isCommentSectionVisible ? 300 : 0,
                    child: SingleChildScrollView(
                      child: _buildCommentList(_comments),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isCommentSectionVisible ? 60 : 0,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            focusNode: _commentFocusNode,
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Write a comment...',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: () => _addComment(replyTo: _replyTo),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
