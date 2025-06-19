class ApiConfig {
  // Development (Local Machine)
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android Emulator
  static const String url = 'http://10.0.2.2:5000'; // Android Emulator

  // auth
  static const String signup = '$baseUrl/auth/signup';
  static const String signin = '$baseUrl/auth/signin';
  static const String profile = '$baseUrl/auth/profile';
  static const String refreshToken = '$baseUrl/auth/refresh-token';

  // profile picture
  static const String uploadProfilePicture =
      '$baseUrl/upload-image/upload-profile-picture';
  static String updateProfilePicture(String userId) =>
      '$baseUrl/upload-image/users/$userId/profile-picture';

  // getstreams
  static String fetchChatToken = '$baseUrl/chat/chatToken';
  static String createChannel = '$baseUrl/chat/create-channel';

  // Pet Listings
  static const String createPetListing = '$baseUrl/pets/create-listing';
  static const String uploadPetImages = '$baseUrl/pets/upload-pet-images';
  static const String getAllPetListings = '$baseUrl/pets/get-listings';
  static String getPetListingById(String id) => '$baseUrl/pets/get-listing/$id';
  static const String getAllPetCategories = '$baseUrl/pets/categories';
  static String getAllLovedPets(String userId) =>
      '$baseUrl/pets/get-loved-pets/$userId';
  static String updatePetListing(String id) =>
      '$baseUrl/pets/update-listing/$id';
  static String deletePetListing(String petId) =>
      '$baseUrl/pets/delete-listing/$petId';
  static String lovePetListing(String petId) => '$baseUrl/pets/pet-love/$petId';
  static String getAllAdoptionsBuyer(String userId) =>
      '$baseUrl/pets/get-all-adoptions-buyer/$userId';
  static String requestAdoption(String petId) =>
      '$baseUrl/pets/request-adoption/$petId';
  static String cancelRequestAdoption(String petId) =>
      '$baseUrl/pets/cancel-request-adoption/$petId';
  static String updateRequestStatus(String petId, String requestId) =>
      "$baseUrl/pets/update-request-status/$petId/$requestId";
  static String getAllAdoptionsOwner(String petId) =>
      '$baseUrl/pets/get-adoption-requests/$petId';

  // Posts
  static const String createPost = '$baseUrl/posts/create-post';
  static const String getAllPosts = '$baseUrl/posts/get-posts';
  static String getAllUserPosts(String userId) =>
      '$baseUrl/posts/get-my-posts/$userId';
  static String getAllLovedPosts(String userId) =>
      '$baseUrl/posts/get-loved-posts/$userId';
  static String deletePost(String postId) =>
      '$baseUrl/posts/delete-post/$postId';
  static String addCommentToPost(String postId) =>
      '$baseUrl/posts/post-comments/$postId/';
  static String lovePostListing(String postId) =>
      '$baseUrl/posts/post-love/$postId';
}
