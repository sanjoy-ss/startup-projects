import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/app.dart';
import 'package:alogyan_app/core/cache/cache_service.dart';
import 'package:alogyan_app/features/auth/controllers/auth_controller.dart';
import 'package:alogyan_app/features/auth/data/auth_repository.dart';
import 'package:alogyan_app/features/onboarding/controllers/onboarding_controller.dart';
import 'package:alogyan_app/features/onboarding/screens/onboarding_screen.dart';

class FakeOnboardingCacheService extends CacheService {
  final Map<String, dynamic> memoryStore = {};

  @override
  bool hasCompletedOnboarding() {
    return memoryStore['completed_onboarding'] ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    memoryStore['completed_onboarding'] = value;
  }

  @override
  Future<void> saveUser(Map<String, dynamic> userData) async {
    memoryStore['active_user'] = userData;
  }

  @override
  Map<String, dynamic>? getCachedUser() {
    final data = memoryStore['active_user'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    memoryStore.remove('active_user');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  group('OnboardingController State Management', () {
    test('initializes with page 0 and false completion', () {
      final fakeCache = FakeOnboardingCacheService();
      final controller = OnboardingController(cacheService: fakeCache);

      expect(controller.currentPage.value, 0);
      expect(controller.isCompleted.value, false);
      expect(fakeCache.hasCompletedOnboarding(), false);
    });

    test('onPageChanged updates currentPage reactively', () {
      final fakeCache = FakeOnboardingCacheService();
      final controller = OnboardingController(cacheService: fakeCache);

      controller.onPageChanged(1);
      expect(controller.currentPage.value, 1);

      controller.onPageChanged(2);
      expect(controller.currentPage.value, 2);
    });

    test('finishOnboarding marks isCompleted true and saves to cache', () async {
      final fakeCache = FakeOnboardingCacheService();
      final controller = OnboardingController(cacheService: fakeCache);

      await controller.finishOnboarding();

      expect(controller.isCompleted.value, true);
      expect(fakeCache.hasCompletedOnboarding(), true);
    });
  });

  group('OnboardingScreen UI & Widget Interactions', () {
    testWidgets('renders Alogyan branding, first slide, and buttons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeCache = FakeOnboardingCacheService();
      Get.put(OnboardingController(cacheService: fakeCache));

      await tester.pumpWidget(
        const GetMaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Brand header
      expect(find.text('Alogyan'), findsOneWidget);
      expect(find.text('Educator Companion'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Slide 1 elements
      expect(find.text('01 / 03'), findsOneWidget);
      expect(find.text('Attendance in\nten seconds flat.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('tapping Skip triggers finishOnboarding', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeCache = FakeOnboardingCacheService();
      final controller = Get.put(OnboardingController(cacheService: fakeCache));

      await tester.pumpWidget(
        const GetMaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Skip
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(controller.isCompleted.value, true);
      expect(fakeCache.hasCompletedOnboarding(), true);
    });

    testWidgets('tapping Continue advances slides to Step 2 and Step 3, then Get Started finishes onboarding', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeCache = FakeOnboardingCacheService();
      final controller = Get.put(OnboardingController(cacheService: fakeCache));

      await tester.pumpWidget(
        const GetMaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1
      expect(find.text('01 / 03'), findsOneWidget);

      // Tap Continue -> Advance to Step 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('02 / 03'), findsOneWidget);
      expect(find.text('Tuition fees paid\nvia dynamic UPI.'), findsOneWidget);

      // Tap Continue -> Advance to Step 3
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('03 / 03'), findsOneWidget);
      expect(find.text('Engineered for\nbasement classes.'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);

      // Tap Get Started -> Finishes onboarding
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(controller.isCompleted.value, true);
      expect(fakeCache.hasCompletedOnboarding(), true);
    });
  });

  group('AlogyanApp Onboarding Routing Integration', () {
    testWidgets('shows OnboardingScreen when not completed, then LoginScreen on completion', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeCache = FakeOnboardingCacheService();
      Get.put<CacheService>(fakeCache);

      final authRepo = AuthRepository(cacheService: fakeCache);
      Get.put(AuthController(authRepository: authRepo));

      final onboardingController = Get.put(OnboardingController(cacheService: fakeCache));

      await tester.pumpWidget(const AlogyanApp());
      await tester.pumpAndSettle();

      // Should be on OnboardingScreen
      expect(find.text('01 / 03'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Finish onboarding
      await onboardingController.finishOnboarding();
      await tester.pumpAndSettle();

      // Now should transition to LoginScreen
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Mobile OTP'), findsOneWidget);
      expect(find.text('Continue with Email & Password'), findsOneWidget);
    });
  });
}
