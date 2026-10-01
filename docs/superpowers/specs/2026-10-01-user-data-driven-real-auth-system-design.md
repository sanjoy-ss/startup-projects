# Alogyan Flutter Companion: User Data-Driven Architecture & Real Authentication Specification

- **Date:** 2026-10-01
- **Status:** Approved
- **Target App:** [`alogyan_app`](file:///Users/sanjoysarkar/web_app/start-up-projects/alogyan_app)
- **Scope:** Complete removal of dummy/mock data, implementation of production Firebase Authentication (Google, Phone OTP, Email & Password), Firestore multi-tenant data binding, and dynamic user-scoped UI.

---

## 1. Executive Summary & Problem Statement

Prior iterations of [`alogyan_app`](file:///Users/sanjoysarkar/web_app/start-up-projects/alogyan_app) contained mock fallbacks, hardcoded student lists (`Aarav Sharma`, `Diya Sen`, `Ishaan Roy`, `Meera Patel`, `Rohan Das`), static demo persona buttons, artificial phone OTP simulation, and static dashboard metrics (3 hardcoded classes and ₹7,500 fallback pending dues).

This specification establishes a clean, production-grade architecture where:
1. **All dummy data, demo personas, and artificial seeds are completely removed.**
2. **All 3 authentication methods (Google, Phone OTP, Email & Password) communicate strictly with Firebase Auth and Firestore.**
3. **All application screens and statistics are dynamically driven by the authenticated user's real Firestore data** (`users/{uid}` and collections filtered by `instituteId`), presenting responsive empty states when a user's roster or schedule is newly initialized.

---

## 2. Authentication Architecture

### 2.1 Google Sign-In Flow
1. **Trigger**: User taps "Continue with Google" on the login screen.
2. **Provider**: `FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider())` on mobile devices; `signInWithPopup(GoogleAuthProvider())` on web.
3. **Profile Ingestion**:
   - Obtain authenticated `User` from `UserCredential`.
   - Query Firestore `users/{user.uid}`.
   - If document exists: deserialize into `UserModel`.
   - If document does not exist: create `users/{user.uid}` with:
     ```dart
     {
       'uid': user.uid,
       'name': user.displayName ?? (user.email?.split('@')[0] ?? 'Educator'),
       'email': user.email ?? '',
       'phone': user.phoneNumber ?? '',
       'role': 'owner',
       'instituteId': 'inst_${user.uid.substring(0, 8)}',
       'instituteName': "${user.displayName ?? 'My'}'s Academy",
       'branchIds': ['main-campus'],
       'activeBranchId': 'main-campus',
       'activeBranchName': 'Main Campus',
       'assignedBatchIds': [],
       'designation': 'Director / Owner',
       'subject': 'General',
       'photoUrl': user.photoURL,
       'status': 'active',
       'createdAt': FieldValue.serverTimestamp(),
       'lastLoginAt': FieldValue.serverTimestamp(),
     }
     ```
4. **Local Cache & State**: Save `UserModel` into Hive `user_box`, update `AuthController.currentUser`, and update `ApiClient.updateTenantId(user.instituteId)`.

### 2.2 Phone Number & OTP Verification Flow
1. **SMS Trigger**:
   - `phoneController.text` is formatted to E.164 standard (`+91XXXXXXXXXX`).
   - `auth.verifyPhoneNumber(...)` uses a `Completer<String>` waiting for `codeSent(verificationId, resendToken)`.
   - Returns the true Firebase verification ID (or throws standard Firebase verification errors).
   - Starts a 30-second resend countdown timer in UI.
2. **OTP Verification**:
   - User inputs 6-digit code in `OtpVerificationScreen`.
   - App constructs `PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode)`.
   - Calls `auth.signInWithCredential(credential)`.
   - Obtains `user.uid`, queries `users/{user.uid}` from Firestore, initializes document if first login, updates cache, and navigates to `MainNavigationShell`.

### 2.3 Email & Password Flow
1. **Sign In**:
   - Calls `auth.signInWithEmailAndPassword(email, password)`.
   - Retrieves `users/{user.uid}` from Firestore.
   - Surface clean, user-friendly error messages if credentials fail (e.g. wrong password, user not found).
2. **Registration**:
   - Calls `auth.createUserWithEmailAndPassword(email, password)`.
   - Updates display name with `user.updateDisplayName(name)`.
   - Creates `users/{user.uid}` in Firestore with user input fields (name, institute name, phone, role).
   - Saves to cache and launches main shell.

### 2.4 Cold Launch Session Recovery & Sign Out
1. **Session Recovery**:
   - In `AuthController._restoreCachedSession()`, read `cacheService.getCachedUser()`.
   - If cached user exists and `FirebaseAuth.instance.currentUser != null`, immediately restore `currentUser.value = cachedUser` and configure `ApiClient`.
   - The app's root router (`AlogyanApp`) will immediately route authenticated users to `MainNavigationShell()`.
2. **Sign Out**:
   - `signOut()` triggers `FirebaseAuth.instance.signOut()`, deletes `active_user` from Hive `user_box`, resets `currentUser.value = null`, and resets navigation to `LoginScreen`.

---

## 3. Multi-Tenant Data Layer & Firestore Schema

All domain data is structured in top-level collections filtered by `instituteId`, matching the Web CMS schema:

### 3.1 Collections

#### 1. `users/{uid}`
- Top-level document per authenticated user.
- Contains identity, role (`owner` | `teacher` | `branch_manager`), `instituteId`, and `activeBranchId`.

#### 2. `students`
- Filtered by: `where('instituteId', isEqualTo: user.instituteId)`
- Model: `StudentItem` (`id`, `name`, `batch`, `phone`, `dueAmount`, `instituteId`, `createdAt`).
- Streamed in `StudentRepository.streamStudents(String instituteId)`.

#### 3. `batches`
- Filtered by: `where('instituteId', isEqualTo: user.instituteId)`
- Model: `BatchScheduleItem` (`id`, `time`, `batchName`, `roomOrMeet`, `status`, `statusType`, `meetLink`, `instituteId`).
- Streamed in `DashboardController.streamBatches(String instituteId)`.

#### 4. `attendance`
- Document ID: `${instituteId}_${batchId}_${date}`
- Fields: `instituteId`, `batchId`, `date`, `records` (map of `studentId -> 'present' | 'absent' | 'late'`), `updatedAt`.
- Streamed and saved in `AttendanceRepository`.

#### 5. `fees`
- Records of payments collected: `instituteId`, `studentId`, `studentName`, `amount`, `paymentMode`, `collectedBy`, `timestamp`.

---

## 4. Complete Dummy Data Removal

| Target File | Item to Remove | Replacement / New Behavior |
|---|---|---|
| `lib/core/cache/cache_service.dart` | `_seedInitialStudents()` method and invocation | Completely removed. Clear existing cached student records if they match dummy IDs. |
| `lib/core/cache/cache_service.dart` | Hardcoded `return false;` in `hasCompletedOnboarding()` | Read from `_settingsBox.get('completed_onboarding') ?? false`. |
| `lib/features/students/controllers/students_controller.dart` | Hardcoded `StudentItem` list in constructor | Initialize with empty list `RxList<StudentItem>()`. Bind to `StudentRepository.streamStudents()`. |
| `lib/features/attendance/controllers/attendance_controller.dart` | Hardcoded list of 5 students in constructor | Dynamically derive roster from `StudentsController.allStudents`. |
| `lib/features/dashboard/controllers/dashboard_controller.dart` | Hardcoded `todaySchedule` and `fallbackPendingDues = 7500` | Stream real batches from Firestore (empty if none). Compute dues strictly from real students sum. |
| `lib/features/auth/models/user_model.dart` | `demoProfiles` static list | Removed. |
| `lib/features/auth/screens/login_screen.dart` | `QuickDemoLoginSheet` button & modal call | Removed. |
| `lib/features/auth/widgets/user_profile_modal.dart` | "Switch Demo Persona" tile & persona picker | Removed. Replaced with real account info & Logout button. |
| `lib/shared/widgets/alogyan_app_bar.dart` | Fallback text `'Prof. Sanjoy • Physics & Maths'` | Display authenticated user's real name & role/subject, or fallback to `'Educator'`. |

---

## 5. UI & Empty State Specifications

1. **Dashboard**:
   - `0 Batches` displayed when no batches exist for the day.
   - `₹0` pending dues when no students have pending balances.
   - Empty state widget for "Today's Schedule" when no classes are scheduled, prompting educator with quick actions.
2. **Attendance**:
   - Roster populated from real students. If no students exist, shows a clear card: *"No students found in this batch. Add students in the Alogyan CMS to record attendance."*
3. **Fees**:
   - Student picker displays real students. If no students have dues, displays: *"All students up to date! No pending dues."*
4. **Students**:
   - Searchable student list showing real students. If empty, displays: *"No students enrolled yet."*

---

## 6. Verification & Testing

1. **Static Analysis**: `flutter analyze` must pass with 0 errors.
2. **Unit & Widget Tests**: Update tests in `test/` to mock/test real repositories and empty states instead of relying on `demoProfiles`.
3. **Manual Flow Verification**:
   - Sign in with Google: creates/reads Firestore document, updates UI.
   - Sign in with Phone: sends OTP via Firebase, verifies SMS code, updates UI.
   - Sign in / Sign up with Email: creates/reads Firestore document, handles auth errors properly.
   - Cold restart app: preserves user session and opens `MainNavigationShell` directly.
   - Sign out: clears cache, returns to `LoginScreen`.
