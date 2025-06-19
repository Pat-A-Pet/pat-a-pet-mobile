import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pat_a_pet/components/strocked_icon.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/models/pet.dart';

class PetDetailPage extends StatefulWidget {
  final Pet pet;

  const PetDetailPage({super.key, required this.pet});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  int currentPage = 0;
  final PageController pageController = PageController();
  final userController = Get.find<UserController>();
  final secureStorage = FlutterSecureStorage();
  bool hasRequestedAdoption = false;
  bool isLoadingRequestStatus = true;

  @override
  void initState() {
    super.initState();
    _checkAdoptionRequestStatus();
  }

  Future<void> _checkAdoptionRequestStatus() async {
    try {
      final token = await secureStorage.read(key: "jwt");
      final response = await http.get(
        Uri.parse(ApiConfig.getPetListingById(widget.pet.id)),
        headers: {
          'Authorization': "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final petData = json.decode(response.body);
        print("post: $petData");
        final List<dynamic> adoptionRequests =
            petData['adoptionRequests'] ?? [];

        setState(() {
          hasRequestedAdoption = adoptionRequests.any(
              (request) => request['user'].toString() == userController.id);
          isLoadingRequestStatus = false;
        });
      } else {
        setState(() {
          isLoadingRequestStatus = false;
        });
        Get.snackbar('Error', 'Failed to check adoption status');
      }
    } catch (e) {
      setState(() {
        isLoadingRequestStatus = false;
      });
      Get.snackbar('Error', 'Failed to check adoption status');
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _requestAdoption() async {
    try {
      final token = await secureStorage.read(key: "jwt");
      final response = await http.post(
        Uri.parse(ApiConfig.requestAdoption(widget.pet.id)),
        headers: {
          'Authorization': "Bearer $token",
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'userId': userController.id,
        }),
      );

      print("body: ${response.body}");
      print("statusCode: ${response.statusCode}");

      if (response.statusCode == 201) {
        await _checkAdoptionRequestStatus();
        Get.snackbar(
          'Success',
          'Adoption request sent!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        setState(() {}); // Refresh UI
      } else {
        final error = json.decode(response.body)['message'];
        Get.snackbar('Error', error);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send request');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: ConstantsColors.background,
            expandedHeight: 300,
            flexibleSpace: LayoutBuilder(builder: (context, constraints) {
              return Stack(children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: widget.pet.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.network(
                      widget.pet.imageUrls[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
                if (widget.pet.imageUrls.length >
                    1) // Only show dots if more than one image
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.pet.imageUrls.length,
                        (index) => GestureDetector(
                          onTap: () {
                            pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: currentPage == index ? 12 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentPage == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ]);
            }),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: ConstantsColors.accent),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pet.name,
                        style: const TextStyle(
                          fontSize: 28,
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
                              fontSize: 18,
                              color: Colors.grey,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${NumberFormat('#,###').format(widget.pet.adoptionFee)}',
                        style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                            color: widget.pet.status == "available"
                                ? ConstantsColors.secondary
                                : ConstantsColors.primary,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          widget.pet.status == "available"
                              ? "Available"
                              : "Adopted",
                          style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 3,
                        children: [
                          _buildAttributeItem('Species', widget.pet.species),
                          _buildAttributeItem('Breed', widget.pet.breed),
                          _buildAttributeItem('Gender', widget.pet.sex),
                          _buildAttributeItem('Color', widget.pet.color),
                          _buildAttributeItem(
                              'Weight', '${widget.pet.weight} kg(s)'),
                          _buildAttributeItem('Age', '${widget.pet.age} years'),
                          _buildAttributeItem('Vaccinated',
                              widget.pet.vaccinated ? "Yes" : "No"),
                          _buildAttributeItem(
                              'Neutered', widget.pet.neutered ? "Yes" : "No"),
                          _buildAttributeItem('Microchipped',
                              widget.pet.microchipped ? "Yes" : "No"),
                        ],
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: 'Medical Conditions:\n',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold), // Bold labels
                            ),
                            TextSpan(
                                text: '${widget.pet.medicalConditions}\n\n',
                                style: TextStyle(color: Colors.grey.shade600)),
                            TextSpan(
                              text: 'Special Needs:\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text: '${widget.pet.specialNeeds}\n\n',
                                style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: 24),
                      const Text(
                        'Description:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.pet.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 24),
                      RichText(
                          text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                              children: [
                            const TextSpan(
                              text: 'Owned by: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            TextSpan(
                              text: widget.pet.owner.fullname,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ])),
                      const SizedBox(height: 32),
// Replace the current button section with this:
                      if (widget.pet.owner.id != userController.id &&
                          widget.pet.status != "adopted")
                        isLoadingRequestStatus
                            ? const CircularProgressIndicator()
                            : hasRequestedAdoption
                                ? Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: const Text(
                                        'You already requested to adopt this pet',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Nunito',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _requestAdoption,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        backgroundColor:
                                            ConstantsColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        'Adopt Me',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ),
                                  ),
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontFamily: 'PT Sans',
          ),
        ),
      ],
    );
  }
}
