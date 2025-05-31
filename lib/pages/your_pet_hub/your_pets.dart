import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/your_pet_card.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/models/pet.dart';

class MyPets extends StatefulWidget {
  const MyPets({super.key});

  @override
  State<MyPets> createState() => _MyPetsState();
}

class _MyPetsState extends State<MyPets> {
  List<Pet> _pets = [];
  bool _isLoading = false;
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _fetchUserPets();
  }

  Future<void> _fetchUserPets() async {
    setState(() {
      _isLoading = true;
    });

    final uri =
        Uri.parse('${ApiConfig.getAllPetListings}?owner=${userController.id}');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> petJson = jsonDecode(response.body);
        final pets = petJson.map((json) => Pet.fromJson(json)).toList();

        setState(() {
          _pets = pets;
        });
      } else {
        print('Failed to load your pets: ${response.body}');
      }
    } catch (e) {
      print('Error fetching your pets: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCreateNewPetListingDialog() {
    final _formKey = GlobalKey<FormState>();
    String imagePath = 'assets/images/logo.png'; // placeholder image
    String name = '';
    String location = '';
    String sex = '';
    String color = '';
    String breed = '';
    String weight = '';
    String description = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Create New Pet Listing'),
          content: Form(
            key: _formKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Column(
                children: [
                  // Image picker placeholder button (just for demo)
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.image,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Pick Image(s)',
                      style:
                          TextStyle(fontFamily: "Nunito", color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ConstantsColors.primary),
                  ),
                  // Pet name
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) => name = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                  ),

                  // Location
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Location'),
                    onChanged: (value) => location = value,
                  ),

                  // Sex
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Sex'),
                    onChanged: (value) => sex = value,
                  ),

                  // Color
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Color'),
                    onChanged: (value) => color = value,
                  ),

                  // Breed
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Breed'),
                    onChanged: (value) => breed = value,
                  ),

                  // Weight
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Weight'),
                    onChanged: (value) => weight = value,
                  ),

                  // Description
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onChanged: (value) => description = value,
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // setState(() {
                  //   pets.add(
                  //     Pet(
                  //       imagePath: imagePath,
                  //       name: name,
                  //       location: location,
                  //       sex: sex,
                  //       color: color,
                  //       breed: breed,
                  //       weight: weight,
                  //       owner: "John Doe",
                  //       description: description,
                  //     ),
                  //   );
                  // });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantsColors.primary),
              child: const Text(
                'Add Pet',
                style: TextStyle(fontFamily: "Nunito", color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "My Pets",
      ),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _pets.isEmpty
                        ? const Center(
                            child: Text(
                              'You haven\'t listed any pets yet.',
                              style: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                        : GridView.builder(
                            itemCount: _pets.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.60,
                            ),
                            itemBuilder: (context, index) {
                              final pet = _pets[index];
                              return YourPetCard(pet: pet);
                            },
                          ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          right: MediaQuery.of(context).size.width * 0.43,
          left: MediaQuery.of(context).size.width * 0.43,
          child: FloatingActionButton(
            onPressed: () {
              _showCreateNewPetListingDialog();
            },
            backgroundColor: ConstantsColors.primary,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ]),
    );
  }
}
