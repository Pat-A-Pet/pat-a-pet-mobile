import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/constants/colors.dart';
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
        child: Icon(
          Icons.home,
          color: selectedIndex == 0 ? ConstantsColors.secondary : Colors.grey,
        ),
        label: 'Home',
      ),
      CurvedNavigationBarItem(
        child: Icon(
          Icons.pets,
          color: selectedIndex == 0 ? ConstantsColors.secondary : Colors.grey,
        ),
        label: 'Listing',
      ),
      CurvedNavigationBarItem(
        child: Icon(
          Icons.group,
          color: selectedIndex == 0 ? ConstantsColors.secondary : Colors.grey,
        ),
        label: 'Community',
      ),
      CurvedNavigationBarItem(
        child: Icon(
          Icons.question_answer,
          color: selectedIndex == 0 ? ConstantsColors.secondary : Colors.grey,
        ),
        label: 'Inbox',
      ),
      CurvedNavigationBarItem(
        child: Icon(
          Icons.person,
          color: selectedIndex == 0 ? ConstantsColors.secondary : Colors.grey,
        ),
        label: 'Profile',
      ),
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
      // const ChatPage(),
      const Profile(),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    selectedIndex.value = 0;
  }
}
