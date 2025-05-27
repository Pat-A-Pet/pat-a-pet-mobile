import 'package:flutter/material.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/main.dart';
import 'package:pat_a_pet/pages/home_screen.dart';
import 'package:pat_a_pet/pages/signin/signin_screen.dart';
import 'package:pat_a_pet/pages/signup/signup_screen.dart';

class App extends StatelessWidget {
  final Widget initialScreen;
  const App({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ConstantsColors.primary),
        useMaterial3: true,
      ),
      home: initialScreen,
    );
  }
}
