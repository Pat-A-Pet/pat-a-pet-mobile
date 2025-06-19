import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/app.dart';
import 'package:pat_a_pet/components/navigation_menu.dart';
import 'package:pat_a_pet/pages/onboarding_screen.dart';
import 'controllers/user_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final StreamChatClient streamClient = StreamChatClient(
  dotenv.get('STREAM_API_KEY'),
  logLevel: Level.INFO,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'jwt');
  final userController = Get.put(UserController());
  await userController.loadPersistedData();
  Get.put(NavigationController());

  runApp(App(
    client: streamClient,
    initialScreen:
        token != null ? const NavigationMenu() : const OnBoardingScreen(),
  ));
}
