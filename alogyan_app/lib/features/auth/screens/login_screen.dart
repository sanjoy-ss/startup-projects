import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/mascot_data.dart';
import '../../../core/widgets/mascot_holding_sheet_wrapper.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/quick_demo_login_sheet.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    final topPadding = MediaQuery.of(context).padding.top;
    final headerWaveHeight = math.max(225.0, 180.0 + topPadding);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            // 1. Organic Red Background Curve Wave at the Top (Edge-to-edge under status bar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerWaveHeight,
              child: CustomPaint(painter: _RedWaveHeaderPainter()),
            ),

            // 2. Main Interactive Content (Full viewport occupying, one view-wise, responsive & evenly distributed)
            SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 440,
                            minHeight: math.max(
                              0.0,
                              constraints.maxHeight - 20,
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 1. Dynamic Header (Top)
                                _buildDynamicHeader(),

                                // 2. Open Auth Flow (Middle)
                                _buildAuthFlow(context, controller),

                                const SizedBox(height: 16),

                                // Bottom Group: Terms & Conditions + Security Footer (Pinned cleanly at the bottom)
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildTermsAndPrivacyNotice(context),
                                    // const SizedBox(height: 8),
                                    // _buildSecurityFooter(context),
                                    // const SizedBox(height: 4),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Open Authentication Flow directly on the canvas without boxy card boundaries
  Widget _buildAuthFlow(BuildContext context, AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Mobile OTP Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Sign In',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AlogyanColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage attendance, fees, and students seamlessly.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            color: AlogyanColors.textSecondary,
            height: 1.35,
          ),
        ),

        const SizedBox(height: 20),

        // Phone Input Form
        _buildPhoneForm(controller),

        // Error Banner
        Obx(() {
          final error = controller.errorMessage.value;
          if (error.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AlogyanColors.dangerLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AlogyanColors.danger.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.alertCircle,
                  size: 16,
                  color: AlogyanColors.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AlogyanColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),

        // Primary Action: Continue with Phone
        Obx(() => _buildPrimaryButton(controller)),

        const SizedBox(height: 20),

        // Modern Divider
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AlogyanColors.border)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'or continue with',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AlogyanColors.textMuted,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: AlogyanColors.border)),
          ],
        ),

        const SizedBox(height: 16),

        // Google Sign-In Button (Opens Separated Account Sheet)
        _buildGoogleButton(context, controller),

        const SizedBox(height: 10),

        // Email & Password Button (Opens Separated Sheet)
        _buildEmailPasswordButton(context, controller),
      ],
    );
  }

  /// Dynamic Header displaying brand text on the left and freestanding mascot flying in side-wise on the right
  Widget _buildDynamicHeader() {
    return SizedBox(
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Left Side: Brand Emblem, Title & Companion Badge
          Positioned(
            left: 2,
            top: 10,
            right: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand Mark with Graduation Cap
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.graduationCap,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Row(
                      children: const [
                        Text(
                          'Alogyan',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFCDD2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Educator Companion Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Educator Companion',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Welcome Heading
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),

          // Right Side: Mascot Flying in Side-wise (Freestanding with pure alpha transparency)
          Positioned(
            right: -6,
            top: 0,
            width: 140,
            height: 140,
            child: Image.memory(AlogyanMascot.bytes, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm(AuthController controller) {
    return Column(
      key: const ValueKey('phone_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          label: 'Mobile Number',
          hintText: '98765 43210',
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          prefixIcon: Container(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                const Text(
                  '+91',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AlogyanColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 18, color: AlogyanColors.border),
              ],
            ),
          ),
          helperText: 'A 6-digit OTP code will be sent to verify your device.',
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(AuthController controller) {
    final isLoading = controller.isLoading.value;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : controller.sendOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AlogyanColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 1,
          shadowColor: AlogyanColors.primary.withValues(alpha: 0.35),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Sending OTP...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Flexible(
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(LucideIcons.arrowRight, size: 16),
                ],
              ),
      ),
    );
  }

  /// Clean Google Sign-in Button with official 4-color Google G icon
  Widget _buildGoogleButton(BuildContext context, AuthController controller) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showGoogleSheet(context, controller),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AlogyanColors.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            _GoogleLogoWidget(),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Continue with Google',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AlogyanColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Email & Password button that matches "Continue with Google" in geometry, styling & hierarchy
  Widget _buildEmailPasswordButton(
    BuildContext context,
    AuthController controller,
  ) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showEmailPasswordSheet(context, controller),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AlogyanColors.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(LucideIcons.mail, size: 18, color: AlogyanColors.textPrimary),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Continue with Email & Password',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AlogyanColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Interactive, linkable Terms of Service & Privacy Policy with responsive touch areas
  Widget _buildTermsAndPrivacyNotice(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'By continuing, you agree to our ',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AlogyanColors.textSecondary,
              height: 1.45,
            ),
          ),
          InkWell(
            onTap: () => _showTermsOfServiceSheet(context),
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              child: Text(
                'Terms of Service',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AlogyanColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AlogyanColors.primary,
                  decorationThickness: 1.3,
                ),
              ),
            ),
          ),
          const Text(
            ' and ',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AlogyanColors.textSecondary,
              height: 1.45,
            ),
          ),
          InkWell(
            onTap: () => _showPrivacyPolicySheet(context),
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AlogyanColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AlogyanColors.primary,
                  decorationThickness: 1.3,
                ),
              ),
            ),
          ),
          const Text(
            '.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AlogyanColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Clean separated bottom sheet for Institutional Google account sign-in
  void _showGoogleSheet(BuildContext context, AuthController controller) {
    QuickDemoLoginSheet.show(context, (user) {
      controller.loginWithDemo(user);
    });
  }

  /// Clean separated bottom sheet for Email & Password authentication & registration
  void _showEmailPasswordSheet(
    BuildContext context,
    AuthController controller,
  ) {
    controller.setTab('email');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsetsGeometry.zero,
        // padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: MascotHoldingSheetWrapper(
          child: _EmailAuthSheetContent(controller: controller),
        ),
      ),
    );
  }

  static void showForgotPasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MascotHoldingSheetWrapper(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Password resets are managed by your Institute Admin on the Alogyan Teachers Web CMS, or you can sign in directly using Mobile OTP.',
                style: TextStyle(
                  fontSize: 13,
                  color: AlogyanColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bespoke, attractive bottom sheet for Terms of Service
  void _showTermsOfServiceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MascotHoldingSheetWrapper(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.80,
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AlogyanColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AlogyanColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.fileText,
                        color: AlogyanColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Terms of Service',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AlogyanColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Alogyan Educator & Institute Agreement',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.x,
                      size: 20,
                      color: AlogyanColors.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: AlogyanColors.border, height: 1),
              const SizedBox(height: 16),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: const [
                      _LegalClauseItem(
                        icon: LucideIcons.graduationCap,
                        title: 'Authorized Educator Use',
                        description: 'Alogyan Companion is licensed exclusively to verified coaching institute staff and private tutors to manage schedules, student rosters, and fee collection.',
                      ),
                      SizedBox(height: 14),
                      _LegalClauseItem(
                        icon: LucideIcons.database,
                        title: 'Offline-First Ledger Integrity',
                        description: 'Attendance entries and fee records recorded offline are cryptographically journaled locally and reconciled immediately once network connectivity is re-established.',
                      ),
                      SizedBox(height: 14),
                      _LegalClauseItem(
                        icon: LucideIcons.userCheck,
                        title: 'Student & Guardian Confidentiality',
                        description: 'Educators agree to preserve strict confidentiality of student academic progress, attendance history, and guardian contact credentials.',
                      ),
                      SizedBox(height: 14),
                      _LegalClauseItem(
                        icon: LucideIcons.receipt,
                        title: 'Auditing & Fee Records',
                        description: 'All payment receipts generated serve as administrative records between your coaching center and enrolled students under institute oversight.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Accept / Dismiss Button
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AlogyanColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'I Agree & Understand',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bespoke, attractive bottom sheet for Privacy Policy
  void _showPrivacyPolicySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MascotHoldingSheetWrapper(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.80,
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 24,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AlogyanColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AlogyanColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.shieldCheck,
                        color: AlogyanColors.success,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AlogyanColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your data is end-to-end encrypted and never sold',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.x,
                      size: 20,
                      color: AlogyanColors.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: AlogyanColors.border, height: 1),
              const SizedBox(height: 16),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: const [
                      _LegalClauseItem(
                        icon: LucideIcons.lock,
                        title: '256-Bit TLS Encryption',
                        description: 'All data transfers between the mobile companion and Alogyan Cloud are encrypted in transit using 256-bit TLS 1.3 protocol standards.',
                      ),
                      SizedBox(height: 14),
                      _LegalClauseItem(
                        icon: LucideIcons.smartphone,
                        title: 'Protected Local Sandbox',
                        description: 'Offline student records and attendance tables are securely stored inside your device sandbox and isolated from other mobile applications.',
                      ),
                      SizedBox(height: 14),
                      _LegalClauseItem(
                        icon: LucideIcons.shieldAlert,
                        title: 'Zero Third-Party Advertising',
                        description: 'Alogyan never sells, monetizes, or shares teacher or student personal details with third-party advertisement networks or data brokers.',
                      ),
                      SizedBox(height: 14),
                      _LegalClauseItem(
                        icon: LucideIcons.building,
                        title: 'Institute Data Custody',
                        description: 'Your coaching institute administrators retain full rights to update, archive, or permanently delete institutional and student profiles.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Dismiss Button
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AlogyanColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'I Understand',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modern, multi-flow bottom sheet for Email & Password authentication
/// with both Institutional Sign In and Free Educator Registration (Sign Up)
class _EmailAuthSheetContent extends StatefulWidget {
  final AuthController controller;

  const _EmailAuthSheetContent({required this.controller});

  @override
  State<_EmailAuthSheetContent> createState() => _EmailAuthSheetContentState();
}

class _EmailAuthSheetContentState extends State<_EmailAuthSheetContent> {
  int _activeTabIndex = 0; // 0 = Sign In, 1 = Sign Up Free
  bool _obscureSignInPassword = true;
  bool _obscureSignUpPassword = true;

  // Sign Up Form Controllers
  final _nameController = TextEditingController();
  final _instituteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'tutor'; // 'tutor', 'coaching', 'teacher'
  String? _validationError;

  @override
  void dispose() {
    _nameController.dispose();
    _instituteController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    if (_validationError != null) {
      setState(() => _validationError = null);
    }
    if (widget.controller.errorMessage.value.isNotEmpty) {
      widget.controller.errorMessage.value = '';
    }
  }

  void _handleSignIn() {
    _clearErrors();
    widget.controller.loginWithEmail();
  }

  void _handleSignUp() {
    _clearErrors();
    final name = _nameController.text.trim();
    final institute = _instituteController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      setState(() => _validationError = 'Please enter your full name.');
      return;
    }
    if (phone.length != 10) {
      setState(
        () => _validationError = 'Please enter a valid 10-digit mobile number.',
      );
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _validationError = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(
        () => _validationError = 'Password must be at least 6 characters.',
      );
      return;
    }

    widget.controller.registerWithEmail(
      name: name,
      email: email,
      password: password,
      phone: phone,
      instituteName: institute.isEmpty ? null : institute,
      role: _selectedRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.88),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        math.max(20.0, keyboardHeight + 10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top subtle grab handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AlogyanColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Row: Title & Subtitle + Close (X) button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _activeTabIndex == 0
                          ? 'Educator Sign In'
                          : 'Create Free Account',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AlogyanColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _activeTabIndex == 0
                          ? 'Institutional credentials for coaching & tuition'
                          : 'Join thousands of tutors & coaching centers',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: AlogyanColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.x,
                  size: 20,
                  color: AlogyanColors.textSecondary,
                ),
                onPressed: () => Navigator.pop(context),
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Error Banner
          Obx(() {
            final err =
                _validationError ?? widget.controller.errorMessage.value;
            if (err.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AlogyanColors.dangerLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AlogyanColors.danger.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 16,
                    color: AlogyanColors.danger,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      err,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AlogyanColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Scrollable Form Body
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _activeTabIndex == 0
                  ? _buildSignInForm()
                  : _buildSignUpForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          label: 'Institutional Email',
          hintText: 'teacher@institute.edu',
          controller: widget.controller.emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            LucideIcons.mail,
            size: 18,
            color: AlogyanColors.textSecondary,
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: 14),
        AuthTextField(
          label: 'Password',
          hintText: '••••••••',
          controller: widget.controller.passwordController,
          obscureText: _obscureSignInPassword,
          textInputAction: TextInputAction.done,
          onEditingComplete: _handleSignIn,
          prefixIcon: const Icon(
            LucideIcons.lock,
            size: 18,
            color: AlogyanColors.textSecondary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureSignInPassword ? LucideIcons.eyeOff : LucideIcons.eye,
              size: 18,
              color: AlogyanColors.textSecondary,
            ),
            onPressed: () => setState(
              () => _obscureSignInPassword = !_obscureSignInPassword,
            ),
          ),
          trailingLabelAction: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              LoginScreen.showForgotPasswordSheet(context);
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AlogyanColors.primary,
              ),
            ),
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: 20),
        Obx(() {
          final isLoading = widget.controller.isLoading.value;
          return SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AlogyanColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 1,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Flexible(
                          child: Text(
                            'Sign In to Alogyan',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(LucideIcons.arrowRight, size: 16),
                      ],
                    ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () {
              _clearErrors();
              setState(() => _activeTabIndex = 1);
            },
            child: RichText(
              text: const TextSpan(
                text: "Don't have an educator account? ",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AlogyanColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Sign Up Free',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AlogyanColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role Selector
        const Text(
          'I am registering as',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AlogyanColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildRoleChip(
                role: 'tutor',
                label: 'Private Tutor',
                icon: LucideIcons.userCheck,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRoleChip(
                role: 'coaching',
                label: 'Coaching',
                icon: LucideIcons.building2,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRoleChip(
                role: 'teacher',
                label: 'Faculty',
                icon: LucideIcons.graduationCap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Full Name
        AuthTextField(
          label: 'Full Name',
          hintText: 'e.g. Dr. Rajesh Sen',
          controller: _nameController,
          prefixIcon: const Icon(
            LucideIcons.user,
            size: 18,
            color: AlogyanColors.textSecondary,
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: 12),

        // Institute / Coaching Name
        AuthTextField(
          label: _selectedRole == 'tutor'
              ? 'Classes / Batch Name'
              : 'Institute Name',
          hintText: _selectedRole == 'tutor'
              ? 'e.g. Sen Physics Classes'
              : 'e.g. Apex Coaching Institute',
          controller: _instituteController,
          prefixIcon: const Icon(
            LucideIcons.building,
            size: 18,
            color: AlogyanColors.textSecondary,
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: 12),

        // Mobile Number
        AuthTextField(
          label: 'Mobile Number',
          hintText: '98765 43210',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          prefixIcon: Container(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇮🇳', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 5),
                const Text(
                  '+91',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AlogyanColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(width: 1, height: 16, color: AlogyanColors.border),
              ],
            ),
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: 12),

        // Email Address
        AuthTextField(
          label: 'Email Address',
          hintText: 'rajesh@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            LucideIcons.mail,
            size: 18,
            color: AlogyanColors.textSecondary,
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: 12),

        // Password
        AuthTextField(
          label: 'Create Password',
          hintText: 'Min. 6 characters',
          controller: _passwordController,
          obscureText: _obscureSignUpPassword,
          textInputAction: TextInputAction.done,
          onEditingComplete: _handleSignUp,
          prefixIcon: const Icon(
            LucideIcons.lock,
            size: 18,
            color: AlogyanColors.textSecondary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureSignUpPassword ? LucideIcons.eyeOff : LucideIcons.eye,
              size: 18,
              color: AlogyanColors.textSecondary,
            ),
            onPressed: () => setState(
              () => _obscureSignUpPassword = !_obscureSignUpPassword,
            ),
          ),
          onChanged: (_) => _clearErrors(),
        ),
        const SizedBox(height: 18),

        // Create Account Button
        Obx(() {
          final isLoading = widget.controller.isLoading.value;
          return SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AlogyanColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 1,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Flexible(
                          child: Text(
                            'Create Free Educator Account',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(LucideIcons.arrowRight, size: 16),
                      ],
                    ),
            ),
          );
        }),
        const SizedBox(height: 12),

        // Trust badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              LucideIcons.shieldCheck,
              size: 13,
              color: AlogyanColors.textMuted,
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                '100% Free for Independent Tutors • No Card Required',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AlogyanColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Switcher prompt: Already registered? Sign In
        Center(
          child: GestureDetector(
            onTap: () {
              _clearErrors();
              setState(() => _activeTabIndex = 0);
            },
            child: RichText(
              text: const TextSpan(
                text: 'Already registered? ',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AlogyanColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AlogyanColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRoleChip({
    required String role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFECEB) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AlogyanColors.primary : AlogyanColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AlogyanColors.primary
                  : AlogyanColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AlogyanColors.primary
                    : AlogyanColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Clean, human-designed scannable item for Terms and Privacy sheets
class _LegalClauseItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _LegalClauseItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: AlogyanColors.surfaceMuted,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AlogyanColors.border),
          ),
          child: Center(
            child: Icon(icon, size: 16, color: AlogyanColors.textPrimary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AlogyanColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AlogyanColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Organic Red Background Curve Wave Painter for energetic, modern brand identity
/// Built with mathematically collinear G1-continuous cubic Béziers for silky smooth curvature.
/// Features high-visibility engineering textures (contour ribbons, dual-layer crest shimmer,
/// technical dot-matrix grid, orbit rings, and floating sparkles).
class _RedWaveHeaderPainter extends CustomPainter {
  /// Builds a G1-continuous wave path using two collinear cubic Bézier spans
  Path _buildWavePath({
    required double y0,
    required double c1x,
    required double c1y,
    required double xm,
    required double ym,
    required double tanDx,
    required double tanDy,
    required double c4x,
    required double c4y,
    required double yEnd,
    required double width,
    double yOffset = 0.0,
  }) {
    final path = Path();
    path.moveTo(0, y0 + yOffset);
    path.cubicTo(
      c1x,
      c1y + yOffset,
      xm - tanDx,
      ym - tanDy + yOffset,
      xm,
      ym + yOffset,
    );
    path.cubicTo(
      xm + tanDx,
      ym + tanDy + yOffset,
      c4x,
      c4y + yOffset,
      width,
      yEnd + yOffset,
    );
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Vibrant Alogyan Brand Red Linear Gradient
    final wavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFE53935), // Alogyan vibrant red
          Color(0xFFB71C1C), // Deep crimson
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    // 2. Collinear G1-Continuous Cubic Bézier Wave Parameters
    final y0 = size.height * 0.76;
    final c1x = size.width * 0.22;
    final c1y = size.height * 0.90;

    final xm = size.width * 0.54;
    final ym = size.height * 0.83;

    final tanDx = size.width * 0.18;
    final tanDy = -size.height * 0.035;

    final c4x = size.width * 0.84;
    final c4y = size.height * 0.75;
    final yEnd = size.height * 0.85;

    final waveLine = _buildWavePath(
      y0: y0,
      c1x: c1x,
      c1y: c1y,
      xm: xm,
      ym: ym,
      tanDx: tanDx,
      tanDy: tanDy,
      c4x: c4x,
      c4y: c4y,
      yEnd: yEnd,
      width: size.width,
    );

    final filledPath = Path.from(waveLine)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(filledPath, wavePaint);

    // // 3. Technical Dot-Matrix Grid across the upper red canvas
    // final dotGridPaint = Paint()..color = Colors.white.withValues(alpha: 0.12);
    // const spacing = 24.0;
    // for (double x = 8.0; x < size.width; x += spacing) {
    //   for (double y = 14.0; y < size.height * 0.70; y += spacing) {
    //     canvas.drawCircle(Offset(x, y), 1.1, dotGridPaint);
    //   }
    // }

    // 4. Highly Visible Multi-Layered Flowing Contour Ribbons
    // Ribbon 1: Bold Secondary Ribbon
    final ribbon1 = _buildWavePath(
      y0: y0,
      c1x: c1x,
      c1y: c1y,
      xm: xm,
      ym: ym,
      tanDx: tanDx,
      tanDy: tanDy,
      c4x: c4x,
      c4y: c4y,
      yEnd: yEnd,
      width: size.width,
      yOffset: -24.0,
    );
    final ribbon1Paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(ribbon1, ribbon1Paint);

    // Ribbon 2: Mid Tertiary Contour Ribbon
    final ribbon2 = _buildWavePath(
      y0: y0,
      c1x: c1x,
      c1y: c1y,
      xm: xm,
      ym: ym,
      tanDx: tanDx,
      tanDy: tanDy,
      c4x: c4x,
      c4y: c4y,
      yEnd: yEnd,
      width: size.width,
      yOffset: -46.0,
    );
    final ribbon2Paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(ribbon2, ribbon2Paint);

    // Ribbon 3: Fine Quaternary Contour Line
    final ribbon3 = _buildWavePath(
      y0: y0,
      c1x: c1x,
      c1y: c1y,
      xm: xm,
      ym: ym,
      tanDx: tanDx,
      tanDy: tanDy,
      c4x: c4x,
      c4y: c4y,
      yEnd: yEnd,
      width: size.width,
      yOffset: -68.0,
    );
    final ribbon3Paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(ribbon3, ribbon3Paint);

    // 5. Dual-Layer Luminous Crest Shimmer Edge
    // Layer A: Outer Diffuse Glow
    final glowShimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.32),
          Colors.white.withValues(alpha: 0.48),
          Colors.white.withValues(alpha: 0.32),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(waveLine, glowShimmerPaint);

    // Layer B: Ultra-Crisp High-Luminance Core Line
    final coreShimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.70),
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.70),
          Colors.white.withValues(alpha: 0.15),
        ],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(waveLine, coreShimmerPaint);

    // 6. Mascot Light Stage Halo & Concentric Orbit Rings
    final mascotStage = Offset(size.width * 0.82, size.height * 0.42);
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.22),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: mascotStage, radius: size.width * 0.42),
          );
    canvas.drawCircle(mascotStage, size.width * 0.42, glowPaint);

    final orbit1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(mascotStage, 58, orbit1);

    final orbit2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(mascotStage, 96, orbit2);

    final orbit3 = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(mascotStage, 140, orbit3);

    // 7. Floating 4-Point Micro-Sparkles
    _drawSparkle(
      canvas,
      Offset(size.width * 0.16, size.height * 0.22),
      4.8,
      0.55,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.48, size.height * 0.14),
      4.2,
      0.50,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.64, size.height * 0.26),
      4.0,
      0.45,
    );
  }

  /// Draws a crisp 4-point sparkle star with bright core glint
  void _drawSparkle(Canvas canvas, Offset center, double size, double alpha) {
    if (alpha <= 0.0) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);
    path.close();
    canvas.drawPath(path, paint);

    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: (alpha * 1.5).clamp(0.0, 1.0));
    canvas.drawCircle(center, size * 0.28, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Crisp, authentic 4-color Google "G" logo
class _GoogleLogoWidget extends StatelessWidget {
  const _GoogleLogoWidget();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/svg/logo_google.svg",
      height: 20,
      width: 20,
    );
  }
}
