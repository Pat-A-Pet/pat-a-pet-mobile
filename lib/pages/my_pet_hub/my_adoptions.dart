import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pat_a_pet/components/adoptions_pet_card.dart';
import 'package:pat_a_pet/configs/api_config.dart';
import 'dart:convert';
import 'package:pat_a_pet/controllers/user_controller.dart';
import 'package:pat_a_pet/models/pet.dart';

class MyAdoptions extends StatefulWidget {
  const MyAdoptions({super.key});

  @override
  State<MyAdoptions> createState() => _MyAdoptionsState();
}

class _MyAdoptionsState extends State<MyAdoptions>
    with SingleTickerProviderStateMixin {
  List<Pet> _requestedAdoptions = [];
  List<Pet> _completedAdoptions = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;
  final userController = Get.find<UserController>();
  final secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAdoptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAdoptions() async {
    final userId = userController.id;
    final token = await secureStorage.read(key: "jwt");

    if (token == null) {
      setState(() {
        _errorMessage = 'Not authenticated';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getAllAdoptionsBuyer(userId)),
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint("Adoptions API Response: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          // Requested adoptions - pets where user has pending/accepted requests
          _requestedAdoptions = (responseData['requested'] as List? ?? [])
              .map((json) => Pet.fromJson(json))
              .toList();

          // Completed adoptions - pets from user's adoption list
          _completedAdoptions = (responseData['adopted'] as List? ?? [])
              .map((json) => Pet.fromJson(json))
              .toList();

          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load adoptions: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching adoptions: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildAdoptionsList(List<Pet> adoptions, String emptyMessage) {
    if (adoptions.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            fontFamily: "Nunito",
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: adoptions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final pet = adoptions[index];
        return AdoptionsPetCard(
          pet: pet,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Adoptions'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Requested'),
              Tab(text: 'Adopted'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Requested Adoptions Tab
                      RefreshIndicator(
                        onRefresh: _fetchAdoptions,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _requestedAdoptions.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                          ),
                          itemBuilder: (context, index) => AdoptionsPetCard(
                            pet: _requestedAdoptions[index],
                            isCompletedAdoption: false,
                          ),
                        ),
                      ),

                      // Completed Adoptions Tab
                      RefreshIndicator(
                        onRefresh: _fetchAdoptions,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _completedAdoptions.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                          ),
                          itemBuilder: (context, index) => AdoptionsPetCard(
                            pet: _completedAdoptions[index],
                            isCompletedAdoption: true,
                          ),
                        ),
                      ),
                    ],
                  ));
  }
}
