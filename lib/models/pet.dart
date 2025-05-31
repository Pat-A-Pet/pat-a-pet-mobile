class Pet {
  String id;
  String imagePath;
  String name;
  String location;
  String sex;
  String color;
  String breed;
  String weight;
  String owner;
  String description;
  String? adoptedBy;
  String status;
  String species;
  DateTime createdAt;
  List<String> likes;

  Pet({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.location,
    required this.sex,
    required this.color,
    required this.breed,
    required this.weight,
    required this.owner,
    required this.description,
    this.adoptedBy,
    this.status = "Available",
    required this.species,
    required this.createdAt,
    required this.likes,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['_id'] ?? '',
      imagePath: json['imagePath'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      sex: json['sex'] ?? '',
      color: json['color'] ?? '',
      breed: json['breed'] ?? '',
      weight: json['weight'] ?? '',
      owner: json['owner'] ?? '',
      description: json['description'] ?? '',
      adoptedBy: json['adoptedBy'],
      status: json['status'] ?? 'Available',
      species: json['species'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      likes: List<String>.from(json['likes'] ?? []),
    );
  }
}
