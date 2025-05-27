import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/configs/api_config.dart';

class UserController extends GetxController {
  final user = <dynamic, dynamic>{}.obs;
  final _secureStorage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    loadPersistedData();
  }

  String get id => user['_id']?.toString() ?? '';
  String get fullname => user['fullname'] ?? '';
  String get email => user['email'] ?? '';
  String get profilePictureUrl => user['profilePictureUrl'] ?? '';

  void setUser(Map<String, dynamic> userData) async {
    user.value = userData;
    // Sync profile image with secure storage when setting new user data
    await _secureStorage.write(key: 'userData', value: jsonEncode(userData));
    if (userData.containsKey('profilePictureUrl')) {
      _secureStorage.write(
          key: 'profilePictureUrl', value: userData['profilePictureUrl']);
    }
  }

  Future<void> fetchUserProfile(String token) async {
    final url = Uri.parse(ApiConfig.profile);

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setUser(responseData['user']);
        print('User profile fetched and set.');
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> loadPersistedData() async {
    final storedImage = await _secureStorage.read(key: 'profilePictureUrl');
    final storedToken = await _secureStorage.read(key: 'jwt');
    final storedUserData = await _secureStorage.read(key: 'userData');
    if (storedUserData != null) {
      user.value = jsonDecode(storedUserData);
    }
    if (storedToken != null) {
      await fetchUserProfile(storedToken);
    }
    if (storedImage != null) {
      user['profilePictureUrl'] = storedImage;
    }
  }

  Future<void> updateProfilePicture(String userId, String imageUrl) async {
    final url = ApiConfig.updateProfilePicture(userId);

    String? authToken = await _secureStorage.read(key: 'jwt');

    if (authToken == null) {
      Get.snackbar('Error', 'No auth token found. Please log in again.');
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'profilePictureUrl': imageUrl}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final updatedUser = responseData['user'];

        // Update locall// Update both local state and secure storage
        setUser(updatedUser);
        await _secureStorage.write(key: 'profilePictureUrl', value: imageUrl);
        user.refresh(); // Notify listeners about the updatey stored user data if needed
        Get.snackbar('Success', 'Profile picture updated');
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        Get.snackbar('Failed', errorMessage ?? 'Update failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }
}
