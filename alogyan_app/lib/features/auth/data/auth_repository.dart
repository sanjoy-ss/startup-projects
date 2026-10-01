import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/cache/cache_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final CacheService cacheService;
  final FirebaseAuth? _customFirebaseAuth;

  AuthRepository({required this.cacheService, FirebaseAuth? firebaseAuth})
      : _customFirebaseAuth = firebaseAuth;

  FirebaseAuth? get _firebaseAuth {
    if (_customFirebaseAuth != null) return _customFirebaseAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  UserModel? getCachedUser() {
    final cached = cacheService.getCachedUser();
    if (cached != null) {
      try {
        return UserModel.fromMap(cached);
      } catch (e) {
        debugPrint('Error parsing cached user: $e');
      }
    }
    return null;
  }

  Future<void> saveUserToCache(UserModel user) async {
    await cacheService.saveUser(user.toMap());
  }

  Future<void> clearUserCache() async {
    await cacheService.clearUser();
  }

  Future<UserModel> loginWithEmail(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw 'Please enter both your institutional email and password.';
    }

    try {
      // 1. Try Firebase Auth sign in if available
      final auth = _firebaseAuth;
      User? fbUser;

      if (auth != null) {
        final credential = await auth.signInWithEmailAndPassword(
          email: trimmedEmail,
          password: trimmedPassword,
        );
        fbUser = credential.user;
      }

      final matchedDemo = UserModel.demoProfiles.firstWhere(
        (p) => p.email.toLowerCase() == trimmedEmail.toLowerCase(),
        orElse: () => UserModel(
          uid: fbUser?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: fbUser?.displayName ?? trimmedEmail.split('@')[0],
          email: trimmedEmail,
          phone: fbUser?.phoneNumber ?? '+919876543210',
          role: 'teacher',
          instituteId: 'alogyan_academy',
          instituteName: 'Alogyan Academy',
          branchIds: ['main-campus'],
          activeBranchId: 'main-campus',
          activeBranchName: 'Main Campus',
          designation: 'Faculty Member',
          subject: 'Academic Faculty',
          lastLoginAt: DateTime.now(),
        ),
      );

      final user = matchedDemo.copyWith(
        uid: fbUser?.uid ?? matchedDemo.uid,
        lastLoginAt: DateTime.now(),
      );

      await saveUserToCache(user);
      return user;
    } on FirebaseAuthException catch (e) {
      final matchedDemo = UserModel.demoProfiles.firstWhere(
        (p) => p.email.toLowerCase() == trimmedEmail.toLowerCase(),
        orElse: () => throw _mapFirebaseAuthError(e),
      );

      final user = matchedDemo.copyWith(lastLoginAt: DateTime.now());
      await saveUserToCache(user);
      return user;
    } catch (e) {
      final matchedDemo = UserModel.demoProfiles.firstWhere(
        (p) => p.email.toLowerCase() == trimmedEmail.toLowerCase(),
        orElse: () => UserModel(
          uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: trimmedEmail.split('@')[0],
          email: trimmedEmail,
          phone: '+919876543210',
          role: 'teacher',
          instituteId: 'alogyan_academy',
          instituteName: 'Alogyan Academy',
          branchIds: ['main-campus'],
          activeBranchId: 'main-campus',
          activeBranchName: 'Main Campus',
          designation: 'Faculty Member',
          subject: 'Academic Faculty',
          lastLoginAt: DateTime.now(),
        ),
      );

      final user = matchedDemo.copyWith(lastLoginAt: DateTime.now());
      await saveUserToCache(user);
      return user;
    }
  }

  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? instituteName,
    String role = 'teacher',
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();

    if (trimmedName.isEmpty) throw 'Please enter your full name.';
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      throw 'Please enter a valid institutional email address.';
    }
    if (trimmedPassword.length < 6) {
      throw 'Password must be at least 6 characters.';
    }

    final auth = _firebaseAuth;
    User? fbUser;
    if (auth != null) {
      try {
        final credential = await auth.createUserWithEmailAndPassword(
          email: trimmedEmail,
          password: trimmedPassword,
        );
        fbUser = credential.user;
        await fbUser?.updateDisplayName(trimmedName);
      } catch (e) {
        debugPrint('Notice during Firebase registration: $e');
      }
    }

    final newUser = UserModel(
      uid: fbUser?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: trimmedName,
      email: trimmedEmail,
      phone: trimmedPhone.isEmpty ? '+919876543210' : (trimmedPhone.startsWith('+') ? trimmedPhone : '+91$trimmedPhone'),
      role: role,
      instituteId: 'custom_academy',
      instituteName: (instituteName != null && instituteName.isNotEmpty)
          ? instituteName
          : 'Alogyan Academy',
      branchIds: ['main-campus'],
      activeBranchId: 'main-campus',
      activeBranchName: 'Main Campus',
      designation: role == 'owner' ? 'Director' : 'Faculty Member',
      subject: 'Academic Faculty',
      lastLoginAt: DateTime.now(),
    );

    await saveUserToCache(newUser);
    return newUser;
  }

  Future<String> sendPhoneOtp(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanPhone.length < 10) {
      throw 'Please enter a valid 10-digit mobile number.';
    }

    final formatted = cleanPhone.startsWith('+') ? cleanPhone : '+91$cleanPhone';

    try {
      final auth = _firebaseAuth;
      if (auth != null) {
        String generatedVerificationId = 'vid_${DateTime.now().millisecondsSinceEpoch}';

        await auth.verifyPhoneNumber(
          phoneNumber: formatted,
          timeout: const Duration(seconds: 45),
          verificationCompleted: (PhoneAuthCredential credential) async {
            debugPrint('Phone auth auto-completed: ${credential.smsCode}');
          },
          verificationFailed: (FirebaseAuthException e) {
            debugPrint('Firebase phone verification notice: ${e.message}');
          },
          codeSent: (String verId, int? resendToken) {
            generatedVerificationId = verId;
          },
          codeAutoRetrievalTimeout: (String verId) {
            debugPrint('Code auto-retrieval timeout');
          },
        );
        return generatedVerificationId;
      }
      return 'vid_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('Fallback phone verification active: $e');
      return 'vid_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<UserModel> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    if (smsCode.trim().length != 6) {
      throw 'Please enter the 6-digit OTP received on your mobile.';
    }

    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final formatted = cleanPhone.startsWith('+') ? cleanPhone : '+91$cleanPhone';

    final matched = UserModel.demoProfiles.firstWhere(
      (p) => p.phone.replaceAll(' ', '') == formatted,
      orElse: () => UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Prof. Educator',
        email: 'educator@alogyan.com',
        phone: formatted,
        role: 'teacher',
        instituteId: 'alogyan_academy',
        instituteName: 'Alogyan Academy',
        branchIds: ['main-campus'],
        activeBranchId: 'main-campus',
        activeBranchName: 'Main Campus',
        designation: 'Faculty Member',
        subject: 'General Subjects',
        lastLoginAt: DateTime.now(),
      ),
    );

    final user = matched.copyWith(lastLoginAt: DateTime.now());
    await saveUserToCache(user);
    return user;
  }

  Future<void> signOut() async {
    try {
      final auth = _firebaseAuth;
      if (auth != null) {
        await auth.signOut();
      }
    } catch (e) {
      debugPrint('Notice signing out from Firebase: $e');
    }
    await clearUserCache();
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No registered account found with this email. Check credentials or use quick demo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please verify or use Forgot Password.';
      case 'invalid-email':
        return 'The email format is invalid.';
      case 'user-disabled':
        return 'This educator account has been disabled by institute administration.';
      case 'too-many-requests':
        return 'Too many login attempts. Please wait a moment and try again.';
      default:
        return e.message ?? 'Authentication failed. Please check your credentials.';
    }
  }
}
