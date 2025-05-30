import 'package:flutter/material.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/post_card.dart';
import 'package:pat_a_pet/constants/colors.dart';

class YourActivities extends StatefulWidget {
  const YourActivities({super.key});

  @override
  State<YourActivities> createState() => _YourActivitiesState();
}

class _YourActivitiesState extends State<YourActivities>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> lovedPosts = [
    {
      'avatar': 'assets/images/logo.png',
      'username': 'Luna',
      'image': 'assets/images/logo.png',
      'text': 'Look at my sunbathe spot!',
      'comments': [{}],
    },
  ];

  final List<Map<String, dynamic>> myPosts = [
    {
      'avatar': 'assets/images/logo.png',
      'username': 'You',
      'image': 'assets/images/logo.png',
      'text': 'My adorable pup enjoying a treat 🍪',
      'comments': [{}],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildPostList(List<Map<String, dynamic>> posts) {
    if (posts.isEmpty) {
      return const Center(
        child: Text('No posts to show 🐶'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          avatarPath: post['avatar']!,
          username: post['username']!,
          postImagePath: post['image']!,
          postText: post['text']!,
          comments: post['comments']!,
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
          _buildPostList(myPosts),
          _buildPostList(lovedPosts),
        ],
      ),
    );
  }
}
