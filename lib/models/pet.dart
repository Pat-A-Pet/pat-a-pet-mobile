class Pet {
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

  Pet({
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
  });
}
