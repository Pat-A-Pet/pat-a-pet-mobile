import 'package:flutter/material.dart';
import 'package:pat_a_pet/constants/colors.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color backgroundColor;
  final PreferredSizeWidget? bottom;

  const CustomAppbar({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor = ConstantsColors.accent,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    Widget? titleWidget;
    Widget logo = Image.asset("assets/images/logo_wo_picture.png");

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
    if (title == null) {
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
      centerTitle: title == null || title!.isEmpty ? true : false,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
      elevation: 4,
      bottom: bottom,
    );
  }
}
