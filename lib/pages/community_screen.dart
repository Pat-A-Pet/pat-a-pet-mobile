import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/post_card.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/configs/api_config.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<dynamic> _posts = [];
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
        setState(() {
          _posts = postJson;
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

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Create New Post'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  maxLines: 5,
                  minLines: 2,
                  onChanged: (value) {
                    newPostText = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Write your caption here…',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedImages.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedImages.map((img) {
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(img.path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.remove(img);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final List<XFile> images = await _picker.pickMultiImage();
                    if (images.isNotEmpty) {
                      setState(() {
                        _selectedImages.addAll(images);
                      });
                    }
                  },
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text('Add Images',
                      style:
                          TextStyle(fontFamily: "Nunito", color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConstantsColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _selectedImages.clear();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (newPostText.isNotEmpty || _selectedImages.isNotEmpty) {
                    // Locally add new post (mock, or send POST request to your backend here)
                    setState(() {
                      _posts.insert(0, {
                        'author': {
                          'fullname': 'CurrentUser',
                          'profilePictureUrl': 'assets/images/logo.png'
                        },
                        'images': _selectedImages.map((x) => x.path).toList(),
                        'text': newPostText,
                        'comments': [],
                      });
                    });
                    _selectedImages.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantsColors.primary,
                ),
                child: const Text('Post',
                    style:
                        TextStyle(fontFamily: "Nunito", color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(),
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
                        avatarPath: post['author']?['profilePictureUrl'] ??
                            'assets/images/logo.png',
                        username: post['author']?['fullname'] ?? 'Unknown',
                        postImagePath:
                            post['images'] != null && post['images'].isNotEmpty
                                ? post['images'][0]
                                : 'assets/images/logo.png',
                        postText: post['text'] ?? '',
                        comments: post['comments'] ?? [],
                      );
                    },
                  ),
        Positioned(
          bottom: -24,
          right: MediaQuery.of(context).size.width * 0.42,
          left: MediaQuery.of(context).size.width * 0.42,
          child: FloatingActionButton(
            onPressed: () {
              _showAddPostDialog();
            },
            backgroundColor: ConstantsColors.primary,
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ]),
    );
  }
}

