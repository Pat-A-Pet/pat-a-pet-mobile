import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/post_card.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/components/pet_listing_card.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/models/pet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final pets = [
    Pet(
      imagePath: 'assets/images/logo.png',
      name: 'Buddy',
      location: 'New York',
      sex: 'Male',
      color: 'Brown',
      breed: 'Golden Retriever',
      weight: '25kg',
      owner: 'John Doe',
      description: 'A friendly and playful dog that loves the outdoors.',
    ),
    // Add more pets...
  ];

  final List<Map<String, dynamic>> communityPosts = [
    {
      'avatarPath': 'assets/images/logo.png',
      'username': 'PetLover123',
      'postImagePath': 'assets/images/logo.png',
      'postText': 'Just adopted a new puppy today!',
      'comments': [
        {
          'avatar': 'assets/images/logo.png',
          'username': 'HappyHelper',
          'comment': 'Aww congrats!!'
        },
      ],
    },
    {
      'avatarPath': 'assets/images/logo.png',
      'username': 'FurryFriendFan',
      'postImagePath': 'assets/images/logo.png',
      'postText': 'Meet Luna, my new rescue cat 🐱',
      'comments': [{}],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return Scaffold(
      backgroundColor: ConstantsColors.background,
      appBar: CustomAppbar(),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello there, User!',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset("assets/images/hero_home_1.png"),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Latest Listed Pets',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 220, // height of each card
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: pets.length,
                          itemBuilder: (context, index) {
                            final pet = pets[index];
                            return PetListingCard(
                              pet: pet,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Latest Community Posts',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: communityPosts.map((post) {
                          return PostCard(
                            avatarPath: post['avatarPath'],
                            username: post['username'],
                            postImagePath: post['postImagePath'],
                            postText: post['postText'],
                            comments: post['comments'],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: const Text(
                      '🐶 83 pets listed | 🐾 23 adoptions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
