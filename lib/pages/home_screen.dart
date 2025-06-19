import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/post_card.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/components/pet_listing_card.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/models/pet.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/models/post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pet> _pets = [];
  List<Post> _communityPosts = [];
  bool _isLoadingPets = false;
  bool _isLoadingPosts = false;
  bool _isRefreshingToken = false;
  final userController = Get.find<UserController>();
  final _secureStorage = const FlutterSecureStorage();
  var petsListedCounts = 0;
  var adoptionsCounts = 0;

  @override
  void initState() {
    super.initState();
    _initializeHomeScreen();
  }

  Future<void> _initializeHomeScreen() async {
    // First, try to refresh the token
    final refreshSuccess = await _refreshTokenIfNeeded();

    // Only fetch data if token refresh was successful or not needed
    if (refreshSuccess) {
      await Future.wait([
        _fetchLatestPets(),
        _fetchLatestPosts(),
      ]);
    } else {
      // Handle the case where refresh failed (user might be logged out)
    }
  }

  Future<bool> _refreshTokenIfNeeded() async {
    // Check if we even have a token that might need refreshing
    final jwt = await _secureStorage.read(key: 'jwt');
    if (jwt != null) {
      return true; // Token is still valid
    }

    setState(() {
      _isRefreshingToken = true;
    });

    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        print('No refresh token found');
        await _handleTokenExpired();
        return false;
      }

      final uri = Uri.parse(ApiConfig.refreshToken);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newToken = responseData['token'];

        // Validate the new token before storing
        if (newToken == null || newToken.isEmpty) {
          throw Exception('Invalid token received');
        }

        await _secureStorage.write(key: 'jwt', value: newToken);
        print('Token refreshed successfully');
        return true;
      } else {
        print('Failed to refresh token: ${response.statusCode}');
        await _handleTokenExpired();
        return false;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      await _handleTokenExpired();
      return false;
    } finally {
      setState(() {
        _isRefreshingToken = false;
      });
    }
  }

  Future<void> _handleTokenExpired() async {
    // Clear all stored tokens
    await _secureStorage.delete(key: 'jwt');
    await _secureStorage.delete(key: 'refresh_token');

    // Show error message
    Get.snackbar(
      'Session Expired',
      'Please log in again',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );

    // Navigate to login screen
    // Replace 'LoginScreen' with your actual login route
    Get.offAllNamed('/login');
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
          petsListedCounts = pets.toList().length;
          adoptionsCounts = pets.where((pet) => pet.status == 'adopted').length;
          _pets = pets.take(2).toList();
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
          _communityPosts =
              postJson.map((json) => Post.fromJson(json)).take(1).toList();
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
                                      post: post,
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
                      '🐶 $petsListedCounts pets listed | 🐾 $adoptionsCounts adoptions',
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
