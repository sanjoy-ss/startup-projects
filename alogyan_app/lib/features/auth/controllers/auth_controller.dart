import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/api/api_client.dart';
import '../../navigation/screens/main_navigation_shell.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';
import '../screens/login_screen.dart';
import '../screens/otp_verification_screen.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  bool get isLoggedIn => currentUser.value != null;

  // Form Controllers
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  // Observable UI States
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString activeTab = 'phone'.obs; // 'phone' | 'email'

  // Phone OTP States
  final RxString verificationId = ''.obs;
  final RxInt resendTimer = 30.obs;
  final RxBool canResendOtp = false.obs;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    _restoreCachedSession();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void _restoreCachedSession() {
    final cached = authRepository.getCachedUser();
    if (cached != null) {
      currentUser.value = cached;
      _syncApiClient(cached);
    }
  }

  void setTab(String tab) {
    activeTab.value = tab;
    errorMessage.value = '';
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void _syncApiClient(UserModel user) {
    if (Get.isRegistered<ApiClient>()) {
      final apiClient = Get.find<ApiClient>();
      apiClient.updateTenantId(user.instituteId);
    }
  }

  void _startOtpCountdown() {
    _countdownTimer?.cancel();
    resendTimer.value = 30;
    canResendOtp.value = false;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  // 1. Phone Number & OTP Flow
  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      errorMessage.value = 'Please enter a valid 10-digit mobile number.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final vId = await authRepository.sendPhoneOtp(phone);
      verificationId.value = vId;
      _startOtpCountdown();

      Get.to(() => const OtpVerificationScreen());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!canResendOtp.value) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final vId = await authRepository.sendPhoneOtp(phoneController.text);
      verificationId.value = vId;
      _startOtpCountdown();
      if (Get.context != null) {
        Get.snackbar(
          'Code Sent',
          'A fresh 6-digit OTP has been sent to +91 ${phoneController.text.trim()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String code) async {
    final otp = code.trim();
    if (otp.length != 6) {
      errorMessage.value =
          'Please enter the complete 6-digit verification code.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await authRepository.verifyPhoneOtp(
        verificationId: verificationId.value,
        smsCode: otp,
        phoneNumber: phoneController.text,
      );

      currentUser.value = user;
      _syncApiClient(user);

      if (Get.key.currentState != null) {
        Get.offAll(() => const MainNavigationShell());
        Get.snackbar(
          'Welcome, ${user.name}',
          'Signed in as ${user.designation} (${user.activeBranchName})',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Email & Password Flow
  Future<void> loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      errorMessage.value = 'Please enter a valid institutional email address.';
      return;
    }

    if (password.isEmpty || password.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await authRepository.loginWithEmail(email, password);
      currentUser.value = user;
      _syncApiClient(user);

      if (Get.key.currentState != null) {
        Get.offAll(() => const MainNavigationShell());
        Get.snackbar(
          'Welcome, ${user.name}',
          'Signed in to ${user.instituteName} (${user.activeBranchName})',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? instituteName,
    String role = 'teacher',
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await authRepository.registerWithEmail(
        name: name,
        email: email,
        password: password,
        phone: phone,
        instituteName: instituteName,
        role: role,
      );

      currentUser.value = user;
      _syncApiClient(user);

      if (Get.key.currentState != null) {
        Get.offAll(() => const MainNavigationShell());
        Get.snackbar(
          'Account Created',
          'Welcome to Alogyan, ${user.name}!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }



  // 4. Google Sign-In Flow
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await authRepository.signInWithGoogle();
      currentUser.value = user;
      _syncApiClient(user);

      if (Get.key.currentState != null) {
        Get.offAll(() => const MainNavigationShell());
        Get.snackbar(
          'Welcome, ${user.name}',
          'Signed in with Google to ${user.instituteName}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      if (Get.context != null) {
        Get.snackbar(
          'Google Sign-In',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // 5. Branch Switcher
  Future<void> switchBranch(String branchId, String branchName) async {
    final user = currentUser.value;
    if (user == null) return;

    final updated = user.copyWith(
      activeBranchId: branchId,
      activeBranchName: branchName,
    );

    await authRepository.saveUserToCache(updated);
    currentUser.value = updated;

    if (Get.context != null) {
      Get.snackbar(
        'Branch Switched',
        'Active campus: $branchName',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 6. Update Profile
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String designation,
    required String subject,
  }) async {
    final user = currentUser.value;
    if (user == null) return;

    final updated = user.copyWith(
      name: name.trim(),
      phone: phone.trim(),
      designation: designation.trim(),
      subject: subject.trim(),
    );

    await authRepository.updateUserProfile(updated);
    currentUser.value = updated;

    if (Get.context != null) {
      Get.snackbar(
        'Profile Updated',
        'Educator profile details have been saved.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 7. Sign Out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await authRepository.signOut();
      currentUser.value = null;
      otpController.clear();
      errorMessage.value = '';

      if (Get.key.currentState != null) {
        Get.offAll(() => const LoginScreen());
      }
    } finally {
      isLoading.value = false;
    }
  }
}
