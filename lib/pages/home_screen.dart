import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/controllers/user_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return Scaffold(
        backgroundColor: ConstantsColors.background,
        appBar: CustomAppbar(
          logo: Image.asset("assets/images/logo_wo_picture.png"),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hello there, User!',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Center(
                      child: Image.asset(
                    "assets/images/hero_home_1.png",
                  )),
                  const SizedBox(height: 30),
                  const Text('Your Pets',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  // TODO: your pets buttons
                  const SizedBox(height: 30),
                  const Text('Latest Listed Pets',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  // TODO: list view data pet terbaru
                  const SizedBox(
                      height:
                          120), // extra space to avoid overlapping with bottom stats
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: const Text(
                  '🐶 83 pets listed | 🐾 23 adoptions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ));
  }
}
