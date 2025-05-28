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
              activeColor: ConstantsColors.primary,
            )),
        const SizedBox(width: 10),
        Text.rich(TextSpan(children: [
          TextSpan(
              text: 'I agree to ', style: TextStyle(fontFamily: "PT Sans")),
          TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(fontFamily: "PT Sans").apply(
                color: ConstantsColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: ConstantsColors.primary,
              )),
          TextSpan(text: ' and ', style: TextStyle(fontFamily: "PT Sans")),
          TextSpan(
              text: 'Terms of use',
              style: TextStyle(fontFamily: "PT Sans").apply(
                color: ConstantsColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: ConstantsColors.primary,
              )),
        ]))
      ],
    );
  }
}
