import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pat_a_pet/constants/colors.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ConstantsColors.background,
      padding: const EdgeInsets.all(100),
      child: SizedBox(
        child: Lottie.asset(
          'assets/images/loader.json',
          repeat: true,
          animate: true,
        ),
      ),
    );
  }
}
