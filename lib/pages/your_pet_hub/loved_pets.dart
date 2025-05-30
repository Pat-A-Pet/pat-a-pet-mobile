import 'package:flutter/material.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/pet_listing_card.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/models/pet.dart';

class LovedPets extends StatefulWidget {
  const LovedPets({super.key});

  @override
  State<LovedPets> createState() => _LovedPetsState();
}

class _LovedPetsState extends State<LovedPets> {
  final pets = [
    Pet(
      imagePath: 'assets/images/logo.png',
      name: 'Buddy',
      location: 'New York',
      sex: 'Male',
      color: 'Brown',
      breed: 'Golden Retriever',
      weight: '25kg',
      owner: 'John Doe',
      description: 'A friendly and playful dog that loves the outdoors.',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: pets.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return PetListingCard(
                    pet: pet,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
