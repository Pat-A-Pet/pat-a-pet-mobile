class Pet {
  String id;
  List<dynamic> imageUrls;
  String name;
  String location;
  String sex;
  String color;
  String breed;
  String weight;
  Owner owner;
  String description;
  AdoptedBy? adoptedBy;
  String status;
  String species;
  DateTime createdAt;
  int age;
  bool vaccinated;
  bool neutered;
  bool microchipped;
  String medicalConditions;
  String specialNeeds;
  int adoptionFee;
  bool adopted;
  DateTime updatedAt;
  List<String> loves;
  List<AdoptionRequest>? adoptionRequests;

  Pet(
      {required this.id,
      required this.imageUrls,
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
      required this.age,
      required this.vaccinated,
      required this.neutered,
      required this.microchipped,
      required this.medicalConditions,
      required this.specialNeeds,
      required this.adoptionFee,
      required this.adopted,
      required this.updatedAt,
      required this.loves,
      this.adoptionRequests = const []});

  factory Pet.fromJson(Map<String, dynamic> json) {
    // Helper function to parse dates safely
    DateTime parseDateTime(dynamic dateData) {
      if (dateData == null) return DateTime.now();

      try {
        // Handle MongoDB-style date format
        if (dateData is Map) {
          final dateObj = dateData['\$date'];
          if (dateObj is Map) {
            final numberLong = dateObj['\$numberLong']?.toString();
            if (numberLong != null) {
              return DateTime.fromMillisecondsSinceEpoch(int.parse(numberLong));
            }
          }
          // Handle simple timestamp format
          final numberLong = dateData['\$numberLong']?.toString();
          if (numberLong != null) {
            return DateTime.fromMillisecondsSinceEpoch(int.parse(numberLong));
          }
        }
        // Handle direct string timestamps
        if (dateData is String && dateData.isNotEmpty) {
          final milliseconds = int.tryParse(dateData);
          if (milliseconds != null) {
            return DateTime.fromMillisecondsSinceEpoch(milliseconds);
          }
          return DateTime.parse(dateData);
        }
        // Handle direct integer timestamps
        if (dateData is int) {
          return DateTime.fromMillisecondsSinceEpoch(dateData);
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
      return DateTime.now();
    }

    // Helper to parse integers safely
    int parseInt(dynamic intData) {
      if (intData == null) return 0;

      try {
        if (intData is int) return intData;
        if (intData is String) return int.tryParse(intData) ?? 0;

        // Handle MongoDB-style integers
        if (intData is Map) {
          final numberInt = intData['\$numberInt']?.toString();
          if (numberInt != null) return int.tryParse(numberInt) ?? 0;
        }
      } catch (e) {
        print('Error parsing integer: $e');
      }
      return 0;
    }

    List<AdoptionRequest> parseAdoptionRequests(dynamic requestsData) {
      if (requestsData == null || requestsData is! List) return [];

      return requestsData.map((req) {
        if (req is Map<String, dynamic>) {
          return AdoptionRequest.fromJson(req);
        }
        return AdoptionRequest.fromJson({});
      }).toList();
    }

    dynamic adoptedByData = json['adoptedBy'];
    AdoptedBy? adoptedBy;
    if (adoptedByData is Map) {
      adoptedBy = AdoptedBy.fromJson(adoptedByData.cast<String, dynamic>());
    } else if (adoptedByData is String) {
      adoptedBy = AdoptedBy(id: adoptedByData, fullname: '');
    }

    return Pet(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrls: (json['imageUrls'] is List)
          ? (json['imageUrls'] as List).map((e) => e.toString()).toList()
          : [],
      species: json['species']?.toString() ?? '',
      breed: json['breed']?.toString() ?? '',
      age: parseInt(json['age']),
      sex: json['gender']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      vaccinated: json['vaccinated'] == true,
      neutered: json['neutered'] == true,
      microchipped: json['microchipped'] == true,
      medicalConditions: json['medicalConditions']?.toString() ?? '-',
      specialNeeds: json['specialNeeds']?.toString() ?? '-',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      owner: Owner.fromJson(json['owner'] is Map ? json['owner'] : {}),
      adopted: json['adopted'] == true,
      adoptedBy: adoptedBy,
      status: json['status']?.toString() ?? 'Available',
      loves: (json['loves'] is List)
          ? (json['loves'] as List).map((e) => e.toString()).toList()
          : [],
      adoptionFee: parseInt(json['adoptionFee']),
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
      adoptionRequests: parseAdoptionRequests(json['adoptionRequests']),
    );
  }
}

class AdoptionRequest {
  final String id;
  final String userId;
  final String status;
  final String? channelId; // Add this field
  final DateTime createdAt;
  final DateTime? updatedAt;

  AdoptionRequest({
    required this.id,
    required this.userId,
    required this.status,
    this.channelId, // Add to constructor
    required this.createdAt,
    this.updatedAt,
  });

  factory AdoptionRequest.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic dateData) {
      if (dateData == null) return DateTime.now();

      try {
        // Handle MongoDB-style date format
        if (dateData is Map) {
          final dateObj = dateData['\$date'];
          if (dateObj is Map) {
            final numberLong = dateObj['\$numberLong']?.toString();
            if (numberLong != null) {
              return DateTime.fromMillisecondsSinceEpoch(int.parse(numberLong));
            }
          }
          // Handle simple timestamp format
          final numberLong = dateData['\$numberLong']?.toString();
          if (numberLong != null) {
            return DateTime.fromMillisecondsSinceEpoch(int.parse(numberLong));
          }
        }
        // Handle direct string timestamps
        if (dateData is String && dateData.isNotEmpty) {
          final milliseconds = int.tryParse(dateData);
          if (milliseconds != null) {
            return DateTime.fromMillisecondsSinceEpoch(milliseconds);
          }
          return DateTime.parse(dateData);
        }
        // Handle direct integer timestamps
        if (dateData is int) {
          return DateTime.fromMillisecondsSinceEpoch(dateData);
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
      return DateTime.now();
    }

    return AdoptionRequest(
      id: json['_id']?.toString() ?? '',
      userId: json['user'] is String
          ? json['user']
          : json['user']?['_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      channelId: json['channelId']?.toString(), // Parse channelId
      createdAt: parseDateTime(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? parseDateTime(json['updatedAt']) : null,
    );
  }
}

class AdoptedBy {
  final String id;
  final String fullname;
  final String? profilePictureUrl;

  AdoptedBy({
    required this.id,
    required this.fullname,
    this.profilePictureUrl,
  });

  factory AdoptedBy.fromJson(Map<String, dynamic> json) {
    return AdoptedBy(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? '',
      profilePictureUrl: json['profilePictureUrl']?.toString(),
    );
  }
}

class Owner {
  final String id;
  final String fullname;
  final String email;

  Owner({
    required this.id,
    required this.fullname,
    required this.email,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['_id']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}
