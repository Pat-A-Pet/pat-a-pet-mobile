import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/models/post.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool showDelete;
  final VoidCallback? onDelete;
  final Function(Post)? onPostUpdated;

  const PostCard({
    super.key,
    required this.post,
    this.showDelete = false,
    this.onDelete,
    this.onPostUpdated,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Post _post;
  bool _isLoading = false;
  bool _isCommenting = false;
  bool showComments = false;
  int _currentImageIndex = 0;
  final TextEditingController _commentController = TextEditingController();
  final userController = Get.find<UserController>();
  final _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  Future<void> _toggleLove() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final token = await _secureStorage.read(key: "jwt");
      final url = ApiConfig.lovePostListing(_post.id);
      print('Sending PATCH to: $url');

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Received status: ${response.statusCode}');
      print('Received body: ${response.body}');

      // Handle non-JSON responses
      if (response.headers['content-type']?.contains('application/json') !=
          true) {
        throw Exception('Server returned non-JSON response');
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody is! Map<String, dynamic>) {
          throw Exception('Expected Map but got ${responseBody.runtimeType}');
        }

        final updatedPost = Post.fromJson(responseBody);
        setState(() => _post = updatedPost);
      } else {
        // Handle API error messages
        final errorMsg = responseBody['error'] ?? 'Failed to toggle love';
        throw Exception(errorMsg);
      }
    } catch (e, stack) {
      print('Toggle love error: $e');
      print('Stack trace: $stack');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error: ${e.toString().replaceAll(RegExp(r'^Exception: '), '')}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty || _isCommenting) return;

    setState(() => _isCommenting = true);

    try {
      final token = await _secureStorage.read(key: "jwt");
      final response = await http.post(
        Uri.parse(ApiConfig.addCommentToPost(_post.id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'comment':
              _commentController.text.trim(), // Ensure we send proper JSON
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        print('Parsed response: $responseBody');

        // Add explicit type checking
        if (responseBody is! Map<String, dynamic>) {
          throw Exception(
              'Expected Map<String, dynamic> but got ${responseBody.runtimeType}');
        }

        final updatedPost = Post.fromJson(responseBody);
        setState(() {
          _post = updatedPost;
          _commentController.clear();
        });
        widget.onPostUpdated?.call(updatedPost);
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e, stack) {
      print('Error adding comment: $e');
      print('Stack trace: $stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isCommenting = false);
    }
  }

  void _nextImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % _post.imageUrls.length;
    });
  }

  void _prevImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex - 1) < 0
          ? _post.imageUrls.length - 1
          : _currentImageIndex - 1;
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
    final isLoved = _post.loves.contains(userController.id);
    final loveCount = _post.loves.length;

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
              backgroundImage: _post.author.profilePictureUrl == null ||
                      _post.author.profilePictureUrl!.isEmpty
                  ? const AssetImage('assets/images/logo.png')
                  : NetworkImage(_post.author.profilePictureUrl!),
            ),
            title: Text(
              _post.author.fullname,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          // Post Image with navigation arrows
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 300,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _post.imageUrls[_currentImageIndex],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error_outline, size: 50),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_post.imageUrls.length > 1) ...[
                if (_currentImageIndex > 0)
                  Positioned(
                    left: 24,
                    child: GestureDetector(
                      onTap: _prevImage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_currentImageIndex < _post.imageUrls.length - 1)
                  Positioned(
                    right: 24,
                    child: GestureDetector(
                      onTap: _nextImage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _post.imageUrls.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Post Text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _post.captions,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // Like & Comment Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.redAccent,
                              ),
                            )
                          : Icon(
                              isLoved ? Icons.favorite : Icons.favorite_border,
                              color:
                                  isLoved ? Colors.redAccent : Colors.black54,
                            ),
                      onPressed: _toggleLove,
                    ),
                    Text(
                      '$loveCount',
                      style: TextStyle(
                        color: isLoved ? Colors.redAccent : Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        showComments
                            ? Icons.chat_bubble
                            : Icons.chat_bubble_outline,
                        color:
                            showComments ? Colors.lightGreen : Colors.black54,
                      ),
                      onPressed: toggleComments,
                    ),
                    Text(
                      '${_post.comments.length}',
                      style: TextStyle(
                        color:
                            showComments ? Colors.lightGreen : Colors.black54,
                      ),
                    ),
                  ],
                ),
                if (widget.showDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete,
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
                        const SizedBox(height: 12),
                        // Comments List
                        if (_post.comments.isNotEmpty)
                          ..._post.comments.map((comment) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: _post.author
                                                      .profilePictureUrl ==
                                                  null ||
                                              _post.author.profilePictureUrl!
                                                  .isEmpty
                                          ? const AssetImage(
                                              'assets/images/logo.png')
                                          : NetworkImage(
                                              _post.author.profilePictureUrl!),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.author.fullname,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(comment.text),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        if (_post.comments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text('No comments yet'),
                          ),
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
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: _isCommenting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send,
                                      color: ConstantsColors.primary),
                              onPressed: _addComment,
                            ),
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
}
