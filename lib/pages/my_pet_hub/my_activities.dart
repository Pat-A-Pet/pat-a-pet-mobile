import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/post_card.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/models/post.dart';

class MyActivities extends StatefulWidget {
  const MyActivities({super.key});

  @override
  State<MyActivities> createState() => _MyActivitiesState();
}

class _MyActivitiesState extends State<MyActivities>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final userController = Get.find<UserController>();
  List<Post> _lovedPosts = [];
  List<Post> _myPosts = [];
  bool _isLoading = true;
  final _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserActivities();
  }

  Future<void> _deletePost(String postId, int index) async {
    final token = await _secureStorage.read(key: 'jwt');
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.deletePost(postId)),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("Delete response status: ${response.statusCode}");
      print("Delete response body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          _myPosts.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete post')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }

  Future<void> _fetchUserActivities() async {
    final token = await _secureStorage.read(key: 'jwt');
    setState(() {
      _isLoading = true;
    });

    try {
      final myPostsResponse = await http.get(
        Uri.parse(ApiConfig.getAllUserPosts(userController.id)),
        headers: {
          'Authorization': 'Bearer $token', // Add JWT token
        },
      );
      final lovedPostsResponse = await http.get(
        Uri.parse(ApiConfig.getAllLovedPosts(userController.id)),
        headers: {
          'Authorization': 'Bearer $token', // Add JWT token
        },
      );

      print("My Posts: ${myPostsResponse.body}");

      if (myPostsResponse.statusCode == 200 &&
          lovedPostsResponse.statusCode == 200) {
        final myPostsJson = jsonDecode(myPostsResponse.body) as List;
        final lovedPostsJson = jsonDecode(lovedPostsResponse.body) as List;

        setState(() {
          _myPosts = myPostsJson.map((e) => Post.fromJson(e)).toList();
          _lovedPosts = lovedPostsJson.map((e) => Post.fromJson(e)).toList();
        });
      } else {
        print('Failed to load activities');
      }
    } catch (e) {
      print('Error fetching activities: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildPostList(List<Post> posts, bool isMyPosts) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'No posts to show 🐶',
          style: TextStyle(
              fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchUserActivities,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            post: post,
            showDelete: isMyPosts,
            onDelete: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Post'),
                  content:
                      const Text('Are you sure you want to delete this post?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deletePost(post.id, index);
                      },
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'My Activities',
        backgroundColor: ConstantsColors.accent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ConstantsColors.textPrimary,
          tabs: const [
            Tab(text: 'My Posts'),
            Tab(text: 'Loved Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostList(_myPosts, true),
          _buildPostList(_lovedPosts, false),
        ],
      ),
    );
  }
}
