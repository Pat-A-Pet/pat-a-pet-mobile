import 'package:flutter/material.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/models/post.dart';

class PostCard extends StatefulWidget {
  final String avatarPath;
  final String username;
  final String postImagePath;
  final String postText;
  final List<Comment>? comments;

  const PostCard({
    super.key,
    required this.avatarPath,
    required this.username,
    required this.postImagePath,
    required this.postText,
    this.comments,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  bool showComments = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  void toggleComments() {
    setState(() {
      showComments = !showComments;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0),
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Username
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(widget.avatarPath),
            ),
            title: Text(
              widget.username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          // Post Image
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Image.asset(widget.postImagePath),
          ),

          // Post Text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.postText,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // Like & Comment Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  onPressed: toggleLike,
                ),
                IconButton(
                  icon: Icon(
                    showComments
                        ? Icons.chat_bubble
                        : Icons.chat_bubble_outline,
                    color: showComments ? Colors.lightGreen : Colors.black,
                  ),
                  onPressed: toggleComments,
                ),
              ],
            ),
          ),

          // Comments Section
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.linearToEaseOut,
            child: showComments
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const Divider(),
                        // Comments List
                        const SizedBox(height: 12),

                        // Text Field to Add Comment
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  hintText: 'Add a comment...',
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                ),
                                maxLines: 4,
                                minLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                                icon: const Icon(Icons.send,
                                    color: ConstantsColors.primary),
                                onPressed: () => {}),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(
      {required String avatar,
      required String username,
      required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage(avatar),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(text),
              ],
            ),
          )
        ],
      ),
    );
  }
}
