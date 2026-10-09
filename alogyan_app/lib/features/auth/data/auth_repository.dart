import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/cache/cache_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final CacheService cacheService;
  final FirebaseAuth? _customFirebaseAuth;
  final FirebaseFirestore? _customFirestore;

  AuthRepository({
    required this.cacheService,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _customFirebaseAuth = firebaseAuth,
        _customFirestore = firestore;

  FirebaseAuth? get _firebaseAuth {
    if (_customFirebaseAuth != null) return _customFirebaseAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

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

  Future<void> updateUserProfile(UserModel user) async {
    await saveUserToCache(user);
    try {
      if (user.uid.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(user.toMap());
      }
    } catch (e) {
      debugPrint('Firestore profile update notice: $e');
    }
  }

  Future<void> clearUserCache() async {
    await cacheService.clearUser();
  }

  /// Fetches an existing user document from Firestore, or provisions a new one for newly registered educators
  Future<UserModel> _fetchOrCreateUserDoc(
    User fbUser, {
    String? defaultRole,
    String? instituteName,
    String? subject,
    String? designation,
    String? phone,
  }) async {
    try {
      final docRef = _firestore.collection('users').doc(fbUser.uid);
      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final user = UserModel.fromMap(data).copyWith(
          lastLoginAt: DateTime.now(),
          photoUrl: fbUser.photoURL ?? data['photoUrl'] as String?,
        );
        // Persist last login timestamp
        docRef.update({'lastLoginAt': FieldValue.serverTimestamp()}).catchError((_) {});
        await saveUserToCache(user);
        return user;
      }

      // First time provision
      final displayName = fbUser.displayName;
      final email = fbUser.email ?? '';
      final resolvedName = (displayName != null && displayName.isNotEmpty)
          ? displayName
          : (email.isNotEmpty ? email.split('@')[0] : 'Educator');

      final effectiveRole = defaultRole ?? 'owner';
      final defaultInstId = 'inst_${fbUser.uid.length >= 8 ? fbUser.uid.substring(0, 8) : fbUser.uid}';
      final effectiveInstName = (instituteName != null && instituteName.isNotEmpty)
          ? instituteName
          : "$resolvedName's Academy";

      final effectivePhone = (phone != null && phone.isNotEmpty)
          ? phone
          : (fbUser.phoneNumber ?? '');

      final newUser = UserModel(
        uid: fbUser.uid,
        name: resolvedName,
        email: email,
        phone: effectivePhone,
        role: effectiveRole,
        instituteId: defaultInstId,
        instituteName: effectiveInstName,
        branchIds: const ['main-campus'],
        activeBranchId: 'main-campus',
        activeBranchName: 'Main Campus',
        assignedBatchIds: const [],
        designation: designation ?? (effectiveRole == 'owner' ? 'Director / Owner' : 'Faculty Member'),
        subject: subject ?? 'General',
        photoUrl: fbUser.photoURL,
        status: 'active',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await docRef.set(newUser.toMap());
      await saveUserToCache(newUser);
      return newUser;
    } catch (e) {
      debugPrint('Firestore provisioning error (falling back to offline profile): $e');
      final fallbackUser = UserModel(
        uid: fbUser.uid,
        name: fbUser.displayName ?? (fbUser.email?.split('@')[0] ?? 'Educator'),
        email: fbUser.email ?? '',
        phone: fbUser.phoneNumber ?? (phone ?? ''),
        role: defaultRole ?? 'owner',
        instituteId: 'inst_${fbUser.uid.length >= 8 ? fbUser.uid.substring(0, 8) : fbUser.uid}',
        instituteName: instituteName ?? 'Alogyan Academy',
        branchIds: const ['main-campus'],
        activeBranchId: 'main-campus',
        activeBranchName: 'Main Campus',
        assignedBatchIds: const [],
        designation: designation ?? 'Faculty Member',
        subject: subject ?? 'General',
        photoUrl: fbUser.photoURL,
        lastLoginAt: DateTime.now(),
      );
      await saveUserToCache(fallbackUser);
      return fallbackUser;
    }
  }

  // 1. Email & Password Login
  Future<UserModel> loginWithEmail(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw 'Please enter both your institutional email and password.';
    }

    final auth = _firebaseAuth;
    if (auth == null) {
      throw 'Firebase Authentication is not available. Please verify internet connection.';
    }

    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      final fbUser = credential.user;
      if (fbUser == null) {
        throw 'Authentication failed. Please verify credentials and retry.';
      }

      return await _fetchOrCreateUserDoc(fbUser);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw e.toString();
    }
  }

  // 2. Google Sign-In
  Future<UserModel> signInWithGoogle() async {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw 'Firebase Authentication is not available. Please verify network.';
    }

    try {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      final UserCredential credential = kIsWeb
          ? await auth.signInWithPopup(googleProvider)
          : await auth.signInWithProvider(googleProvider);

      final fbUser = credential.user;
      if (fbUser == null) {
        throw 'Google Sign-In failed to retrieve user account.';
      }

      return await _fetchOrCreateUserDoc(fbUser);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains('cancel') ||
          err.contains('closed') ||
          err.contains('abort')) {
        throw 'Google sign-in was cancelled.';
      }
      rethrow;
    }
  }

  // 3. Email & Password Registration
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
    if (auth == null) {
      throw 'Firebase Authentication is not available. Please verify network.';
    }

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      final fbUser = credential.user;
      if (fbUser == null) {
        throw 'Failed to create user account. Please try again.';
      }

      await fbUser.updateDisplayName(trimmedName).catchError((_) {});

      return await _fetchOrCreateUserDoc(
        fbUser,
        defaultRole: role,
        instituteName: instituteName,
        phone: trimmedPhone,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw e.toString();
    }
  }

  // 4. Send Phone OTP
  Future<String> sendPhoneOtp(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanPhone.length < 10) {
      throw 'Please enter a valid 10-digit mobile number.';
    }

    final formatted = cleanPhone.startsWith('+') ? cleanPhone : '+91$cleanPhone';

    final auth = _firebaseAuth;
    if (auth == null) {
      throw 'Firebase Authentication is not available.';
    }

    final completer = Completer<String>();

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: formatted,
        timeout: const Duration(seconds: 45),
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('Phone auth auto-completed verification');
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(_mapFirebaseAuthError(e));
          }
        },
        codeSent: (String verId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(verId);
          }
        },
        codeAutoRetrievalTimeout: (String verId) {
          if (!completer.isCompleted) {
            completer.complete(verId);
          }
        },
      );
      return await completer.future;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw e.toString();
    }
  }

  // 5. Verify Phone OTP
  Future<UserModel> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    final cleanCode = smsCode.trim();
    if (cleanCode.length != 6) {
      throw 'Please enter the 6-digit OTP received on your mobile.';
    }

    final auth = _firebaseAuth;
    if (auth == null) {
      throw 'Firebase Authentication is not available.';
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: cleanCode,
      );

      final userCred = await auth.signInWithCredential(credential);
      final fbUser = userCred.user;
      if (fbUser == null) {
        throw 'Failed to sign in with phone verification code.';
      }

      return await _fetchOrCreateUserDoc(
        fbUser,
        phone: phoneNumber,
        defaultRole: 'teacher',
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw e.toString();
    }
  }

  // 6. Sign Out
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
        return 'No registered account found with this email. Please sign up or verify credentials.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please verify and retry.';
      case 'invalid-email':
        return 'The email format is invalid.';
      case 'user-disabled':
        return 'This educator account has been disabled by institute administration.';
      case 'too-many-requests':
        return 'Too many login attempts. Please wait a moment and try again.';
      case 'popup-closed-by-user':
      case 'canceled':
        return 'Sign-in was cancelled.';
      case 'invalid-verification-code':
        return 'The 6-digit verification code entered is incorrect or expired.';
      case 'invalid-verification-id':
        return 'The verification session has expired. Please request a new code.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      default:
        return e.message ?? 'Authentication failed. Please check your credentials.';
    }
  }
}
