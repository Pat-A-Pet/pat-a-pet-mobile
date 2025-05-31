import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/post_card.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/components/pet_listing_card.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/models/pet.dart';
import 'package:pat_a_pet/configs/api_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pet> _pets = [];
  List<dynamic> _communityPosts = [];
  bool _isLoadingPets = false;
  bool _isLoadingPosts = false;
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _fetchLatestPets();
    _fetchLatestPosts();
  }

  Future<void> _fetchLatestPets() async {
    setState(() {
      _isLoadingPets = true;
    });

    final uri = Uri.parse(ApiConfig.getAllPetListings);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> petJson = jsonDecode(response.body);
        final pets = petJson.map((json) => Pet.fromJson(json)).toList();

        // limit to 5 pets for home preview
        setState(() {
          _pets = pets.take(5).toList();
        });
      } else {
        print('Failed to load pets: ${response.body}');
      }
    } catch (e) {
      print('Error fetching pets: $e');
    } finally {
      setState(() {
        _isLoadingPets = false;
      });
    }
  }

  Future<void> _fetchLatestPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });

    final uri = Uri.parse(ApiConfig.getAllPosts);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> postJson = jsonDecode(response.body);

        // limit to 3 posts for home preview
        setState(() {
          _communityPosts = postJson.take(3).toList();
        });
      } else {
        print('Failed to load posts: ${response.body}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

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
                      Text(
                        'Hello there,\n${userController.fullname}!',
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
                      _isLoadingPets
                          ? const Center(child: CircularProgressIndicator())
                          : _pets.isEmpty
                              ? const Center(
                                  child: Text(
                                  'No pets listed yet',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ))
                              : SizedBox(
                                  height: 220,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _pets.length,
                                    itemBuilder: (context, index) {
                                      final pet = _pets[index];
                                      return PetListingCard(pet: pet);
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
                      _isLoadingPosts
                          ? const Center(child: CircularProgressIndicator())
                          : _communityPosts.isEmpty
                              ? const Center(
                                  child: Text(
                                  'No community posts yet',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ))
                              : Column(
                                  children: _communityPosts.map((post) {
                                    return PostCard(
                                      avatarPath: post['author']
                                              ?['profilePictureUrl'] ??
                                          'assets/images/logo.png',
                                      username: post['author']?['fullname'] ??
                                          'Unknown',
                                      postImagePath: (post['images'] != null &&
                                              post['images'].isNotEmpty)
                                          ? post['images'][0]
                                          : 'assets/images/logo.png',
                                      postText: post['text'] ?? '',
                                      comments: post['comments'] ?? [],
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
                    child: Text(
                      '🐶 ${_pets.length} pets listed | 🐾 ${_pets.where((pet) => pet.status == 'adopted').length} adoptions',
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
