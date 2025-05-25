import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/components/custom_appbar.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/pages/signup/signup_form.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // final userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantsColors.background,
      appBar: CustomAppbar(
        title: "Welcome owner!",
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                /// Title
                const SizedBox(height: 30),
                Text(
                    "Please fill in the doctor's information accurately to create their account.",
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 30),
                SignupForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
