import 'package:flutter/material.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/pages/home_screen.dart';
import 'package:pat_a_pet/pages/signin/signin_screen.dart';
import 'package:pat_a_pet/pages/signup/signup_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: ConstantsColors.primary),
        useMaterial3: true,
      ),
      // home: const HomePage(),
      // home: const SignupScreen(),
      home: const SigninScreen(),
    );
  }
}
