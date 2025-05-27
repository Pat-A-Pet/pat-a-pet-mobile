import 'package:flutter/material.dart';
import 'package:pat_a_pet/constants/colors.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions(
      {super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: ConstantsColors.secondary,
            )),
        const SizedBox(width: 30),
        Text.rich(TextSpan(children: [
          TextSpan(text: 'I agree to', style: TextStyle(fontFamily: "PT Sans")),
          TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(fontFamily: "PT Sans").apply(
                color: ConstantsColors.secondary,
                decoration: TextDecoration.underline,
                decorationColor: ConstantsColors.secondary,
              )),
          TextSpan(text: 'and', style: TextStyle(fontFamily: "PT Sans")),
          TextSpan(
              text: 'Terms of use',
              style: TextStyle(fontFamily: "PT Sans").apply(
                color: ConstantsColors.secondary,
                decoration: TextDecoration.underline,
                decorationColor: ConstantsColors.secondary,
              )),
        ]))
      ],
    );
  }
}
