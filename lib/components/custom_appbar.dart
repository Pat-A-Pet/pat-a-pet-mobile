import 'package:flutter/material.dart';
import 'package:pat_a_pet/constants/colors.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? logo;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color backgroundColor;

  const CustomAppbar({
    super.key,
    this.title,
    this.logo,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor = ConstantsColors.accent,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Widget? titleWidget;

    // if (logo != null && title != null) {
    //   titleWidget = Row(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       SizedBox(
    //         height: 60, // or whatever fits your app bar height
    //         child: logo,
    //       ),
    //       SizedBox(width: 8),
    //       Text(title!,
    //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    //     ],
    //   );
    // } else
    if (logo != null) {
      titleWidget = SizedBox(
        height: 50,
        child: logo,
      );
    } else if (title != null) {
      titleWidget = Text(title!,
          style: TextStyle(
              fontFamily: "Nunito", fontSize: 20, fontWeight: FontWeight.bold));
    }

    return AppBar(
      backgroundColor: backgroundColor,
      title: titleWidget,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      elevation: 4,
    );
  }
}
