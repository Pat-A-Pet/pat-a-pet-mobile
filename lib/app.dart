import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/main.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class App extends StatelessWidget {
  final Widget initialScreen;
  final StreamChatClient client;

  const App({
    super.key,
    required this.initialScreen,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ConstantsColors.primary),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return StreamChat(
          client: client,
          child: StreamChatTheme(
            data: StreamChatThemeData(),
            child: child!,
          ),
        );
      },
      home: initialScreen,
    );
  }
}

