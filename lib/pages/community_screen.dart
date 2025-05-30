import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/post_card.dart';
import 'package:pat_a_pet/constants/colors.dart'; // make sure the path matches where you saved it

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  final List<Map<String, dynamic>> posts = [
    {
      'avatar': 'assets/images/logo.png',
      'username': 'Yuna',
      'image': 'assets/images/logo.png',
      'text': 'Sleep in Sunday is the best day of the week! #sunspot',
      'comments': [
        {
          'avatar': 'assets/images/logo.png',
          'username': 'Yuna',
          'comment': 'Me too!'
        },
        {
          'avatar': 'assets/images/logo.png',
          'username': 'Max',
          'comment': 'So adorable!'
        },
      ],
    },
    {
      'avatar': 'assets/images/logo.png',
      'username': 'Yuna',
      'image': 'assets/images/logo.png',
      'text': 'Another cute post to brighten your day!',
      'comments': [{}],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(),
      body: Stack(children: [
        ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(
                avatarPath: post['avatar']!,
                username: post['username']!,
                postImagePath: post['image']!,
                postText: post['text']!,
                comments: post['comments']!);
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
                // Caption field
                TextField(
                  maxLines: 5,
                  minLines: 2,
                  onChanged: (value) {
                    newPostText = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Write your caption here (can include links)…',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Selected images preview
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

                // Pick Images Button
                ElevatedButton.icon(
                  onPressed: () async {
                    final List<XFile> images = await _picker.pickMultiImage();
                    if (images.isNotEmpty) {
                      setState(() {
                        _selectedImages.addAll(images);
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Add Images',
                    style: TextStyle(fontFamily: "Nunito", color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ConstantsColors.primary),
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
                    setState(() {
                      posts.insert(0, {
                        'avatar': 'assets/images/logo.png',
                        'username': 'CurrentUser',
                        'image': _selectedImages.isNotEmpty
                            ? _selectedImages.first.path
                            : 'assets/images/logo.png',
                        'text': newPostText,
                        'comments': [],
                        'extraImages':
                            _selectedImages.map((x) => x.path).toList(),
                      });
                    });
                    _selectedImages.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: ConstantsColors.primary),
                child: const Text(
                  'Post',
                  style: TextStyle(fontFamily: "Nunito", color: Colors.white),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
