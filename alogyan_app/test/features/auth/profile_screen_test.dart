import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:alogyan_app/features/auth/controllers/auth_controller.dart';
import 'package:alogyan_app/features/auth/data/auth_repository.dart';
import 'package:alogyan_app/features/auth/models/user_model.dart';
import 'package:alogyan_app/features/auth/screens/profile_screen.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';
import 'package:alogyan_app/features/students/screens/students_screen.dart';
import 'package:alogyan_app/core/cache/cache_service.dart';

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
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('ProfileScreen renders educator header, credentials, and actions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeCache = FakeCacheService();
    final authRepo = AuthRepository(cacheService: fakeCache);
    final authController = Get.put(AuthController(authRepository: authRepo));
    Get.put(StudentsController());

    authController.currentUser.value = const UserModel(
      uid: 'u_101',
      name: 'Dr. Anand Verma',
      email: 'anand@alogyan.com',
      phone: '+91 9123456780',
      role: 'owner',
      instituteId: 'inst_alpha',
      instituteName: 'Alpha Coaching Institute',
      activeBranchId: 'main-campus',
      activeBranchName: 'Main Campus',
      designation: 'Managing Director',
      subject: 'Higher Mathematics',
    );

    await tester.pumpWidget(
      const GetMaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify educator details
    expect(find.text('Dr. Anand Verma'), findsOneWidget);
    expect(find.text('Managing Director'), findsOneWidget);
    expect(find.text('Alpha Coaching Institute • Main Campus'), findsOneWidget);
    expect(find.text('EDUCATOR CREDENTIALS'), findsOneWidget);
    expect(find.text('anand@alogyan.com'), findsOneWidget);
    expect(find.text('+91 9123456780'), findsOneWidget);
    expect(find.text('Higher Mathematics'), findsOneWidget);

    // Verify quick link to Student Directory
    expect(find.text('Student Directory'), findsOneWidget);

    // Verify Edit Profile Details button
    expect(find.text('Edit Profile Details'), findsOneWidget);

    // Tap Edit Profile Details
    await tester.tap(find.text('Edit Profile Details'));
    await tester.pumpAndSettle();

    expect(find.text('Change Profile Details'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Full Name'), findsOneWidget);
  });

  testWidgets('ProfileScreen switches branch on tap', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeCache = FakeCacheService();
    final authRepo = AuthRepository(cacheService: fakeCache);
    final authController = Get.put(AuthController(authRepository: authRepo));
    Get.put(StudentsController());

    authController.currentUser.value = const UserModel(
      uid: 'u_101',
      name: 'Dr. Anand Verma',
      email: 'anand@alogyan.com',
      phone: '+91 9123456780',
      role: 'owner',
      instituteId: 'inst_alpha',
      instituteName: 'Alpha Coaching Institute',
      activeBranchId: 'main-campus',
      activeBranchName: 'Main Campus',
      designation: 'Managing Director',
      subject: 'Higher Mathematics',
    );

    await tester.pumpWidget(
      const GetMaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap North Campus
    expect(find.text('North Campus'), findsOneWidget);
    await tester.tap(find.text('North Campus'));
    await tester.pumpAndSettle();

    expect(authController.currentUser.value?.activeBranchId, 'north-branch');
    expect(authController.currentUser.value?.activeBranchName, 'North Campus');

    // Allow snackbar timer to expire cleanly
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('ProfileScreen opens Student Directory when tapped', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeCache = FakeCacheService();
    final authRepo = AuthRepository(cacheService: fakeCache);
    final authController = Get.put(AuthController(authRepository: authRepo));
    Get.put(StudentsController());

    authController.currentUser.value = const UserModel(
      uid: 'u_101',
      name: 'Dr. Anand Verma',
      email: 'anand@alogyan.com',
      phone: '+91 9123456780',
      role: 'owner',
      instituteId: 'inst_alpha',
      instituteName: 'Alpha Coaching Institute',
      activeBranchId: 'main-campus',
      activeBranchName: 'Main Campus',
      designation: 'Managing Director',
      subject: 'Higher Mathematics',
    );

    await tester.pumpWidget(
      const GetMaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Student Directory link
    await tester.tap(find.text('Student Directory'));
    await tester.pumpAndSettle();

    // Should push StudentsScreen
    expect(find.byType(StudentsScreen), findsOneWidget);
  });
}
