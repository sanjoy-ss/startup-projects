# User Data-Driven Real Auth System & Complete Dummy Data Removal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove all hardcoded dummy data (students, batches, demo personas, fallback dues), implement production-grade Firebase Auth (Google, Phone OTP, Email/Password), bind data to the authenticated user's Firestore tenant (`instituteId`), and render dynamic empty states.

**Architecture:** Purge all mock profiles and initial dummy student cache. Refactor `AuthRepository` to perform real Firebase authentication and query/create `users/{uid}` in Firestore with multi-tenant metadata (`instituteId`). Connect `StudentRepository`, `AttendanceController`, `FeeController`, and `DashboardController` reactively to the authenticated user's `instituteId` collections with responsive empty states.

**Tech Stack:** Flutter 3.x, Dart 3.x, Firebase Auth 6.7.0, Cloud Firestore 6.10.0, Hive 2.x, GetX 4.7.3, Lucide Icons.

**Spec:** [`docs/superpowers/specs/2026-10-01-user-data-driven-real-auth-system-design.md`](file:///Users/sanjoysarkar/web_app/start-up-projects/docs/superpowers/specs/2026-10-01-user-data-driven-real-auth-system-design.md)

## Global Constraints
- No dummy data, demo profiles, or hardcoded student/batch lists anywhere in `lib/`.
- Every screen must gracefully render real data or a polished empty state.
- All Firestore tenant queries must filter by `where('instituteId', isEqualTo: activeUser.instituteId)`.
- Follow the Proactive Flutter Hot Reload Rule when modifying files under `lib/`.
- `flutter analyze` must pass with 0 errors.

---

### Task 1: Clean Cache & Remove Dummy Seed Data

**Files:**
- Modify: `lib/core/cache/cache_service.dart:30-65`
- Test: `test/core/cache/cache_service_test.dart`

**Interfaces:**
- Consumes: `Hive.openBox`
- Produces: `CacheService.getCachedStudents()`, `CacheService.hasCompletedOnboarding()`

- [ ] **Step 1: Write the failing unit test for clean CacheService**

```dart
// test/core/cache/cache_service_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:alogyan_app/core/cache/cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final tempDir = Directory.systemTemp.createTempSync('hive_cache_test_');

  setUpAll(() async {
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  test('CacheService initializes with zero dummy students seeded', () async {
    final cache = CacheService();
    await cache.init();

    final students = cache.getCachedStudents();
    expect(students, isEmpty, reason: 'CacheService should not seed hardcoded dummy students');
  });

  test('CacheService correctly tracks onboarding status from settings box', () async {
    final cache = CacheService();
    await cache.init();

    expect(cache.hasCompletedOnboarding(), isFalse);
    await cache.setOnboardingCompleted(true);
    expect(cache.hasCompletedOnboarding(), isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/cache/cache_service_test.dart`
Expected: FAIL because `_seedInitialStudents` seeds 5 students and `hasCompletedOnboarding` returns hardcoded false.

- [ ] **Step 3: Modify `lib/core/cache/cache_service.dart`**

Remove `_seedInitialStudents()` and update `hasCompletedOnboarding()`:
```dart
  Future<void> init() async {
    _studentsBox = await Hive.openBox(studentsBoxName);
    _attendanceBox = await Hive.openBox(attendanceBoxName);
    _feesBox = await Hive.openBox(feesBoxName);
    _syncBox = await Hive.openBox(syncBoxName);
    _userBox = await Hive.openBox(userBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);

    // Sanitize any stale dummy student data from previous demo runs
    _sanitizeStaleDummyData();
  }

  void _sanitizeStaleDummyData() {
    final dummyIds = {'1', '2', '3', '4', '5'};
    final keysToRemove = <dynamic>[];
    for (final key in _studentsBox.keys) {
      if (dummyIds.contains(key.toString())) {
        keysToRemove.add(key);
      }
    }
    for (final k in keysToRemove) {
      _studentsBox.delete(k);
    }
  }

  bool hasCompletedOnboarding() {
    return _settingsBox.get('completed_onboarding', defaultValue: false) as bool? ?? false;
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/cache/cache_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add test/core/cache/cache_service_test.dart lib/core/cache/cache_service.dart
git commit -m "feat(cache): remove dummy student seeding and bind onboarding to settings box"
```

---

### Task 2: Purge Demo Profiles and Update UserModel

**Files:**
- Modify: `lib/features/auth/models/user_model.dart:150-201`
- Modify: `lib/features/auth/widgets/user_profile_modal.dart:180-260`
- Test: `test/features/auth/user_model_test.dart`

**Interfaces:**
- Consumes: None
- Produces: `UserModel`, `UserModel.toMap()`, `UserModel.fromMap()` without `demoProfiles`

- [ ] **Step 1: Write test for UserModel without demoProfiles**

```dart
// test/features/auth/user_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/features/auth/models/user_model.dart';

void main() {
  test('UserModel serializes and deserializes accurately', () {
    const user = UserModel(
      uid: 'test_uid_123',
      name: 'Dr. Jane Doe',
      email: 'jane@example.com',
      phone: '+919876543210',
      role: 'owner',
      instituteId: 'inst_abc123',
      instituteName: 'Zenith Academy',
      branchIds: ['main-campus'],
      activeBranchId: 'main-campus',
      activeBranchName: 'Main Campus',
      designation: 'Director',
      subject: 'Physics',
    );

    final map = user.toMap();
    final restored = UserModel.fromMap(map);

    expect(restored.uid, 'test_uid_123');
    expect(restored.name, 'Dr. Jane Doe');
    expect(restored.instituteId, 'inst_abc123');
    expect(restored.initials, 'JD');
  });
}
```

- [ ] **Step 2: Modify `lib/features/auth/models/user_model.dart`**

Remove `static const List<UserModel> demoProfiles = [...]` from `user_model.dart`.

- [ ] **Step 3: Modify `lib/features/auth/widgets/user_profile_modal.dart`**

Remove the "Switch Demo Persona" section from `UserProfileModal`. Replace it with a clean "Account Details" card showing User ID, Role, Institute ID, and a clean "Log Out" button that invokes `authController.signOut()`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/user_model_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/models/user_model.dart lib/features/auth/widgets/user_profile_modal.dart test/features/auth/user_model_test.dart
git commit -m "refactor(auth): remove static demo profiles and update user profile modal"
```

---

### Task 3: Production Firebase Authentication Engine & Repository

**Files:**
- Modify: `lib/features/auth/data/auth_repository.dart:40-330`
- Modify: `lib/features/auth/controllers/auth_controller.dart:40-170`
- Test: `test/features/auth/auth_repository_test.dart`

**Interfaces:**
- Consumes: `FirebaseAuth`, `FirebaseFirestore`, `CacheService`
- Produces: `AuthRepository.signInWithGoogle()`, `AuthRepository.sendPhoneOtp()`, `AuthRepository.verifyPhoneOtp()`, `AuthRepository.loginWithEmail()`, `AuthRepository.registerWithEmail()`

- [ ] **Step 1: Write test for AuthRepository methods and error handling**

```dart
// test/features/auth/auth_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:alogyan_app/features/auth/data/auth_repository.dart';
import 'package:alogyan_app/core/cache/cache_service.dart';

class MockCacheService extends Mock implements CacheService {
  @override
  Map<String, dynamic>? getCachedUser() => null;
}

void main() {
  test('AuthRepository rejects invalid email or password without falling back to demo', () async {
    final mockCache = MockCacheService();
    final repo = AuthRepository(cacheService: mockCache);

    expect(
      () => repo.loginWithEmail('', ''),
      throwsA(isA<String>()),
    );
  });
}
```

- [ ] **Step 2: Update `lib/features/auth/data/auth_repository.dart`**

1. Remove all references to `UserModel.demoProfiles`.
2. Implement `_fetchOrCreateUserDoc(User fbUser, {String? defaultRole, String? instituteName})`:
   - Checks `FirebaseFirestore.instance.collection('users').doc(fbUser.uid).get()`.
   - If exists, parses document data into `UserModel`.
   - If not, writes new document with real Firebase user details (`fbUser.displayName`, `fbUser.email`, `fbUser.phoneNumber`, etc.) and default institute ID (`inst_${fbUser.uid.substring(0, 8)}`).
3. In `sendPhoneOtp(phoneNumber)`:
   - Use `Completer<String>` to wait for `codeSent: (verificationId, forceResendingToken)` and return the real verification ID.
4. In `verifyPhoneOtp(verificationId, smsCode, phoneNumber)`:
   - Call `auth.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode))`.
   - Fetch or create user doc from Firestore and cache it.
5. In `loginWithEmail(email, password)`:
   - Call `auth.signInWithEmailAndPassword(email: trimmedEmail, password: trimmedPassword)`.
   - Fetch user doc from Firestore. On `FirebaseAuthException`, throw `_mapFirebaseAuthError(e)`.
6. In `signInWithGoogle()`:
   - Call `auth.signInWithProvider(GoogleAuthProvider())`.
   - Fetch or create user doc from Firestore.

- [ ] **Step 3: Update `lib/features/auth/controllers/auth_controller.dart`**

1. In `_restoreCachedSession()`:
   - Check `authRepository.getCachedUser()`.
   - If cached user exists and `FirebaseAuth.instance.currentUser != null`:
     - `currentUser.value = cachedUser;`
     - `_syncApiClient(cachedUser);`
2. Remove any remaining demo login helper calls.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/auth_repository_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/data/auth_repository.dart lib/features/auth/controllers/auth_controller.dart test/features/auth/auth_repository_test.dart
git commit -m "feat(auth): integrate production Firebase auth with Firestore user doc provisioning and session restoration"
```

---

### Task 4: Clean Login Screen UI (Purge Quick Demo Button/Sheet)

**Files:**
- Modify: `lib/features/auth/screens/login_screen.dart:1-200`
- Delete: `lib/features/auth/widgets/quick_demo_login_sheet.dart`
- Test: `test/features/auth/login_screen_test.dart`

**Interfaces:**
- Consumes: `AuthController`
- Produces: `LoginScreen` with phone, email & password, and Google auth (no demo buttons)

- [ ] **Step 1: Write widget test for LoginScreen**

```dart
// test/features/auth/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/auth/screens/login_screen.dart';
import 'package:alogyan_app/features/auth/controllers/auth_controller.dart';
import 'package:alogyan_app/features/auth/data/auth_repository.dart';
import 'package:alogyan_app/core/cache/cache_service.dart';

void main() {
  testWidgets('LoginScreen displays real auth options without demo sheet triggers', (tester) async {
    Get.reset();
    final cacheService = CacheService();
    final authRepo = AuthRepository(cacheService: cacheService);
    Get.put(AuthController(authRepository: authRepo));

    await tester.pumpWidget(const GetMaterialApp(home: LoginScreen()));

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Email & Password'), findsOneWidget);
    expect(find.text('Quick Demo Login'), findsNothing);
  });
}
```

- [ ] **Step 2: Modify `lib/features/auth/screens/login_screen.dart`**

Remove import of `quick_demo_login_sheet.dart` and any UI elements or buttons referencing Quick Demo.
Delete `lib/features/auth/widgets/quick_demo_login_sheet.dart`.

- [ ] **Step 3: Run widget test to verify it passes**

Run: `flutter test test/features/auth/login_screen_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git rm lib/features/auth/widgets/quick_demo_login_sheet.dart
git add lib/features/auth/screens/login_screen.dart test/features/auth/login_screen_test.dart
git commit -m "refactor(auth): purge quick demo sheet and cleanly display production auth options"
```

---

### Task 5: Tenant-Scoped Student Repository & Dynamic Students Controller

**Files:**
- Modify: `lib/features/students/data/repositories/student_repository.dart:15-70`
- Modify: `lib/features/students/controllers/students_controller.dart:30-65`
- Modify: `lib/features/students/screens/students_screen.dart:50-130`
- Test: `test/features/students/students_test.dart`

**Interfaces:**
- Consumes: `StudentRepository.streamStudents(String? instituteId)`
- Produces: `StudentsController.allStudents`, `StudentsController.totalPendingDues`

- [ ] **Step 1: Write test for StudentsController with real stream and zero initial dummy students**

```dart
// test/features/students/students_test.dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';
import 'package:alogyan_app/features/students/data/repositories/student_repository.dart';

class FakeStudentRepository extends Fake implements StudentRepository {
  final _controller = StreamController<List<StudentItem>>.broadcast();

  @override
  Stream<List<StudentItem>> streamStudents({String? instituteId}) => _controller.stream;

  void emit(List<StudentItem> students) => _controller.add(students);
}

void main() {
  test('StudentsController initializes empty and updates strictly from repository stream', () async {
    final fakeRepo = FakeStudentRepository();
    final controller = StudentsController(repository: fakeRepo);

    expect(controller.allStudents, isEmpty);

    fakeRepo.emit([
      StudentItem(id: 's_01', name: 'Real Student 1', batch: 'Batch A', phone: '+919999999999', dueAmount: 1500),
    ]);
    await Future.delayed(const Duration(milliseconds: 50));

    expect(controller.allStudents.length, 1);
    expect(controller.allStudents.first.name, 'Real Student 1');
    expect(controller.totalPendingDues, 1500);
  });
}
```

- [ ] **Step 2: Update `lib/features/students/data/repositories/student_repository.dart`**

Modify `streamStudents({String? instituteId})`:
```dart
    final filterInstitute = instituteId ?? (Get.isRegistered<AuthController>() ? Get.find<AuthController>().currentUser.value?.instituteId : null);

    try {
      final db = firestore ?? FirebaseFirestore.instance;
      Query<Map<String, dynamic>> query = db.collection('students');
      if (filterInstitute != null && filterInstitute.isNotEmpty) {
        query = query.where('instituteId', isEqualTo: filterInstitute);
      }
      query.snapshots().listen((snapshot) {
        final liveStudents = snapshot.docs.map((doc) {
          final data = doc.data();
          return StudentItem(
            id: doc.id,
            name: (data['name'] as String?) ?? 'Unnamed',
            batch: (data['batch'] as String?) ?? 'General',
            phone: (data['phone'] as String?) ?? '',
            dueAmount: (data['dueAmount'] as int?) ?? 0,
          );
        }).toList();

        cacheService.cacheStudents(liveStudents.map((s) => s.toMap()).toList());
        controller.add(liveStudents);
      });
    } catch (_) {}
```

- [ ] **Step 3: Update `lib/features/students/controllers/students_controller.dart`**

Remove the 5 hardcoded dummy students in `StudentsController` constructor:
```dart
  StudentsController({this.repository});
```

- [ ] **Step 4: Update `lib/features/students/screens/students_screen.dart`**

Add an empty state view when `controller.filteredStudents.isEmpty`:
- Display icon `LucideIcons.users`, text "No students enrolled yet", and description "Students added via Alogyan Web CMS will synchronize here automatically."

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/students/students_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/features/students/data/repositories/student_repository.dart lib/features/students/controllers/students_controller.dart lib/features/students/screens/students_screen.dart test/features/students/students_test.dart
git commit -m "feat(students): scope student repository to tenant and add clean empty state"
```

---

### Task 6: Dynamic Attendance Roster & Empty States

**Files:**
- Modify: `lib/features/attendance/controllers/attendance_controller.dart:15-50`
- Modify: `lib/features/attendance/screens/quick_attendance_screen.dart:60-150`
- Test: `test/features/attendance/attendance_test.dart`

**Interfaces:**
- Consumes: `StudentsController.allStudents`
- Produces: `AttendanceController.students`, `AttendanceController.presentCount`

- [ ] **Step 1: Write test for AttendanceController binding to students dynamically**

```dart
// test/features/attendance/attendance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/attendance/controllers/attendance_controller.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';

void main() {
  test('AttendanceController roster synchronizes with StudentsController', () {
    Get.reset();
    final studentsCtrl = Get.put(StudentsController());
    final attendanceCtrl = Get.put(AttendanceController());

    expect(attendanceCtrl.students, isEmpty);

    studentsCtrl.allStudents.add(
      StudentItem(id: 's_10', name: 'Kabir Das', batch: 'Physics', phone: '+919876543210', dueAmount: 0),
    );
    attendanceCtrl.syncRosterFromStudents();

    expect(attendanceCtrl.students.length, 1);
    expect(attendanceCtrl.students.first.name, 'Kabir Das');
    expect(attendanceCtrl.presentCount, 1);
  });
}
```

- [ ] **Step 2: Update `lib/features/attendance/controllers/attendance_controller.dart`**

1. Remove the 5 hardcoded dummy students from `students`.
2. Add `syncRosterFromStudents()` that maps `StudentsController.allStudents` to `AttendanceStudent`.
3. In `onInit()`, listen to `StudentsController.allStudents` and update roster dynamically.

- [ ] **Step 3: Update `lib/features/attendance/screens/quick_attendance_screen.dart`**

Add an empty state when `controller.students.isEmpty`:
- Display icon `LucideIcons.userCheck`, title "No Students in Roster", and subtitle "Once students are enrolled in your institute, they will appear here for 1-tap attendance."

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/attendance/attendance_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/attendance/controllers/attendance_controller.dart lib/features/attendance/screens/quick_attendance_screen.dart test/features/attendance/attendance_test.dart
git commit -m "feat(attendance): bind roster dynamically to real students with responsive empty state"
```

---

### Task 7: Dynamic Fees Controller & Empty States

**Files:**
- Modify: `lib/features/fees/controllers/fee_controller.dart:15-70`
- Modify: `lib/features/fees/screens/quick_fee_screen.dart:50-130`
- Test: `test/features/fees/fees_test.dart`

**Interfaces:**
- Consumes: `StudentsController.allStudents`
- Produces: `FeeController.selectedStudent`, `FeeController.confirmPayment()`

- [ ] **Step 1: Write test for FeeController**

```dart
// test/features/fees/fees_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/fees/controllers/fee_controller.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';

void main() {
  test('FeeController handles empty student list gracefully without crash or fallback dummy', () {
    Get.reset();
    Get.put(StudentsController());
    final feeCtrl = Get.put(FeeController());

    expect(feeCtrl.selectedStudent.value, isNull);
    expect(feeCtrl.amount.value, '0');
  });
}
```

- [ ] **Step 2: Modify `lib/features/fees/controllers/fee_controller.dart`**

1. Set initial amount to `'0'`.
2. When students exist, select the first student with due amount > 0.
3. If no students exist, handle `confirmPayment` by safely aborting with a snackbar message "No student selected".

- [ ] **Step 3: Modify `lib/features/fees/screens/quick_fee_screen.dart`**

If `selectedStudent == null`:
- Render a status badge and card: "No pending student dues found. All student accounts are settled!"

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/fees/fees_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/fees/controllers/fee_controller.dart lib/features/fees/screens/quick_fee_screen.dart test/features/fees/fees_test.dart
git commit -m "feat(fees): dynamically bind fee collection to real student dues"
```

---

### Task 8: Dynamic Dashboard Schedule, Dues & Clean AppBar

**Files:**
- Modify: `lib/features/dashboard/controllers/dashboard_controller.dart:25-70`
- Modify: `lib/features/dashboard/screens/dashboard_screen.dart:150-230`
- Modify: `lib/shared/widgets/alogyan_app_bar.dart:15-35`
- Test: `test/features/dashboard/dashboard_test.dart`

**Interfaces:**
- Consumes: `AuthController.currentUser`, `StudentsController.allStudents`
- Produces: `DashboardController.todaySchedule`, `DashboardController.totalPendingDues`

- [ ] **Step 1: Write test for DashboardController**

```dart
// test/features/dashboard/dashboard_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';

void main() {
  test('DashboardController defaults to 0 batches and 0 pending dues without fallback dummy numbers', () {
    Get.reset();
    Get.put(StudentsController());
    final dashCtrl = Get.put(DashboardController());

    expect(dashCtrl.todayClassesCount, 0);
    expect(dashCtrl.totalPendingDues, 0);
  });
}
```

- [ ] **Step 2: Modify `lib/features/dashboard/controllers/dashboard_controller.dart`**

1. Remove hardcoded 3 batches in `todaySchedule`. Initialize as empty `RxList<BatchScheduleItem>()`.
2. Remove `fallbackPendingDues = 7500`. Set fallback to 0.
3. Stream today's batches from Firestore `batches` where `instituteId == activeUser.instituteId`.

- [ ] **Step 3: Modify `lib/features/dashboard/screens/dashboard_screen.dart`**

When `controller.todaySchedule.isEmpty`:
- Render an empty schedule card:
  - Icon: `LucideIcons.calendarCheck`
  - Title: "No Classes Scheduled Today"
  - Subtitle: "Enjoy your break, or schedule batches and meetings on the Alogyan CMS."

- [ ] **Step 4: Modify `lib/shared/widgets/alogyan_app_bar.dart`**

In `_getSubtitle`:
- Remove hardcoded `'Prof. Sanjoy • Physics & Maths'`.
- Format: `user != null ? '${user.name} • ${user.designation}' : 'Alogyan Companion'`.

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/dashboard/dashboard_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/features/dashboard/controllers/dashboard_controller.dart lib/features/dashboard/screens/dashboard_screen.dart lib/shared/widgets/alogyan_app_bar.dart test/features/dashboard/dashboard_test.dart
git commit -m "feat(dashboard): remove hardcoded batches and dues, dynamic schedule and app bar"
```

---

### Task 9: End-to-End Test Suite & Static Analysis Verification

**Files:**
- Modify: `test/widget_test.dart`
- Modify: `test/features/auth/auth_test.dart`

- [ ] **Step 1: Update existing tests that reference `demoProfiles`**

Update `test/widget_test.dart` and `test/features/auth/auth_test.dart` to instantiate clean test `UserModel` instances rather than referencing `UserModel.demoProfiles`.

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze`
Expected: 0 issues found.

- [ ] **Step 3: Run full test suite**

Run: `flutter test`
Expected: All tests PASS.

- [ ] **Step 4: Hot reload / restart running app**

Trigger hot restart to ensure running simulator reflects clean state.

- [ ] **Step 5: Commit**

```bash
git add test/ lib/
git commit -m "chore: ensure clean test suite and 0 analysis errors across real auth and data layer"
```
