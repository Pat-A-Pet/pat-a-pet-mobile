import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/app.dart';
import 'package:pat_a_pet/components/navigation_menu.dart';
import 'package:pat_a_pet/pages/onboarding_screen.dart';
import 'controllers/user_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  dynamic storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'jwt');
  final userController = Get.put(UserController());
  await userController.loadPersistedData();
  Get.put(NavigationController());
  runApp(App(
      initialScreen:
          token != null ? const NavigationMenu() : const OnBoardingScreen()));
}
