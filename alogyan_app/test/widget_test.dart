import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/app.dart';
import 'package:alogyan_app/core/cache/cache_service.dart';
import 'package:alogyan_app/features/auth/controllers/auth_controller.dart';
import 'package:alogyan_app/features/auth/data/auth_repository.dart';
import 'package:alogyan_app/features/auth/models/user_model.dart';

class FakeCacheService extends CacheService {
  final Map<String, dynamic> memoryStore = {};

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
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  testWidgets('AlogyanApp renders LoginScreen when not authenticated', (WidgetTester tester) async {
    final fakeCache = FakeCacheService();
    final authRepo = AuthRepository(cacheService: fakeCache);
    Get.put(AuthController(authRepository: authRepo));

    await tester.pumpWidget(const AlogyanApp());
    await tester.pump();

    // Verify Login Screen branding and controls
    expect(find.text('Alogyan'), findsOneWidget);
    expect(find.text('Educator Companion'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Email & Password'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('Terms of Service and Privacy Policy sheets open on tap', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeCache = FakeCacheService();
    final authRepo = AuthRepository(cacheService: fakeCache);
    Get.put(AuthController(authRepository: authRepo));

    await tester.pumpWidget(const AlogyanApp());
    await tester.pump();

    // Tap Terms of Service link
    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();

    expect(find.text('Alogyan Educator & Institute Agreement'), findsOneWidget);
    expect(find.text('I Agree & Understand'), findsOneWidget);

    // Close Terms sheet
    await tester.tap(find.text('I Agree & Understand'));
    await tester.pumpAndSettle();

    // Tap Privacy Policy link
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    expect(find.text('Your data is end-to-end encrypted and never sold'), findsOneWidget);
    expect(find.text('I Understand'), findsOneWidget);

    // Close Privacy sheet
    await tester.tap(find.text('I Understand'));
    await tester.pumpAndSettle();
  });

  testWidgets('AlogyanApp transitions to MainNavigationShell when user logs in', (WidgetTester tester) async {
    final fakeCache = FakeCacheService();
    final authRepo = AuthRepository(cacheService: fakeCache);
    final authController = Get.put(AuthController(authRepository: authRepo));

    await tester.pumpWidget(const AlogyanApp());
    await tester.pump();

    // Initially on LoginScreen
    expect(find.text('Sign In'), findsOneWidget);

    // Perform user login
    authController.currentUser.value = const UserModel(
      uid: 'u1',
      name: 'Dr. Sanjoy Sarkar',
      email: 'sanjoy@alogyan.com',
      phone: '+91 9876543210',
      instituteId: 'inst_1',
      instituteName: 'Alogyan Academy',
      activeBranchId: 'b1',
      activeBranchName: 'Main Campus',
      role: 'owner',
      designation: 'Director',
      subject: 'Physics',
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify MainNavigationShell is now active
    expect(find.text('Today\'s Schedule'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Fees'), findsOneWidget);
    expect(find.text('Students'), findsOneWidget);
  });

  testWidgets('Email & Password bottom sheet opens and toggles between Sign In and Sign Up Free', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeCache = FakeCacheService();
    final authRepo = AuthRepository(cacheService: fakeCache);
    Get.put(AuthController(authRepository: authRepo));

    await tester.pumpWidget(const AlogyanApp());
    await tester.pump();

    // Tap Continue with Email & Password button
    await tester.tap(find.text('Continue with Email & Password'));
    await tester.pumpAndSettle();

    // Verify Sign In sheet components
    expect(find.text('Educator Sign In'), findsOneWidget);
    expect(find.text('Institutional Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Sign In to Alogyan'), findsOneWidget);
    final signUpFinder = find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().contains('Sign Up Free'),
    );
    expect(signUpFinder, findsOneWidget);

    // Switch to Sign Up Free tab
    await tester.tap(signUpFinder);
    await tester.pumpAndSettle();

    // Verify Sign Up form components
    expect(find.text('Create Free Account'), findsOneWidget);
    expect(find.text('Private Tutor'), findsOneWidget);
    expect(find.text('Coaching'), findsOneWidget);
    expect(find.text('Faculty'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Classes / Batch Name'), findsOneWidget);
    expect(find.text('Create Password'), findsOneWidget);
    expect(find.text('Create Free Educator Account'), findsOneWidget);

    // Tap Coaching role chip
    await tester.tap(find.text('Coaching'));
    await tester.pumpAndSettle();
    expect(find.text('Institute Name'), findsOneWidget);
  });
}

