import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/core/cache/cache_service.dart';
import 'package:alogyan_app/features/auth/controllers/auth_controller.dart';
import 'package:alogyan_app/features/auth/data/auth_repository.dart';
import 'package:alogyan_app/features/auth/models/user_model.dart';

// Mock CacheService for testing without native Hive platform binary dependencies
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserModel Serialization & Domain Rules', () {
    test('calculates initials properly', () {
      const user1 = UserModel(
        uid: '1',
        name: 'Dr. Sanjoy Sarkar',
        email: 'sanjoy@alogyan.com',
        phone: '+919876543210',
        role: 'owner',
        instituteId: 'alogyan_academy',
        instituteName: 'Alogyan Academy',
        activeBranchId: 'main-campus',
        activeBranchName: 'Main Campus',
        designation: 'Director',
        subject: 'Physics',
      );
      expect(user1.initials, 'DS');

      const user2 = UserModel(
        uid: '2',
        name: 'Aarav',
        email: 'aarav@alogyan.com',
        phone: '+919876543211',
        role: 'teacher',
        instituteId: 'alogyan_academy',
        instituteName: 'Alogyan Academy',
        activeBranchId: 'main-campus',
        activeBranchName: 'Main Campus',
        designation: 'Faculty',
        subject: 'Maths',
      );
      expect(user2.initials, 'AA');
    });

    test('role helper getters work properly', () {
      final owner = UserModel.demoProfiles[0];
      final teacher = UserModel.demoProfiles[1];
      final manager = UserModel.demoProfiles[2];

      expect(owner.isOwner, true);
      expect(owner.isTeacher, false);
      expect(owner.roleDisplay, 'DIRECTOR / OWNER');

      expect(teacher.isTeacher, true);
      expect(teacher.isOwner, false);
      expect(teacher.roleDisplay, 'FACULTY');

      expect(manager.isBranchManager, true);
      expect(manager.roleDisplay, 'BRANCH HEAD');
    });

    test('serializes toMap and deserializes fromMap identically', () {
      final original = UserModel.demoProfiles[0];
      final map = original.toMap();
      final reconstructed = UserModel.fromMap(map);

      expect(reconstructed.uid, original.uid);
      expect(reconstructed.name, original.name);
      expect(reconstructed.email, original.email);
      expect(reconstructed.phone, original.phone);
      expect(reconstructed.role, original.role);
      expect(reconstructed.instituteId, original.instituteId);
      expect(reconstructed.activeBranchId, original.activeBranchId);
      expect(reconstructed.designation, original.designation);
      expect(reconstructed.subject, original.subject);
    });

    test('copyWith updates specified fields only', () {
      final original = UserModel.demoProfiles[0];
      final modified = original.copyWith(
        activeBranchId: 'north-branch',
        activeBranchName: 'North Campus',
      );

      expect(modified.activeBranchId, 'north-branch');
      expect(modified.activeBranchName, 'North Campus');
      expect(modified.name, original.name);
      expect(modified.email, original.email);
    });
  });

  group('AuthRepository and Cache Integration', () {
    test('saves and retrieves user from cache', () async {
      final fakeCache = FakeCacheService();
      final authRepo = AuthRepository(cacheService: fakeCache);

      expect(authRepo.getCachedUser(), isNull);

      final demo = UserModel.demoProfiles[0];
      await authRepo.saveUserToCache(demo);

      final cached = authRepo.getCachedUser();
      expect(cached, isNotNull);
      expect(cached!.name, demo.name);
      expect(cached.email, demo.email);

      await authRepo.clearUserCache();
      expect(authRepo.getCachedUser(), isNull);
    });
  });

  group('AuthController State Management', () {
    test('initializes with default state and demo accounts', () {
      final fakeCache = FakeCacheService();
      final authRepo = AuthRepository(cacheService: fakeCache);
      final controller = AuthController(authRepository: authRepo);

      expect(controller.isLoggedIn, false);
      expect(controller.activeTab.value, 'phone');
      expect(controller.phoneController.text, isEmpty);
      expect(controller.emailController.text, isEmpty);
    });

    test('switches tabs and toggles password visibility', () {
      final fakeCache = FakeCacheService();
      final authRepo = AuthRepository(cacheService: fakeCache);
      final controller = AuthController(authRepository: authRepo);

      controller.setTab('email');
      expect(controller.activeTab.value, 'email');

      expect(controller.isPasswordVisible.value, false);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible.value, true);
    });

    test('loginWithDemo logs in educator and caches user', () async {
      final fakeCache = FakeCacheService();
      final authRepo = AuthRepository(cacheService: fakeCache);
      final controller = AuthController(authRepository: authRepo);

      final selected = UserModel.demoProfiles[0];
      await controller.loginWithDemo(selected);

      expect(controller.isLoggedIn, true);
      expect(controller.currentUser.value?.uid, selected.uid);
      expect(controller.currentUser.value?.name, selected.name);
      expect(fakeCache.getCachedUser()?['name'], selected.name);
    });

    test('switchBranch updates active branch on user model and cache', () async {
      final fakeCache = FakeCacheService();
      final authRepo = AuthRepository(cacheService: fakeCache);
      final controller = AuthController(authRepository: authRepo);

      await controller.loginWithDemo(UserModel.demoProfiles[0]);
      await controller.switchBranch('north-branch', 'North Campus');

      expect(controller.currentUser.value?.activeBranchId, 'north-branch');
      expect(controller.currentUser.value?.activeBranchName, 'North Campus');
      expect(fakeCache.getCachedUser()?['activeBranchId'], 'north-branch');
    });

    test('signOut clears user state and cache', () async {
      final fakeCache = FakeCacheService();
      final authRepo = AuthRepository(cacheService: fakeCache);
      final controller = AuthController(authRepository: authRepo);

      await controller.loginWithDemo(UserModel.demoProfiles[0]);
      expect(controller.isLoggedIn, true);

      await controller.signOut();
      expect(controller.isLoggedIn, false);
      expect(controller.currentUser.value, isNull);
      expect(fakeCache.getCachedUser(), isNull);
    });
  });
}
