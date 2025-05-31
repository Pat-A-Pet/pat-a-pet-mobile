class Post {
  final String id;
  final Author author;
  final String captions;
  final List<String> imageUrls;
  final List<String>? videoUrls;
  final List<String>? loves;
  final List<Comment>? comments;
  final String createdAt;
  final String updatedAt;

  Post({
    required this.id,
    required this.author,
    required this.captions,
    required this.imageUrls,
    this.videoUrls,
    this.loves,
    this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      author: Author.fromJson(json['author']),
      captions: json['captions'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      videoUrls: json['videoUrls'] != null
          ? List<String>.from(json['videoUrls'])
          : null,
      loves: json['loves'] != null ? List<String>.from(json['loves']) : null,
      comments: json['comments'] != null
          ? (json['comments'] as List).map((e) => Comment.fromJson(e)).toList()
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class Author {
  final String id;
  final String fullname;
  final String? profilePictureUrl;

  Author({
    required this.id,
    required this.fullname,
    this.profilePictureUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['_id'],
      fullname: json['fullname'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }
}

class Comment {
  final String comment;
  final Author author;

  Comment({
    required this.comment,
    required this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      comment: json['comment'],
      author: Author.fromJson(json['author']),
    );
  }
}
