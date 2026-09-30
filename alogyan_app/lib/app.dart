import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/cache/cache_service.dart';
import 'core/constants/styles.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/navigation/screens/main_navigation_shell.dart';
import 'features/onboarding/controllers/onboarding_controller.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

class AlogyanApp extends StatelessWidget {
  const AlogyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;

    final cacheService = Get.isRegistered<CacheService>()
        ? Get.find<CacheService>()
        : null;

    final onboardingController = Get.isRegistered<OnboardingController>()
        ? Get.find<OnboardingController>()
        : (cacheService != null
            ? Get.put(OnboardingController(cacheService: cacheService))
            : null);

    return GetMaterialApp(
      title: 'Alogyan Companion',
      debugShowCheckedModeBanner: false,
      theme: AlogyanStyles.themeData,
      home: Obx(() {
        final isLoggedIn = authController?.isLoggedIn ?? false;
        if (isLoggedIn) {
          return const MainNavigationShell();
        }

        final hasCompletedOnboarding = onboardingController != null
            ? onboardingController.isCompleted.value
            : true;
        if (!hasCompletedOnboarding) {
          return const OnboardingScreen();
        }

        return const LoginScreen();
      }),
    );
  }
}
