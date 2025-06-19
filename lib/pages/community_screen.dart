import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/post_card.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/models/post.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _secureStorage = FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<Post> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse(ApiConfig.getAllPosts);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> postJson = jsonDecode(response.body);
        print("post: $postJson");
        setState(() {
          _posts = postJson.map((json) => Post.fromJson(json)).toList();
        });
      } else {
        print('Failed to load posts: ${response.body}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddPostDialog() {
    String newPostText = '';
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Create New Post',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Nunito",
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24, thickness: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: textController,
                              maxLines: 5,
                              minLines: 2,
                              onChanged: (value) => newPostText = value,
                              decoration: InputDecoration(
                                hintText: 'What\'s on your mind?',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: ConstantsColors.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_selectedImages.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected Images (${_selectedImages.length})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _selectedImages.length,
                                      itemBuilder: (context, index) {
                                        final img = _selectedImages[index];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.file(
                                                  File(img.path),
                                                  width: 120,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedImages
                                                        .removeAt(index);
                                                  });
                                                },
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(4),
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.close,
                                                      color: Colors.white,
                                                      size: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final List<XFile> images =
                                    await _picker.pickMultiImage(
                                  maxWidth: 1000,
                                  maxHeight: 1000,
                                  imageQuality: 85,
                                );
                                if (images.isNotEmpty) {
                                  setState(() {
                                    _selectedImages.addAll(images);
                                  });
                                }
                              },
                              icon:
                                  const Icon(Icons.image, color: Colors.white),
                              label: const Text('Add Images',
                                  style: TextStyle(
                                      fontFamily: "Nunito",
                                      color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ConstantsColors.primary,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _selectedImages.clear();
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontFamily: "Nunito",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (newPostText.trim().isEmpty &&
                                _selectedImages.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please add text or images'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            await _createPost(newPostText, _selectedImages);
                            _selectedImages.clear();
                            if (mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ConstantsColors.primary,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Post',
                            style: TextStyle(
                                fontFamily: "Nunito", color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _createPost(String caption, List<XFile> images) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.createPost),
      );

      // Add authorization header
      final token = await _secureStorage.read(key: 'jwt');
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['captions'] = caption;

      // Add image files
      for (var image in images) {
        // Check if file exists
        final file = File(image.path);
        if (!await file.exists()) {
          print('File does not exist: ${image.path}');
          continue;
        }

        // Get file extension to determine content type
        final extension = image.path.split('.').last.toLowerCase();
        final contentType = extension == 'png'
            ? MediaType('image', 'png')
            : extension == 'jpg' || extension == 'jpeg'
                ? MediaType('image', 'jpeg')
                : MediaType('image', extension);

        var multipartFile = await http.MultipartFile.fromPath(
          'images', // Must match the field name in your backend
          image.path,
          contentType: contentType,
        );
        request.files.add(multipartFile);
      }

      // Debug print
      print('Sending request with:');
      print('Caption: $caption');
      print('Files count: ${request.files.length}');

      // Send request
      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $respStr');

      if (response.statusCode == 201) {
        // Refresh posts after successful creation
        await _fetchPosts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _fetchPosts();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create post: $respStr'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error creating post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating post: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: ConstantsColors.textPrimary),
            onPressed: _showAddPostDialog,
          ),
        ],
      ),
      body: Stack(children: [
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _posts.isEmpty
                ? const Center(
                    child: Text(
                      'No community posts yet\nbe the first to post!',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return PostCard(
                        post: post,
                      );
                    },
                  ),
      ]),
    );
  }
}
