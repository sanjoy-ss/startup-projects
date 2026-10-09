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
      const owner = UserModel(
        uid: 'u1',
        name: 'Dr. Owner',
        email: 'owner@alogyan.com',
        phone: '+91 9876543210',
        instituteId: 'inst_1',
        instituteName: 'Alogyan Academy',
        activeBranchId: 'b1',
        activeBranchName: 'Main Campus',
        role: 'owner',
        designation: 'Director',
        subject: 'Physics',
      );
      const teacher = UserModel(
        uid: 'u2',
        name: 'Prof. Teacher',
        email: 'teacher@alogyan.com',
        phone: '+91 9876543211',
        instituteId: 'inst_1',
        instituteName: 'Alogyan Academy',
        activeBranchId: 'b1',
        activeBranchName: 'Main Campus',
        role: 'teacher',
        designation: 'Faculty',
        subject: 'Maths',
      );
      const manager = UserModel(
        uid: 'u3',
        name: 'Manager',
        email: 'manager@alogyan.com',
        phone: '+91 9876543212',
        instituteId: 'inst_1',
        instituteName: 'Alogyan Academy',
        activeBranchId: 'b1',
        activeBranchName: 'Main Campus',
        role: 'branch_manager',
        designation: 'Branch Head',
        subject: 'Admin',
      );

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
      const original = UserModel(
        uid: 'u1',
        name: 'Dr. Sanjoy',
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
      const original = UserModel(
        uid: 'u1',
        name: 'Dr. Sanjoy',
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

      const testUser = UserModel(
        uid: 'u1',
        name: 'Dr. Sanjoy',
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
      await authRepo.saveUserToCache(testUser);

      final cached = authRepo.getCachedUser();
      expect(cached, isNotNull);
      expect(cached!.name, testUser.name);
      expect(cached.email, testUser.email);

      await authRepo.clearUserCache();
      expect(authRepo.getCachedUser(), isNull);
    });
  });

  group('AuthController State Management', () {
    test('initializes with default state', () {
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

    test('switchBranch updates active branch on user model and cache', () async {
      final fakeCache = FakeCacheService();
      final authRepo = AuthRepository(cacheService: fakeCache);
      final controller = AuthController(authRepository: authRepo);

      const testUser = UserModel(
        uid: 'u1',
        name: 'Dr. Sanjoy',
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
      controller.currentUser.value = testUser;
      await authRepo.saveUserToCache(testUser);

      await controller.switchBranch('north-branch', 'North Campus');

      expect(controller.currentUser.value?.activeBranchId, 'north-branch');
      expect(controller.currentUser.value?.activeBranchName, 'North Campus');
      expect(fakeCache.getCachedUser()?['activeBranchId'], 'north-branch');
    });

    test('signOut clears user state and cache', () async {
      final fakeCache = FakeCacheService();
      final authRepo = AuthRepository(cacheService: fakeCache);
      final controller = AuthController(authRepository: authRepo);

      const testUser = UserModel(
        uid: 'u1',
        name: 'Dr. Sanjoy',
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
      controller.currentUser.value = testUser;
      await authRepo.saveUserToCache(testUser);

      expect(controller.isLoggedIn, true);

      await controller.signOut();
      expect(controller.isLoggedIn, false);
      expect(controller.currentUser.value, isNull);
      expect(fakeCache.getCachedUser(), isNull);
    });

    test('updateProfile modifies user details in state and cache', () async {
      final fakeCache = FakeCacheService();
      final authRepo = AuthRepository(cacheService: fakeCache);
      final controller = AuthController(authRepository: authRepo);

      const testUser = UserModel(
        uid: 'u1',
        name: 'Dr. Sanjoy',
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
      controller.currentUser.value = testUser;
      await authRepo.saveUserToCache(testUser);

      await controller.updateProfile(
        name: 'Dr. Sanjoy Sarkar',
        phone: '+91 9999988888',
        designation: 'Managing Director',
        subject: 'Advanced Physics & Maths',
      );

      expect(controller.currentUser.value?.name, 'Dr. Sanjoy Sarkar');
      expect(controller.currentUser.value?.phone, '+91 9999988888');
      expect(controller.currentUser.value?.designation, 'Managing Director');
      expect(controller.currentUser.value?.subject, 'Advanced Physics & Maths');
      expect(fakeCache.getCachedUser()?['name'], 'Dr. Sanjoy Sarkar');
    });
  });
}
