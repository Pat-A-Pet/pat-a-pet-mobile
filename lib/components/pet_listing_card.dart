import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/instance_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pat_a_pet/components/strocked_icon.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/models/pet.dart';
import 'package:pat_a_pet/pages/pet_detail_page.dart';

class PetListingCard extends StatefulWidget {
  final Pet pet;

  const PetListingCard({super.key, required this.pet});

  @override
  State<PetListingCard> createState() => _PetListingCardState();
}

class _PetListingCardState extends State<PetListingCard> {
  final _secureStorage = FlutterSecureStorage();
  final userController = Get.find<UserController>();
  bool _isLoved = false;
  bool _isLoading = false;
  int _loveCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeLoveStatus();
  }

  Future<void> _initializeLoveStatus() async {
    final userId = userController.id;
    setState(() {
      _isLoved = widget.pet.loves.contains(userId);
      _loveCount = widget.pet.loves.length;
    });
  }

  Future<void> _toggleLove() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _secureStorage.read(key: "jwt");
      final response = await http.patch(
        Uri.parse(ApiConfig.lovePetListing(widget.pet.id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("statuscode: ${response.statusCode}");
      print("body: ${response.body}");

      if (response.statusCode == 200) {
        final updatedPet = Pet.fromJson(jsonDecode(response.body));
        final userId = userController.id;

        setState(() {
          _isLoved = updatedPet.loves.contains(userId);
          _loveCount = updatedPet.loves.length;
        });
      } else {
        throw Exception('Failed to toggle love');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PetDetailPage(pet: widget.pet)));
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    widget.pet.imageUrls[0],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleLove,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.redAccent),
                              ),
                            )
                          : Icon(
                              _isLoved ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: _isLoved ? Colors.redAccent : Colors.grey,
                            ),
                    ),
                  ),
                ),
                if (_loveCount > 0)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_loveCount ♥',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pet.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const StrokedIcon(
                          strokeColor: Colors.black,
                          strokeWidth: 0.6,
                          icon: Icons.location_on,
                          size: 16,
                          fillColor: ConstantsColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        widget.pet.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ConstantsColors.textPrimary,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

