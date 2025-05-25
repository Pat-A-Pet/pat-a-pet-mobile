import 'package:flutter/material.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/pages/signin/signin_form.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
        backgroundColor: ConstantsColors.background,
        body: SingleChildScrollView(
          child: Padding(
            //padding: TSpacingStyle.paddingWithAppBarHeight,
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.1,
                horizontal: MediaQuery.of(context).size.width * 0.07),
            child: Column(
              children: [
                /// Logo, Title & sub-title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/logo_w_picture.png",
                      width: 200,
                    ),
                    Text(
                      "Welcome to Pat-A-Pet",
                      // style: Theme.of(context).textTheme.headlineMedium
                    ),
                    SizedBox(height: 30),
                    Text(
                      "something something something",
                      // style: Theme.of(context).textTheme.bodyMedium
                    ),
                  ],
                ),

                /// Form
                SigninForm(),

                /// Divider
                // TFormDivider(dark: dark),
                //TFormDivider(dividerText: TTexts.orSignInWith.capitalize!),
                //const SizedBox(height: TSizes.spaceBtwSections),

                /// Footer
                //const TSocialButtons()
              ],
            ),
          ),
        ));
  }
}
