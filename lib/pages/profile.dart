import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pat_a_pet/components/navigation_menu.dart';
import 'package:pat_a_pet/components/strocked_icon.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/pages/signin/signin_screen.dart';
import 'package:http/http.dart' as http;
import 'package:pat_a_pet/pages/your_pet_hub/loved_pets.dart';
import 'package:pat_a_pet/pages/your_pet_hub/your_activities.dart';
import 'package:pat_a_pet/pages/your_pet_hub/your_pets.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final userController = Get.find<UserController>();
  final secureStorage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  bool _isLoading = false;

  Future<void> logoutUser() async {
    await secureStorage.delete(key: 'jwt'); // Remove the token
    await secureStorage.delete(key: 'profilePictureUrl'); // Remove the token
    await secureStorage.delete(key: 'refreshToken'); // Remove the token
    await secureStorage.delete(key: 'userData'); // Remove the token
    Get.delete<NavigationController>();
    Get.offAll(() => const SigninScreen()); // Navigate to login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantsColors.background,
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: () =>
                                        {pickImageGallery(context)},
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(10),
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    ),
                                    child: Obx(() {
                                      return (_imagePath == null &&
                                              userController
                                                  .profilePictureUrl.isEmpty)
                                          ? const Icon(
                                              Icons.person,
                                              size: 90,
                                              color: Colors.black,
                                            )
                                          : CircleAvatar(
                                              radius: 45,
                                              backgroundImage: NetworkImage(
                                                userController
                                                    .profilePictureUrl,
                                              ),
                                            );
                                    }),
                                  ),
                          ),
                          if (!_isLoading)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: ConstantsColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userController.fullname,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: "Nunito"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Your Pet Hub'),
                  _buildSettingItem(
                      OnTap: () => (Get.to(YourPets())),
                      icon: Icons.pets,
                      title: 'Your Pets',
                      color: ConstantsColors.secondary,
                      titleColor: ConstantsColors.textPrimary),
                  _buildSettingItem(
                      OnTap: () => (Get.to(LovedPets())),
                      icon: Icons.favorite,
                      title: 'Loved Pets',
                      color: ConstantsColors.secondary,
                      titleColor: ConstantsColors.textPrimary),
                  _buildSettingItem(
                      OnTap: () => (Get.to(YourActivities())),
                      icon: Icons.interests,
                      title: 'Your Activities',
                      color: ConstantsColors.secondary,
                      titleColor: ConstantsColors.textPrimary),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Keluar'),
                  _buildSettingItem(
                    OnTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Alert!",
                                style: TextStyle(
                                    fontFamily: "Nunito",
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                            content: const Text(
                                "Are you sure you want to quit?",
                                style: TextStyle(
                                    fontFamily: "PT Sans",
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            actions: <Widget>[
                              TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                    (Set<WidgetState> states) {
                                      if (states
                                          .contains(WidgetState.pressed)) {
                                        return ConstantsColors.primary;
                                      }
                                      return Colors
                                          .transparent; // default color
                                    },
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "No",
                                  style: TextStyle(
                                      fontFamily: "Nunito",
                                      fontSize: 14,
                                      color: Colors.black),
                                ),
                              ),
                              TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color?>(
                                    (Set<WidgetState> states) {
                                      if (states
                                          .contains(WidgetState.pressed)) {
                                        return ConstantsColors
                                            .secondary; // color when pressed
                                      }
                                      return Colors
                                          .transparent; // default color
                                    },
                                  ),
                                ),
                                onPressed: () {
                                  logoutUser();
                                },
                                //onPressed: () =>
                                //    Get.to(() => const LoginScreen()),
                                child: const Text("Sure",
                                    style: TextStyle(
                                        fontFamily: "Nunito",
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Colors.red,
                    titleColor: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadImage(XFile image) async {
    final uri = Uri.parse(ApiConfig.uploadProfilePicture);
    final request = http.MultipartRequest('POST', uri);
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);

        String? authToken = await secureStorage.read(key: 'jwt');

        if (authToken == null) {
          Get.snackbar('Error', 'No auth token found. Please log in again.');
          setState(() => _isLoading = false);
          return;
        }

        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));

        request.headers.addAll({
          'Authorization': "Bearer $authToken",
          'Content-Type': 'multipart/form-data'
        });

        final response = await request.send();

        final responseBody = await response.stream.bytesToString();

        print('Response status code: ${response.statusCode}');
        print('Response body: $responseBody');

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(responseBody);
          final imageUrl = data['profilePicture']['cloudinaryUrl'];

          if (imageUrl != null) {
            userController.updateProfilePicture(userController.id, imageUrl);
            setState(() {
              _imagePath = image.path;
            });
            Get.snackbar('Success', 'Profile picture updated successfully!');
            // );
          } else {
            print("Image URL not found in response: $data");
            Get.snackbar('Upload error', "Failed to retrieve image URL");
          }
        }
      } on SocketException {
        Get.snackbar('Error', 'No internet connection');
      } on TimeoutException {
        Get.snackbar('Error', 'Connection timeout');
      } catch (e) {
        // Add detailed error logging
        print('Registration Error: $e');
        if (e is http.ClientException) {
          Get.snackbar('Error', 'Connection failed: ${e.message}');
        } else {
          Get.snackbar('Error', 'An unexpected error occurred: $e');
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> pickImageGallery(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Optional: reduce quality to save space
      );

      if (image != null) {
        print('Gallery image selected: ${image.path}');
        // TODO: Do something with the selected image
        CroppedFile? croppedImage =
            await ImageCropper().cropImage(sourcePath: image.path, uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: ConstantsColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset
                  .square, // Crop to square (circle for avatar)
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ]);

        if (croppedImage != null) {
          // Upload the cropped image
          _uploadImage(XFile(croppedImage.path));
        }
      }
    } catch (e) {
      print("Error picking image from gallery: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Gallery Error"),
          content: const Text(
              "Failed to access photo gallery. Please check permissions."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: "Nunito",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required VoidCallback OnTap,
    required IconData icon,
    required String title,
    required Color color,
    Color? titleColor,
  }) {
    return GestureDetector(
      onTap: OnTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: StrokedIcon(
              icon: icon,
              size: 20,
              strokeColor: Colors.black,
              strokeWidth: 0.5,
              fillColor: color,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
                fontFamily: "Nunito",
                color: titleColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
