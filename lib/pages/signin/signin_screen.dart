import 'package:flutter/material.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/pages/signin/signin_form.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ConstantsColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.07,
            horizontal: size.width * 0.07,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/logo_w_picture.png",
                  width: size.width * 0.55,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Welcome to Pat-A-Pet!",
                style: TextStyle(
                  fontFamily: "Nunito",
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ConstantsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Connect with your future pet companion. Log in to explore adoptable pets and give them a loving home.",
                style: TextStyle(
                  fontFamily: "PT Sans",
                  fontSize: 16,
                  color: ConstantsColors.textPrimary,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 30),
              const SigninForm(),
            ],
          ),
        ),
      ),
    );
  }
}

