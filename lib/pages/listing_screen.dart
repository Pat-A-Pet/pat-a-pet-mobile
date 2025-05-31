import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/components/pet_listing_card.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/models/pet.dart';
import 'package:pat_a_pet/configs/api_config.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  List<Map<String, dynamic>> _categories = [];
  String _selectedCategory = '';
  List<Pet> _pets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse(ApiConfig.getAllPetCategories);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> categoryJson = jsonDecode(response.body);

        final categories = categoryJson.map((name) {
          return {
            'name': name,
            'icon': Icons.pets, // or assign icons dynamically if desired
            'color': Colors.grey, // or assign colors dynamically
          };
        }).toList();

        setState(() {
          _categories = categories;
          if (categories.isNotEmpty) {
            _selectedCategory = categories.first['name'];
            _fetchPets();
          }
        });
      } else {
        print('Failed to load categories: ${response.body}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPets() async {
    setState(() {
      _isLoading = true;
    });

    final uri =
        Uri.parse('${ApiConfig.getAllPetListings}?species=$_selectedCategory');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> petJson = jsonDecode(response.body);
        final pets = petJson.map((json) => Pet.fromJson(json)).toList();
        setState(() {
          _pets = pets;
        });
      } else {
        print('Failed to load pets: ${response.body}');
      }
    } catch (e) {
      print('Error fetching pets: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _fetchPets();
  }

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
              child: _categories.isEmpty
                  ? const Center(
                      child: Text(
                      "No categories found",
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ))
                  : ListView.separated(
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
            _categories.isNotEmpty
                ? Text(
                    "Listings for $_selectedCategory",
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : SizedBox.shrink(),
            const SizedBox(height: 12),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _pets.isEmpty
                        ? const Center(
                            child: Text(
                            "No pets found",
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
                              return AnimatedOpacity(
                                opacity: 1.0,
                                duration:
                                    Duration(milliseconds: 300 + index * 100),
                                child: PetListingCard(pet: pet),
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
      onTap: () => _onCategorySelected(name),
      borderRadius: BorderRadius.circular(40),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : ConstantsColors.textPrimary,
              ),
              child: Text(name),
            ),
          ],
        ),
      ),
    );
  }
}
