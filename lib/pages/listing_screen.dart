import 'package:flutter/material.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/pet_listing_card.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/models/pet.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Cat', 'icon': Icons.pets, 'color': Colors.orange},
    {'name': 'Dog', 'icon': Icons.pets, 'color': Colors.blue},
    {'name': 'Turtle', 'icon': Icons.pets, 'color': Colors.green},
    {'name': 'Hamster', 'icon': Icons.pets, 'color': Colors.purple},
  ];

  String _selectedCategory = 'Cat';

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
            Text(
              "Pet Categories",
              style: TextStyle(
                fontFamily: "Nunito",
                fontSize: 20,
                color: ConstantsColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildPetCategory(
                    category['name'],
                    category['icon'],
                    category['color'],
                    _selectedCategory == category['name'],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Listings for $_selectedCategory",
              style: TextStyle(
                fontFamily: "Nunito",
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
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

  Widget _buildPetCategory(
      String name, IconData icon, Color color, bool selected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = name;
        });
      },
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color:
              selected ? ConstantsColors.primary : ConstantsColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? ConstantsColors.primary : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : ConstantsColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
