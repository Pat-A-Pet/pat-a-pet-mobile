import 'package:flutter/material.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/pages/signup/signup_form.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ConstantsColors.background,
      appBar: CustomAppbar(
        title: "Welcome owner!",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.07,
            horizontal: size.width * 0.07,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: size.width * 0.9,
              height: size.height,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Text(
                      "Please fill in your information accurately to create an account.",
                      style: TextStyle(
                        fontFamily: "PT Sans",
                        fontSize: 16,
                        color: ConstantsColors.textPrimary,
                        height: 1.5,
                      )),
                  const SizedBox(height: 30),
                  SignupForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
