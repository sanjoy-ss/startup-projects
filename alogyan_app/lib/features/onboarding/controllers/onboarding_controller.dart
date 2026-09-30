import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/cache/cache_service.dart';

class OnboardingController extends GetxController {
  final CacheService cacheService;
  final PageController pageController = PageController(initialPage: 0);

  final RxInt currentPage = 0.obs;
  final RxBool isCompleted = false.obs;

  static const int totalPages = 3;

  OnboardingController({required this.cacheService}) {
    isCompleted.value = cacheService.hasCompletedOnboarding();
    currentPage.value = 0;
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      finishOnboarding();
    }
  }

  Future<void> finishOnboarding() async {
    await cacheService.setOnboardingCompleted(true);
    isCompleted.value = true;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
