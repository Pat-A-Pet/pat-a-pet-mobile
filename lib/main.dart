import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pat_a_pet/app.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  dynamic storage = const FlutterSecureStorage();
  // final token = await storage.read(key: 'jwt');
  // final userController = Get.put(UserController);
  // await userController.loadPersistedData();
  // Get.put(NavigationController());
  runApp(const App());
}
