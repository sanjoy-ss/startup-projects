import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:alogyan_app/features/auth/controllers/auth_controller.dart';
import 'package:alogyan_app/features/auth/data/auth_repository.dart';
import 'package:alogyan_app/features/auth/models/user_model.dart';
import 'package:alogyan_app/core/cache/cache_service.dart';
import 'package:alogyan_app/features/navigation/controllers/navigation_controller.dart';
import 'package:alogyan_app/features/navigation/screens/main_navigation_shell.dart';
import 'package:alogyan_app/features/navigation/widgets/alogyan_drawer.dart';

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

  testWidgets('AlogyanDrawer renders header, navigation items, and switches tabs', (WidgetTester tester) async {
    final fakeCache = FakeCacheService();
    final authRepo = AuthRepository(cacheService: fakeCache);
    final authController = Get.put(AuthController(authRepository: authRepo));
    final navController = Get.put(NavigationController());

    authController.currentUser.value = const UserModel(
      uid: 'u_test',
      name: 'Prof. Sharma',
      email: 'sharma@alogyan.com',
      phone: '+91 9876543210',
      role: 'owner',
      instituteId: 'inst_01',
      instituteName: 'Alogyan Academy',
      activeBranchId: 'main-campus',
      activeBranchName: 'Main Campus',
      designation: 'Senior Faculty',
      subject: 'Mathematics',
    );

    await tester.pumpWidget(
      const GetMaterialApp(
        home: MainNavigationShell(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial tab is Dashboard (index 0)
    expect(navController.currentIndex.value, 0);

    // Open drawer via hamburger icon button
    final menuButton = find.byTooltip('Open Navigation Drawer');
    expect(menuButton, findsOneWidget);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Verify drawer contents
    expect(find.byType(AlogyanDrawer), findsOneWidget);
    expect(find.text('Prof. Sharma'), findsOneWidget);
    expect(find.text('MAIN NAVIGATION'), findsOneWidget);
    expect(find.text('Dashboard Overview'), findsOneWidget);
    expect(find.text('Batches & Classes'), findsOneWidget);
    expect(find.text('Fee Collection & UPI'), findsOneWidget);
    expect(find.text('Educator Profile'), findsOneWidget);
    expect(find.text('Student Directory'), findsOneWidget);
    expect(find.text('Change Profile'), findsOneWidget);

    // Tap Educator Profile in Drawer
    await tester.tap(find.text('Educator Profile'));
    await tester.pumpAndSettle();

    // Tab should change to 3 (Profile) and drawer should close
    expect(navController.currentIndex.value, 3);
    expect(find.byType(AlogyanDrawer), findsNothing);

    // Open drawer again
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Tap Batches & Classes
    await tester.tap(find.text('Batches & Classes'));
    await tester.pumpAndSettle();
    expect(navController.currentIndex.value, 1);
  });

  testWidgets('AlogyanDrawer campus switcher updates active branch', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeCache = FakeCacheService();
    final authRepo = AuthRepository(cacheService: fakeCache);
    final authController = Get.put(AuthController(authRepository: authRepo));
    Get.put(NavigationController());

    authController.currentUser.value = const UserModel(
      uid: 'u_test',
      name: 'Prof. Sharma',
      email: 'sharma@alogyan.com',
      phone: '+91 9876543210',
      role: 'owner',
      instituteId: 'inst_01',
      instituteName: 'Alogyan Academy',
      activeBranchId: 'main-campus',
      activeBranchName: 'Main Campus',
      designation: 'Senior Faculty',
      subject: 'Mathematics',
    );

    await tester.pumpWidget(
      const GetMaterialApp(
        home: MainNavigationShell(),
      ),
    );
    await tester.pumpAndSettle();

    // Open drawer
    await tester.tap(find.byTooltip('Open Navigation Drawer'));
    await tester.pumpAndSettle();

    // Tap North Campus tile
    expect(find.text('North Campus'), findsOneWidget);
    await tester.tap(find.text('North Campus'));
    await tester.pumpAndSettle();

    // Verify branch changed
    expect(authController.currentUser.value?.activeBranchId, 'north-branch');
    expect(authController.currentUser.value?.activeBranchName, 'North Campus');

    // Allow Get.snackbar timer to expire cleanly
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
