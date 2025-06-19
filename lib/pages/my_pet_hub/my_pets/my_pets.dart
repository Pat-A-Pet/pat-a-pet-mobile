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
import 'package:pat_a_pet/pages/my_pet_hub/my_pets/create_edit_pet_listing.dart';

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
      print("${response.body}");
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

  void _showCreateNewPetListing() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: CreateEditPetListingScreen(
          onPetCreated: _fetchUserPets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "My Pets",
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: ConstantsColors.textPrimary),
            // onPressed: () => {Get.to(CreatePetListing1())},
            onPressed: () => {_showCreateNewPetListing()},
          ),
        ],
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
                              childAspectRatio: 0.52,
                            ),
                            itemBuilder: (context, index) {
                              final pet = _pets[index];
                              return YourPetCard(
                                pet: pet,
                                onRequestUpdated: () => _fetchUserPets(),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
