import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserActivities();
  }

  Future<void> _fetchUserActivities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final myPostsResponse = await http.get(
        Uri.parse(ApiConfig.getAllUserPosts(userController.id)),
      );
      final lovedPostsResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/get-loved-posts/${userController.id}'),
      );

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

  Widget _buildPostList(List<Post> posts) {
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          avatarPath: post.author.profilePictureUrl ??
              'assets/images/default_avatar.png',
          username: post.author.fullname,
          postImagePath: post.imageUrls.isNotEmpty ? post.imageUrls[0] : '',
          postText: post.captions,
          comments: post.comments ?? [],
        );
      },
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
          _buildPostList(_myPosts),
          _buildPostList(_lovedPosts),
        ],
      ),
    );
  }
}
