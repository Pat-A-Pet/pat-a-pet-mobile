import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pat_a_pet/constants/colors.dart';
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
            children: const [
              // OnBoardingPage(
              //     image: TImages.melanotectLogo,
              //     title: TTexts.onBoardingTitle1,
              //     // subTitle: TTexts.onBoardingSubTitle1),
              //     subTitle:
              //         "Deteksi melanoma dengan cepat dan mudah, AI kami akan membantu mengenalinya sejak dini."),
              // OnBoardingPage(
              //     image: TImages.onBoardingImage5,
              //     title: TTexts.onBoardingTitle2,
              //     subTitle: TTexts.onBoardingSubTitle2),
              // OnBoardingPage(
              //     image: TImages.onBoardingImage4,
              //     title: "Verifikasi Langsung dari Dokter",
              //     subTitle:
              //         "Deteksi dari AI kami bisa diverifikasi secara langsung dengan dokter kulit yang tersedia"),
              // OnBoardingPage(
              //     image: TImages.onBoardingImage6,
              //     title: TTexts.onBoardingTitle3,
              //     subTitle: TTexts.onBoardingSubTitle3),
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

  /// Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  /// update Current Index when Page Scroll
  // void updatePageIndicator(index) => currentPageIndex = index;
  void updatePageIndicator(index) => currentPageIndex.value = index;

  /// Jump to the specific dot selected page.
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  /// Update Current Index & jump to next page
  void nextPage() {
    if (currentPageIndex.value == 3) {
      // Get.offAll(const LoginScreen());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  /// Update Current Index & jump to the last Page
  void skipPage() {
    currentPageIndex.value = 3;
    pageController.jumpToPage(3);
  }
}

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
  });

  final String image, title, subTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
      child: Column(
        children: [
          // Image(
          //   image: AssetImage(image),
          //   width: THelperFunctions.screenWidth() * 0.8,
          //   height: THelperFunctions.screenHeight() * 0.4,
          // ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Text(
              subTitle,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.justify,
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
        style: TextStyle(color: ConstantsColors.textPrimary, fontSize: 14),
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
        style: TextStyle(color: ConstantsColors.textPrimary, fontSize: 14),
      ),
    );
    //final dark = THelperFunctions.isDarkMode(context);
    //
    //return ElevatedButton(
    //  onPressed: () => OnboardingController.instance.nextPage(),
    //  style: ElevatedButton.styleFrom(
    //      shape: const CircleBorder(),
    //      backgroundColor: dark ? TColors.primary : Colors.black),
    //  child: const Icon(
    //    Iconsax.arrow_right_3,
    //    color: Colors.white,
    //  ),
    //);
  }
}
