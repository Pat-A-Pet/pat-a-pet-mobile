import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/pet_listing_card.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/models/pet.dart';

class LovedPets extends StatefulWidget {
  const LovedPets({super.key});

  @override
  State<LovedPets> createState() => _LovedPetsState();
}

class _LovedPetsState extends State<LovedPets> {
  List<Pet> _pets = [];
  bool _isLoading = false;
  final userController = Get.find<UserController>();
  final _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchLovedPets();
  }

  Future<void> _fetchLovedPets() async {
    final token = await _secureStorage.read(key: 'jwt');
    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse(ApiConfig.getAllLovedPets(userController.id));

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("statusCode: ${response.statusCode}");
      print("body: ${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> petJson = jsonDecode(response.body);
        final pets = petJson.map((json) => Pet.fromJson(json)).toList();

        setState(() {
          _pets = pets;
        });
      } else {
        print('Failed to load loved pets: ${response.body}');
      }
    } catch (e) {
      print('Error fetching loved pets: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Loved Pets",
      ),
      body: Padding(
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
                          'No loved pets yet',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ))
                      : GridView.builder(
                          itemCount: _pets.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemBuilder: (context, index) {
                            final pet = _pets[index];
                            return PetListingCard(pet: pet);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
