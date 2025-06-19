class Post {
  final String id;
  final Author author;
  final String captions;
  final List<String> imageUrls;
  final List<String> loves;
  final List<Comment> comments;
  final String createdAt;
  final String updatedAt;

  Post({
    required this.id,
    required this.author,
    required this.captions,
    required this.imageUrls,
    List<String>? loves,
    List<Comment>? comments,
    required this.createdAt,
    required this.updatedAt,
  })  : loves = loves ?? [],
        comments = comments ?? [];

  factory Post.fromJson(Map<String, dynamic> json) {
    List<Comment> parsedComments = [];
    if (json['comments'] != null && json['comments'] is List) {
      parsedComments = (json['comments'] as List).map((comment) {
        try {
          if (comment is Map<String, dynamic>) {
            return Comment.fromJson(comment);
          }
          return Comment(
            id: '',
            author:
                Author(id: '', fullname: 'Unknown', profilePictureUrl: null),
            text: comment?.toString() ?? '',
            createdAt: '',
          );
        } catch (e) {
          print('Error parsing comment: $e');
          return Comment(
            id: '',
            author:
                Author(id: '', fullname: 'Unknown', profilePictureUrl: null),
            text: '',
            createdAt: '',
          );
        }
      }).toList();
    }

    return Post(
      id: json['_id'] ?? '',
      author: Author.fromJson(json['author'] ?? {}),
      captions: json['captions'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      loves: json['loves'] != null ? List<String>.from(json['loves']) : [],
      comments: parsedComments,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author': author.toJson(),
      'captions': captions,
      'imageUrls': imageUrls,
      'loves': loves,
      'comments': comments.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Author {
  final String id;
  final String fullname;
  final String? profilePictureUrl; // Changed from avatar to profilePictureUrl

  Author({
    required this.id,
    required this.fullname,
    this.profilePictureUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['_id'] ?? '',
      fullname: json['fullname'] ?? 'Unknown',
      profilePictureUrl: json['profilePictureUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullname': fullname,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}

class Comment {
  final String id;
  final Author author;
  final String text; // Keep as text internally, but map from 'comment'
  final String createdAt;

  Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id']?.toString() ?? '',
      author: Author.fromJson(json['author'] is Map ? json['author'] : {}),
      text: json['comment']?.toString() ?? '', // Changed from text to comment
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author': author.toJson(),
      'comment': text, // Map back to 'comment' for backend
      'createdAt': createdAt,
    };
  }
}
