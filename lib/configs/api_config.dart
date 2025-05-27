class ApiConfig {
// Development (Local Machine)
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android Emulator
  static const String url = 'http://10.0.2.2:5000'; // Android Emulator

  static const String signup = '$baseUrl/auth/signup';
  static const String signin = '$baseUrl/auth/signin';
  static const String profile = '$baseUrl/auth/profile';
  static const String uploadProfilePicture =
      '$baseUrl/upload-image/upload-profile-picture';
  static String updateProfilePicture(String userId) =>
      '$baseUrl/upload-image/users/$userId/profile-picture';
  static String fetchChatToken = '$baseUrl/chat/chatToken';
}
