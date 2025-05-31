class ApiConfig {
  // Development (Local Machine)
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android Emulator
  static const String url = 'http://10.0.2.2:5000'; // Android Emulator

  // auth
  static const String signup = '$baseUrl/auth/signup';
  static const String signin = '$baseUrl/auth/signin';
  static const String profile = '$baseUrl/auth/profile';

  // profile picture
  static const String uploadProfilePicture =
      '$baseUrl/upload-image/upload-profile-picture';
  static String updateProfilePicture(String userId) =>
      '$baseUrl/upload-image/users/$userId/profile-picture';

  // getstreams
  static String fetchChatToken = '$baseUrl/chat/chatToken';

  // Pet Listings
  static const String createPetListing = '$baseUrl/pets/create-listing';
  static const String getAllPetListings = '$baseUrl/pets/get-listings';
  static const String getAllPetCategories = '$baseUrl/pets/categories';
  static String getAllLovedPets(String userId) =>
      '$baseUrl/pets/get-loved-pets/$userId';
  // static String getPetListingById(String id) => '$baseUrl/pets/get-listing/$id';
  static String updatePetListing(String id) =>
      '$baseUrl/pets/update-listing/$id';
  static String deletePetListing(String id) =>
      '$baseUrl/pets/delete-listing/$id';

  // Posts
  static const String createPost = '$baseUrl/posts/create-post';
  static const String getAllPosts = '$baseUrl/posts/get-posts';
  static String getAllUserPosts(String userId) =>
      '$baseUrl/pets/get-my-posts/$userId';
  static String getAllLovedPosts(String userId) =>
      '$baseUrl/pets/get-loved-posts/$userId';
  // static String getPostById(String id) => '$baseUrl/posts/get-posts/$id';
  static String updatePost(String id) => '$baseUrl/posts/update-post/$id';
  static String deletePost(String id) => '$baseUrl/posts/delete-post/$id';
  static String addCommentToPost(String id) =>
      '$baseUrl/posts/update-post/$id/comments';
  static String likeOrUnlikePost(String id) =>
      '$baseUrl/posts/update-post/$id/like';
}
