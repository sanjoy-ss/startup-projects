import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            // 1. Organic Red Background Curve Wave at the Top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 230,
              child: CustomPaint(painter: _RedWaveHeaderPainter()),
            ),

            // 2. Main Interactive Scrollable Content (Clean, Card-less Canvas Layout)
            SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Dynamic Header: Left Brand Info & Right Side-Wise Flying Mascot
                          _buildDynamicHeader(),

                          const SizedBox(height: 18),

                          // Open Authentication Flow (Direct on Canvas, No Enclosing Card)
                          _buildAuthFlow(context, controller),

                          const SizedBox(height: 24),

                          // Linkable Terms & Conditions and Privacy Policy
                          _buildTermsAndPrivacyNotice(context),

                          const SizedBox(height: 16),

                          // Security & Institute Footer
                          _buildSecurityFooter(context),
                        ],
                      ),
                    ),
                  ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AlogyanColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AlogyanColors.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AlogyanColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Mobile OTP',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AlogyanColors.primary,
                    ),
                  ),
                ],
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

  /// Email & Password button that opens a clean separated bottom sheet
  Widget _buildEmailPasswordButton(
    BuildContext context,
    AuthController controller,
  ) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _showEmailPasswordSheet(context, controller),
        icon: const Icon(
          LucideIcons.mail,
          size: 16,
          color: AlogyanColors.textSecondary,
        ),
        label: const Text(
          'Email & Password',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AlogyanColors.textSecondary,
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: AlogyanColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

  Widget _buildSecurityFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              LucideIcons.shieldCheck,
              size: 13,
              color: AlogyanColors.textMuted,
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                '256-bit SSL Encrypted • ISO 27001 Certified Cloud',
                style: TextStyle(
                  fontSize: 11,
                  color: AlogyanColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Institute Admin? Sign in to Alogyan Web CMS for staff management',
          style: TextStyle(fontSize: 11, color: AlogyanColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Clean separated bottom sheet for Institutional Google account sign-in
  void _showGoogleSheet(BuildContext context, AuthController controller) {
    QuickDemoLoginSheet.show(context, (user) {
      controller.loginWithDemo(user);
    });
  }

  /// Clean separated bottom sheet for Email & Password authentication
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: MascotHoldingSheetWrapper(
          child: Container(
            padding: const EdgeInsets.fromLTRB(26, 12, 26, 28),
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
                    margin: const EdgeInsets.only(bottom: 18),
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
                          LucideIcons.mail,
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
                            'Email & Password',
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
                            'Sign in with institutional staff credentials',
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

                const SizedBox(height: 20),

                // Email Form Fields
                _buildEmailFields(controller, ctx),

                // Error Banner inside Sheet
                Obx(() {
                  final error = controller.errorMessage.value;
                  if (error.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
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

                const SizedBox(height: 22),

                // Sign In Button
                Obx(() {
                  final isLoading = controller.isLoading.value;
                  return SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              await controller.loginWithEmail();
                              if (controller.isLoggedIn && ctx.mounted) {
                                Navigator.pop(ctx);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AlogyanColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
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
                                  'Signing in...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(LucideIcons.arrowRight, size: 16),
                              ],
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailFields(AuthController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          label: 'Institutional Email',
          hintText: 'teacher@alogyan.com',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            LucideIcons.mail,
            size: 18,
            color: AlogyanColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => AuthTextField(
            label: 'Password',
            hintText: '••••••••',
            controller: controller.passwordController,
            obscureText: !controller.isPasswordVisible.value,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(
              LucideIcons.lock,
              size: 18,
              color: AlogyanColors.textSecondary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordVisible.value
                    ? LucideIcons.eyeOff
                    : LucideIcons.eye,
                size: 18,
                color: AlogyanColors.textSecondary,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
            trailingLabelAction: GestureDetector(
              onTap: () => _showForgotPasswordSheet(context),
              child: const Text(
                'Forgot?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AlogyanColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showForgotPasswordSheet(BuildContext context) {
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
class _RedWaveHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Vibrant Red Gradient Wave
    final wavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFE53935), // Alogyan vibrant red
          Color(0xFFB71C1C), // Deep crimson
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    final path = Path();
    path.lineTo(0, size.height * 0.78);
    path.quadraticBezierTo(
      size.width * 0.28,
      size.height * 0.98,
      size.width * 0.60,
      size.height * 0.84,
    );
    path.quadraticBezierTo(
      size.width * 0.86,
      size.height * 0.72,
      size.width,
      size.height * 0.86,
    );
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, wavePaint);

    // 2. Translucent Layered Secondary Wave
    final accentPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final accentPath = Path();
    accentPath.moveTo(0, size.height * 0.70);
    accentPath.quadraticBezierTo(
      size.width * 0.32,
      size.height * 0.90,
      size.width * 0.65,
      size.height * 0.78,
    );
    accentPath.quadraticBezierTo(
      size.width * 0.88,
      size.height * 0.68,
      size.width,
      size.height * 0.78,
    );
    canvas.drawPath(accentPath, accentPaint);

    // 3. Subtle Ambient Light Orbits
    final orbitPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.35),
      90,
      orbitPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.20),
      45,
      orbitPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Crisp, authentic 4-color Google "G" logo
class _GoogleLogoWidget extends StatelessWidget {
  const _GoogleLogoWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(20, 20), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Red (Top arc)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1.7),
      -math.pi * 0.75,
      math.pi * 0.5,
      false,
      redPaint,
    );

    // Yellow (Left arc)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1.7),
      math.pi * 0.75,
      math.pi * 0.5,
      false,
      yellowPaint,
    );

    // Green (Bottom arc)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1.7),
      math.pi * 0.25,
      math.pi * 0.5,
      false,
      greenPaint,
    );

    // Blue (Right arc)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1.7),
      -math.pi * 0.25,
      math.pi * 0.45,
      false,
      bluePaint,
    );

    // Blue (Horizontal crossbar)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.45, h * 0.42, w - 0.5, h * 0.58),
        const Radius.circular(1.5),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
