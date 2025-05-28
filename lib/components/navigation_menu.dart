import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/components/strocked_icon.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/pages/chat/inbox_screen.dart';
import 'package:pat_a_pet/pages/home_screen.dart';
import 'package:pat_a_pet/pages/profile.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!Get.isRegistered<NavigationController>()) {
        Get.put(NavigationController());
      }
      final controller = Get.find<NavigationController>();

      final navItems = _buildDestinations(controller);

      if (controller.selectedIndex.value >= navItems.length) {
        controller.selectedIndex.value = 0;
      }

      return Scaffold(
        bottomNavigationBar: Obx(() {
          return CurvedNavigationBar(
            iconPadding: 0,
            backgroundColor: Colors.white,
            color: ConstantsColors.accent,
            buttonBackgroundColor: Colors.white,
            height: 78,
            index: controller.selectedIndex.value,
            onTap: (index) => controller.selectedIndex.value = index,
            items: navItems,
          );
        }),
        body: Obx(() => controller.screens[controller.selectedIndex.value]),
      );
    });
  }

  List<CurvedNavigationBarItem> _buildDestinations(
      NavigationController controller) {
    final destinations = <CurvedNavigationBarItem>[];
    final selectedIndex = controller.selectedIndex.value;

    destinations.addAll([
      CurvedNavigationBarItem(
          child: StrokedIcon(
            icon: Icons.home,
            size: 24,
            strokeColor: selectedIndex == 0 ? Colors.black : Colors.transparent,
            strokeWidth: 1,
            fillColor:
                selectedIndex == 0 ? ConstantsColors.secondary : Colors.grey,
          ),
          label: 'Home',
          labelStyle: TextStyle(fontFamily: "PT Sans")),
      CurvedNavigationBarItem(
          child: StrokedIcon(
            icon: Icons.pets,
            size: 24,
            strokeColor: selectedIndex == 1 ? Colors.black : Colors.transparent,
            strokeWidth: 1,
            fillColor:
                selectedIndex == 1 ? ConstantsColors.secondary : Colors.grey,
          ),
          label: 'Listing',
          labelStyle: TextStyle(fontFamily: "PT Sans")),
      CurvedNavigationBarItem(
          child: StrokedIcon(
            icon: Icons.people,
            size: 24,
            strokeColor: selectedIndex == 2 ? Colors.black : Colors.transparent,
            strokeWidth: 1,
            fillColor:
                selectedIndex == 2 ? ConstantsColors.secondary : Colors.grey,
          ),
          label: 'Community',
          labelStyle: TextStyle(fontFamily: "PT Sans")),
      CurvedNavigationBarItem(
          child: StrokedIcon(
            icon: Icons.question_answer,
            size: 24,
            strokeColor: selectedIndex == 3 ? Colors.black : Colors.transparent,
            strokeWidth: 1,
            fillColor:
                selectedIndex == 3 ? ConstantsColors.secondary : Colors.grey,
          ),
          label: 'Inbox',
          labelStyle: TextStyle(fontFamily: "PT Sans")),
      CurvedNavigationBarItem(
          child: StrokedIcon(
            icon: Icons.person,
            size: 24,
            strokeColor: selectedIndex == 4 ? Colors.black : Colors.transparent,
            strokeWidth: 1,
            fillColor:
                selectedIndex == 4 ? ConstantsColors.secondary : Colors.grey,
          ),
          label: 'Profile',
          labelStyle: TextStyle(fontFamily: "PT Sans")),
    ]);
    return destinations;
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  List<Widget> get screens {
    return [
      const HomeScreen(),
      // pet listing page
      // community page
      const InboxScreen(),
      const Profile(),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    selectedIndex.value = 0;
  }
}
