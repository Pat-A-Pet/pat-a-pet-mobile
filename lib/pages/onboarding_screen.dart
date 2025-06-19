import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/constants/colors.dart';
import 'package:pat_a_pet/pages/signin/signin_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: ConstantsColors.background,
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnBoardingPage(
                image: "assets/images/logo_w_picture.png",
                title: "Welcome to Pat-A-Pet! 🐾",
                subTitle:
                    "Your go-to app for pet adoption, selling, and community!",
                last: false,
              ),
              OnBoardingPage(
                  image: "assets/images/hold_dog_1.png",
                  title: "One More Friend Thousands More Fun! ❤️",
                  subTitle:
                      "Browse pets for adoption or list your own for a loving new home.",
                  last: false),
              OnBoardingPage(
                  image: "assets/images/hold_dog_2.png",
                  title: "Share & Connect with Fellow Pet Owners 🐶🐱",
                  subTitle:
                      "Post stories, tips, and photos of your furry friends in our community.",
                  last: false),
              OnBoardingPage(
                image: "assets/images/puppies.png",
                title: "Ready to Dive In?",
                subTitle: "Join thousands of pet lovers today!",
                last: true,
              ),
            ],
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 0,
            right: 0,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OnBoardingSkip(),
                  OnBoardingDotNavigation(),
                  OnBoardingNextButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  void updatePageIndicator(index) => currentPageIndex.value = index;

  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  void nextPage() {
    if (currentPageIndex.value == 3) {
      Get.offAll(const SigninScreen());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage() {
    currentPageIndex.value = 3;
    pageController.jumpToPage(3);
  }
}

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage(
      {super.key,
      required this.image,
      required this.title,
      required this.subTitle,
      this.last = false});

  final String image, title, subTitle;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
      child: Column(
        children: [
          Image(
            image: AssetImage(image),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.4,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            child: Text(
              title,
              style: TextStyle(
                  fontFamily: "Nunito",
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Text(
              subTitle,
              style: const TextStyle(fontFamily: "PT Sans", fontSize: 18),
              textAlign: last == true ? TextAlign.center : TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return const Color(0xffD3E0EA); // color when pressed
            }
            return Colors.transparent; // default color
          },
        ),
      ),
      onPressed: () => OnboardingController.instance.skipPage(),
      child: const Text(
        'Skip',
        style: TextStyle(
            fontFamily: "Nunito",
            color: ConstantsColors.textPrimary,
            fontSize: 14),
      ),
    );
  }
}

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;

    return SmoothPageIndicator(
      controller: controller.pageController,
      onDotClicked: controller.dotNavigationClick,
      count: 4,
      effect: ExpandingDotsEffect(
          activeDotColor: ConstantsColors.primary, dotHeight: 6),
    );
  }
}

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return const Color(0xffD3E0EA); // color when pressed
            }
            return Colors.transparent; // default color
          },
        ),
      ),
      onPressed: () => OnboardingController.instance.nextPage(),
      child: const Text(
        'Next',
        style: TextStyle(
            fontFamily: "Nunito",
            color: ConstantsColors.textPrimary,
            fontSize: 14),
      ),
    );
  }
}
